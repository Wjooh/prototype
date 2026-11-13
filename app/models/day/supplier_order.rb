module Day
  class SupplierOrder
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id, :string
    attribute :order_id, :string
    attribute :supplier_id, :string
    attribute :prep_start, :string
    attribute :prep_end, :string

    attr_accessor :supplier, :order, :items

    def initialize(*)
      super
      @items = []
    end

    def label
      [supplier&.name, order&.customer_name].compact.join(" · ")
    end

    def prep_badge_label
      name = order&.customer_name || "order"
      siblings = (order&.supplier_orders || [self])
        .select { |so| so.supplier_id == supplier_id }
        .sort_by { |so| so.window_start_minutes || 0 }
      return "prep for #{name}" if siblings.size <= 1

      part = siblings.index { |so| so.equal?(self) || so.id == id }&.+(1) || 1
      "prep for #{name} part #{part}/#{siblings.size}"
    end

    def window_start_minutes
      parse_hm(prep_start)
    end

    def window_end_minutes
      parse_hm(prep_end)
    end

    def window_label
      "#{prep_start}–#{prep_end}"
    end

    private

    def parse_hm(value)
      return if value.blank?

      hours, minutes = value.split(":").map(&:to_i)
      hours * 60 + minutes
    end
  end
end
