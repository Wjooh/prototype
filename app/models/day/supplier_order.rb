module Day
  class SupplierOrder
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id, :string
    attribute :order_id, :string
    attribute :supplier_id, :string

    attr_accessor :supplier, :order, :items

    def initialize(*)
      super
      @items = []
    end
  end
end
