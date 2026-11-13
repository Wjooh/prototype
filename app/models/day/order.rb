module Day
  class Order
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id, :string
    attribute :customer_name, :string
    attribute :avatar_initials, :string
    attribute :slot_start, :string
    attribute :slot_end, :string
    attribute :total_pence, :integer
    attribute :margin_pct, :integer

    attr_accessor :supplier_orders, :graph

    def initialize(*)
      super
      @supplier_orders = []
    end

    def items
      supplier_orders.flat_map(&:items)
    end

    def item_ids
      items.map(&:id)
    end

    def suppliers
      supplier_orders.map(&:supplier).compact.uniq
    end

    def deliveries
      graph.deliveries_for_order(self)
    end

    def delivery_cost_pence
      deliveries.sum(&:cost_pence)
    end

    def slot_label
      "#{slot_start}–#{slot_end}"
    end

    def total_label
      format("£%.2f", total_pence / 100.0)
    end

    def delivery_cost_label
      format("£%.2f", delivery_cost_pence / 100.0)
    end
  end
end
