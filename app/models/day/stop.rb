module Day
  class Stop
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :position, :integer
    attribute :place, :string
    attribute :supplier_id, :string
    attribute :order_id, :string
    attribute :pickup_start, :string
    attribute :pickup_end, :string
    attribute :dropoff_start, :string
    attribute :dropoff_end, :string

    attr_accessor :delivery, :supplier, :order, :order_item_ids, :items

    def initialize(*)
      super
      @order_item_ids = []
      @items = []
    end

    def hub?
      place == "hub"
    end

    def customer?
      place == "customer"
    end

    def supplier?
      place == "supplier"
    end

    def label
      case place
      when "hub" then "Tadaaa"
      when "customer" then order&.customer_name || "Customer"
      when "supplier" then supplier&.name || "Supplier"
      else place.to_s.titleize
      end
    end

    def time_label
      if pickup_start.present?
        "#{pickup_start}–#{pickup_end}"
      elsif dropoff_start.present?
        "#{dropoff_start}–#{dropoff_end}"
      end
    end

    def sort_time
      pickup_start.presence || dropoff_start.presence || "99:99"
    end

    def interval_start
      pickup_start.presence || dropoff_start.presence
    end

    def interval_end
      pickup_end.presence || dropoff_end.presence
    end

    def window_start_minutes
      parse_hm(interval_start)
    end

    def window_end_minutes
      parse_hm(interval_end)
    end

    def pickup?
      pickup_start.present?
    end

    def kind_label
      pickup? ? "Pickup" : "Dropoff"
    end

    private

    def parse_hm(value)
      return if value.blank?

      hours, minutes = value.split(":").map(&:to_i)
      hours * 60 + minutes
    end
  end
end

