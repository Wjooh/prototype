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
      item_ids = Array(attrs[:order_item_ids]).map(&:to_s)
      Stop.new(**attrs.except(:order_item_ids)).tap do |stop|
        stop.delivery = delivery
        stop.supplier = @suppliers_by_id[stop.supplier_id]
        stop.order = @orders_by_id[stop.order_id]
        stop.order_item_ids = item_ids
        stop.items = item_ids.filter_map { |id| @order_items_by_id[id] }
      end
    end
  end
end
