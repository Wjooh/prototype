module Day
  class Graph
    attr_reader :suppliers, :products, :orders, :supplier_orders, :order_items, :deliveries

    def self.load
      new(YAML.safe_load_file(Day::FIXTURE_PATH, symbolize_names: true))
    end

    def initialize(data)
      @suppliers_by_id = {}
      @products_by_id = {}
      @orders_by_id = {}
      @supplier_orders_by_id = {}
      @order_items_by_id = {}

      @suppliers = (data[:suppliers] || []).map { |attrs| build_supplier(attrs) }
      @products = (data[:products] || []).map { |attrs| build_product(attrs) }
      @orders = (data[:orders] || []).map { |attrs| build_order(attrs) }
      @supplier_orders = (data[:supplier_orders] || []).map { |attrs| build_supplier_order(attrs) }
      @supplier_orders.sort_by! { |so| so.window_start_minutes || 0 }
      @order_items = (data[:order_items] || []).map { |attrs| build_order_item(attrs) }
      @deliveries = (data[:deliveries] || []).map { |attrs| build_delivery(attrs) }
      @deliveries.sort_by!(&:first_time)
    end

    def deliveries_for_order(order)
      deliveries.select { |delivery| delivery.involves_order?(order) }
    end

    private

    def build_supplier(attrs)
      Supplier.new(**attrs).tap { |s| @suppliers_by_id[s.id] = s }
    end

    def build_product(attrs)
      Product.new(**attrs).tap do |product|
        product.supplier = @suppliers_by_id[product.supplier_id]
        @products_by_id[product.id] = product
      end
    end

    def build_order(attrs)
      Order.new(**attrs).tap do |order|
        order.graph = self
        @orders_by_id[order.id] = order
      end
    end

    def build_supplier_order(attrs)
      SupplierOrder.new(**attrs).tap do |so|
        so.supplier = @suppliers_by_id[so.supplier_id]
        so.order = @orders_by_id[so.order_id]
        so.order&.supplier_orders << so
        @supplier_orders_by_id[so.id] = so
      end
    end

    def build_order_item(attrs)
      OrderItem.new(**attrs).tap do |item|
        item.product = @products_by_id[item.product_id]
        item.supplier_order = @supplier_orders_by_id[item.supplier_order_id]
        item.supplier_order&.items << item
        @order_items_by_id[item.id] = item
      end
    end

    def build_delivery(attrs)
      stop_attrs = attrs[:stops] || []
      Delivery.new(**attrs.except(:stops)).tap do |delivery|
        delivery.graph = self
        delivery.stops = stop_attrs.map { |s| build_stop(delivery, s) }.sort_by(&:position)
      end
    end

    def build_stop(delivery, attrs)
      load_ids = Array(attrs[:load]).map(&:to_s)
      unload_ids = Array(attrs[:unload]).map(&:to_s)
      Stop.new(**attrs.except(:load, :unload, :order_item_ids)).tap do |stop|
        stop.delivery = delivery
        stop.supplier = @suppliers_by_id[stop.supplier_id]
        stop.order = @orders_by_id[stop.order_id]
        stop.load_item_ids = load_ids
        stop.unload_item_ids = unload_ids
        stop.load_items = load_ids.filter_map { |id| @order_items_by_id[id] }
        stop.unload_items = unload_ids.filter_map { |id| @order_items_by_id[id] }
      end
    end

    # Runnable check: each ride's cargo is loaded before unloaded and ends empty.
    def self.cargo_check!(graph = Day.graph)
      graph.deliveries.each do |delivery|
        cargo = []
        delivery.stops.each do |stop|
          cargo.concat(stop.load_item_ids)
          stop.unload_item_ids.each do |id|
            idx = cargo.index(id)
            raise "#{delivery.id}: unload #{id} not in car at stop #{stop.position}" unless idx
            cargo.delete_at(idx)
          end
        end
        raise "#{delivery.id}: ends with cargo #{cargo.join(', ')}" unless cargo.empty?
      end
      true
    end
  end
end
