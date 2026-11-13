module Day
  # Packs prep + stop islands into location swimlanes (Geamos, TADAAA/hub, Jelena).
  # Customer stops stay on the previous supplier/hub stop's lane.
  class TimelineLayout
    HUB_KEY = "hub"
    LANE_ORDER = ["supplier:geamos", HUB_KEY, "supplier:jelena"].freeze
    ISLAND_PAD = 12
    CARD_H = 64
    ISLAND_H = CARD_H + ISLAND_PAD * 2
    STACK_GAP = 8
    ROW_PAD = 8
    MIN_WIDTH = 80

    Block = Struct.new(
      :kind, :lane_key, :start_m, :end_m, :track, :track_span, :object, :anchor,
      :left, :width, :right, :top, :height, :center_y,
      keyword_init: true
    )

    Lane = Struct.new(
      :key, :label, :color, :badge, :blocks, :track_count, :height, :top,
      keyword_init: true
    )

    Connector = Struct.new(:x1, :y1, :x2, :y2, :delivery, :from_id, :to_id, :kind, :y2_from, :order_ids, keyword_init: true)

    attr_reader :lanes, :connectors, :so_connectors, :total_height, :timeline_width

    def initialize(graph, px_per_hour:, start_hour:, end_hour:)
      @graph = graph
      @px_per_hour = px_per_hour
      @start_minutes = start_hour * 60
      @timeline_width = (end_hour - start_hour) * px_per_hour
      @blocks_by_stop = {}
      @blocks_by_so = {}
      build!
    end

    def prep_blocks
      lanes.flat_map { |lane| lane.blocks.select { |b| b.kind == :prep } }
    end

    def stop_blocks
      lanes.flat_map { |lane| lane.blocks.select { |b| b.kind == :stop } }
    end

    # Runnable check: track ranges never overlap in time; multi-SO pickups span their preps;
    # overlapping hub arrivals from above sit above arrivals from below.
    def self.self_check!(graph = Day.graph)
      layout = new(graph, px_per_hour: 200, start_hour: 6, end_hour: 20)
      layout.lanes.each do |lane|
        blocks = lane.blocks
        blocks.combination(2) do |a, b|
          next unless track_ranges_overlap?(a, b)
          raise "overlap on #{lane.key} track #{a.track}" if overlap?(a.start_m, a.end_m, b.start_m, b.end_m)
        end

        blocks.select { |b| b.kind == :stop }.each do |stop|
          if stop.anchor
            anchor = blocks.find { |b| b.object.equal?(stop.anchor) }
            raise "customer not on anchor track on #{lane.key}" if anchor && stop.track != anchor.track
            next
          end
          next unless stop.object.supplier?

          related = blocks.select { |b| b.kind == :prep && stop.object.supplier_orders.include?(b.object) }
          next if related.empty?

          t0 = related.map(&:track).min
          span = related.map(&:track).max - t0 + 1
          raise "stop not spanning prep tracks on #{lane.key}" if stop.track != t0 || (stop.track_span || 1) != span
        end
      end

      hub = layout.lanes.find { |l| l.key == HUB_KEY }
      if hub
        arrivals = hub.blocks.select { |b| b.kind == :stop && !b.anchor && inbound_from_other_lane?(b) }
        arrivals.combination(2) do |a, b|
          next unless overlap?(a.start_m, a.end_m, b.start_m, b.end_m)
          ra = lane_rank(prev_lane_key(a))
          rb = lane_rank(prev_lane_key(b))
          next if ra == rb
          raise "crossed hub arrivals" if (ra < rb) != (a.track < b.track)
        end
      end

      stay = layout.so_connectors.find { |c|
        c.kind == :stay &&
          c.from_id == "stop-d_jelena_to_hub-2" &&
          c.to_id == "stop-d_hub_to_sam-1"
      }
      raise "missing Sam cake hub stay connector" unless stay

      true
    end

    def self.inbound_from_other_lane?(block)
      prev = prev_lane_key(block)
      prev && prev != block.lane_key
    end

    def self.prev_lane_key(block)
      stop = block.object
      return nil unless stop.is_a?(Day::Stop)

      idx = stop.delivery.stops.index(stop)
      return nil if idx.nil? || idx.zero?

      prev = stop.delivery.stops[idx - 1]
      return nil if prev.customer?

      layout_lane_key(prev)
    end

    def self.layout_lane_key(stop)
      if stop.hub? || (stop.supplier? && stop.supplier_id == "tadaaa")
        HUB_KEY
      elsif stop.supplier?
        "supplier:#{stop.supplier_id}"
      else
        "other:#{stop.place}"
      end
    end

    def self.lane_rank(key)
      idx = LANE_ORDER.index(key)
      idx.nil? ? LANE_ORDER.size : idx
    end

    def self.overlap?(a0, a1, b0, b1)
      a0 < b1 && b0 < a1
    end

    def self.track_ranges_overlap?(a, b)
      a0 = a.track
      a1 = a.track + (a.track_span || 1) - 1
      b0 = b.track
      b1 = b.track + (b.track_span || 1) - 1
      a0 <= b1 && b0 <= a1
    end

    private

    def build!
      raw = collect_blocks
      grouped = raw.group_by(&:lane_key)
      keys = ordered_lane_keys(grouped.keys)

      y = 0
      @lanes = keys.map do |key|
        blocks = pack!(grouped.fetch(key))
        track_count = (blocks.map { |b| b.track + (b.track_span || 1) - 1 }.max || 0) + 1
        height = ROW_PAD * 2 + track_count * ISLAND_H + [track_count - 1, 0].max * STACK_GAP
        place_geometry!(blocks, y)
        lane = Lane.new(
          key: key,
          label: lane_label(key),
          color: lane_color(key),
          badge: lane_badge(key),
          blocks: blocks,
          track_count: track_count,
          height: height,
          top: y
        )
        y += height
        lane
      end
      @total_height = y
      @blocks_by_so = prep_blocks.to_h { |b| [b.object, b] }
      @connectors = build_connectors
      @so_connectors = build_so_connectors
    end

    def collect_blocks
      blocks = []

      @graph.deliveries.each do |delivery|
        prev_lane = nil
        prev_stop = nil
        delivery.stops.each do |stop|
          key = lane_key_for_stop(stop, prev_lane)
          start_m = stop.window_start_minutes
          end_m = stop.window_end_minutes
          next if start_m.nil? || end_m.nil?

          stop_block = Block.new(
            kind: :stop,
            lane_key: key,
            start_m: start_m,
            end_m: end_m,
            object: stop,
            # Same-lane customer dropoffs share the previous stop's track (straight arrow).
            anchor: (stop.customer? && key == prev_lane) ? prev_stop : nil
          )
          blocks << stop_block
          @blocks_by_stop[stop] = stop_block
          unless stop.customer?
            prev_lane = key
            prev_stop = stop
          end

          next unless stop.supplier?

          stop.supplier_orders.each do |so|
            next if so.window_start_minutes.nil? || so.window_end_minutes.nil?

            blocks << Block.new(
              kind: :prep,
              lane_key: lane_key_for_supplier_order(so),
              start_m: so.window_start_minutes,
              end_m: so.window_end_minutes,
              object: so
            )
          end
        end
      end

      # Deduplicate prep if the same SO appears on multiple stops (shouldn't, but safe).
      prep, stops = blocks.partition { |b| b.kind == :prep }
      prep.uniq! { |b| b.object.object_id }
      prep + stops
    end

    def lane_key_for_stop(stop, prev_lane = nil)
      if stop.customer?
        prev_lane || HUB_KEY
      elsif stop.hub? || (stop.supplier? && hub_supplier?(stop.supplier_id))
        HUB_KEY
      elsif stop.supplier?
        "supplier:#{stop.supplier_id}"
      else
        "other:#{stop.place}"
      end
    end

    def lane_key_for_supplier_order(so)
      if hub_supplier?(so.supplier_id) || so.supplier_id == "tesco"
        HUB_KEY
      else
        "supplier:#{so.supplier_id}"
      end
    end

    def hub_supplier?(id)
      id == "tadaaa"
    end

    def ordered_lane_keys(keys)
      ordered = LANE_ORDER.select { |k| keys.include?(k) }
      ordered + (keys - ordered).sort
    end

    def lane_label(key)
      case key
      when HUB_KEY
        "TADAAA!"
      when /\Asupplier:(.+)\z/
        @graph.suppliers.find { |s| s.id == $1 }&.name || $1
      else
        key
      end
    end

    def lane_color(key)
      case key
      when HUB_KEY
        @graph.suppliers.find { |s| s.id == "tadaaa" }&.color
      when /\Asupplier:(.+)\z/
        @graph.suppliers.find { |s| s.id == $1 }&.color
      end
    end

    def lane_badge(key)
      case key
      when HUB_KEY
        "T"
      when /\Asupplier:(.+)\z/
        lane_label(key).to_s.first
      end
    end

    def pack!(blocks)
      # Bottom-biased (e.g. Jelena→hub) last so Geamos→hub can claim top tracks first.
      sorted = blocks.sort_by { |b| [track_bias(b) == :bottom ? 1 : 0, b.start_m, b.end_m, b.kind == :prep ? 0 : 1] }
      track_intervals = [] # exclusive [start_m, end_m) ranges per track
      placed = []

      sorted.each do |block|
        occ_end = track_occupancy_end(block)
        track, span = preferred_track_and_span(block, placed, track_intervals, occ_end)
        track = track_intervals.size if track.nil?
        span ||= 1
        span.times do |i|
          t = track + i
          track_intervals[t] ||= []
          track_intervals[t] << [block.start_m, occ_end]
        end
        block.track = track
        block.track_span = span
        placed << block
      end
      sorted
    end

    # :top = from lane above / heading up; :bottom = from lane below / heading down.
    def track_bias(block)
      return nil unless block.kind == :stop
      stop = block.object
      return nil if stop.customer?

      idx = stop.delivery.stops.index(stop)
      return nil if idx.nil?

      prev = idx.positive? ? stop.delivery.stops[idx - 1] : nil
      if prev && !prev.customer?
        prev_key = lane_key_for_stop(prev)
        if prev_key != block.lane_key
          return self.class.lane_rank(prev_key) < self.class.lane_rank(block.lane_key) ? :top : :bottom
        end
      end

      nxt = stop.delivery.stops[idx + 1]
      return nil unless nxt && !nxt.customer?

      next_key = lane_key_for_stop(nxt)
      return nil if next_key == block.lane_key

      self.class.lane_rank(next_key) > self.class.lane_rank(block.lane_key) ? :bottom : :top
    end

    # Multi-SO supplier pickups span every related prep track; customer dropoffs stay on the prior stop's track.
    # Bottom-biased stops skip free upper tracks so cross-lane legs stay untangled.
    def preferred_track_and_span(block, placed, track_intervals, occ_end)
      free_span = ->(t, span) {
        span.times.all? do |i|
          (track_intervals[t + i] || []).none? { |a0, a1| self.class.overlap?(a0, a1, block.start_m, occ_end) }
        end
      }

      if block.kind == :stop && block.anchor
        anchored = placed.find { |b| b.object.equal?(block.anchor) }
        return [anchored.track, 1] if anchored
      end

      if block.kind == :stop && block.object.supplier?
        sos = block.object.supplier_orders
        related = placed.select { |b| b.kind == :prep && sos.include?(b.object) }
        if related.any?
          t0 = related.map(&:track).min
          span = related.map(&:track).max - t0 + 1
          # ponytail: assumes related preps packed on contiguous tracks; regroup if a fixture splits them
          return [t0, span]
        end
      end

      if track_bias(block) == :bottom
        last = track_intervals.size - 1
        return [last, 1] if last >= 0 && free_span.call(last, 1)
        return [nil, 1]
      end

      free = track_intervals.each_index.find { |t| free_span.call(t, 1) }
      [free, 1]
    end

    # Reserve through a same-lane following customer so the dropoff keeps a straight arrow.
    def track_occupancy_end(block)
      return block.end_m unless block.kind == :stop
      stop = block.object
      return block.end_m if stop.customer?

      nxt = stop.delivery.stops[stop.delivery.stops.index(stop) + 1]
      return block.end_m unless nxt&.customer?

      cust = @blocks_by_stop[nxt]
      return block.end_m unless cust && cust.lane_key == block.lane_key

      [block.end_m, cust.end_m].max
    end

    def place_geometry!(blocks, lane_top)
      blocks.each do |block|
        left = ((block.start_m - @start_minutes).to_f / 60) * @px_per_hour
        width = ((block.end_m - block.start_m).to_f / 60) * @px_per_hour
        width = [width, MIN_WIDTH].max
        span = block.track_span || 1
        height = span * ISLAND_H + (span - 1) * STACK_GAP
        top = lane_top + ROW_PAD + block.track * (ISLAND_H + STACK_GAP)
        block.left = left
        block.width = width
        block.right = left + width
        block.top = top
        block.height = height
        block.center_y = top + height / 2.0
      end
    end

    def build_connectors
      @graph.deliveries.flat_map do |delivery|
        delivery.stops.each_cons(2).filter_map do |a, b|
          ba = @blocks_by_stop[a]
          bb = @blocks_by_stop[b]
          next unless ba && bb

          Connector.new(
            x1: ba.right,
            y1: ba.center_y,
            x2: bb.left,
            y2: bb.center_y,
            delivery: delivery,
            from_id: block_dom_id(ba),
            to_id: block_dom_id(bb),
            kind: :ride,
            order_ids: delivery.related_order_ids
          )
        end
      end
    end

    # Prep → first pickup, and hub stay (unload → later load) for each supplier order.
    # Same-delivery stop pairs are skipped — ride edges already cover that path, even when
    # cargo rides through intermediate stops without load/unload (merge multileg).
    def build_so_connectors
      stops = stop_blocks

      @graph.supplier_orders.flat_map do |so|
        item_ids = so.items.map(&:id)
        next [] if item_ids.empty?

        nodes = []
        prep = @blocks_by_so[so]
        nodes << prep if prep
        nodes.concat(
          stops.select { |b| (b.object.order_item_ids & item_ids).any? }.sort_by(&:start_m)
        )
        nodes.uniq!
        nodes.sort_by!(&:start_m)

        nodes.each_cons(2).filter_map do |a, b|
          next if a.kind == :stop && b.kind == :stop && a.object.delivery.equal?(b.object.delivery)

          y2_from = a.kind == :prep
          Connector.new(
            x1: a.right,
            y1: a.center_y,
            x2: b.left,
            y2: y2_from ? a.center_y : b.center_y,
            from_id: block_dom_id(a),
            to_id: block_dom_id(b),
            kind: so_connector_kind(a, b, item_ids),
            y2_from: y2_from,
            order_ids: [so.order_id].compact
          )
        end
      end
    end

    def so_connector_kind(a, b, item_ids)
      if a.kind == :stop && b.kind == :stop &&
          (a.object.unload_item_ids & item_ids).any? &&
          (b.object.load_item_ids & item_ids).any?
        :stay
      else
        :flow
      end
    end

    def block_dom_id(block)
      if block.kind == :prep
        "prep-#{block.object.id}"
      else
        stop = block.object
        "stop-#{stop.delivery.id}-#{stop.position}"
      end
    end
  end
end
