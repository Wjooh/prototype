module Day
  class Product
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id, :string
    attribute :name, :string
    attribute :emoji, :string
    attribute :supplier_id, :string

    attr_accessor :supplier
  end
end
