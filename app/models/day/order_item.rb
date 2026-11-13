module Day
  class OrderItem
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id, :string
    attribute :supplier_order_id, :string
    attribute :product_id, :string
    attribute :quantity, :integer

    attr_accessor :product, :supplier_order

    def order
      supplier_order&.order
    end
  end
end
