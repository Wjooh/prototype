module Day
  class Delivery
    include ActiveModel::Model
    include ActiveModel::Attributes

    KINDS = %w[swiftee uber pickup zaza].freeze

    attribute :id, :string
    attribute :kind, :string
    attribute :cost_pence, :integer

    attr_accessor :stops, :graph

    def initialize(*)
      super
      @stops = []
    end

    def kind_label
      kind.to_s.titleize
    end

    def cost_label
      format("£%.2f", cost_pence / 100.0)
    end

    def first_time
      stops.map(&:sort_time).min
    end

    def window_start_minutes
      stops.filter_map { |stop| parse_hm(stop.interval_start) }.min
    end

    def window_end_minutes
      stops.filter_map { |stop| parse_hm(stop.interval_end) }.max
    end

    def route_label
      stops.map(&:label).join(" → ")
    end

    def window_label
      "#{format_hm(window_start_minutes)}–#{format_hm(window_end_minutes)}"
    end

    def involves_order?(order)
      item_ids = order.item_ids
      stops.any? { |stop| stop.order_id == order.id } ||
        stops.any? { |stop| (stop.order_item_ids & item_ids).any? }
    end

    def related_order_ids
      ids = stops.filter_map(&:order_id)
      ids.concat(stops.flat_map { |stop| stop.items.filter_map { |item| item.order&.id } })
      ids.uniq
    end

    private

    def parse_hm(value)
      return if value.blank?

      hours, minutes = value.split(":").map(&:to_i)
      hours * 60 + minutes
    end

    def format_hm(minutes)
      format("%02d:%02d", minutes / 60, minutes % 60)
    end
  end
end


