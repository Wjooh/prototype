module Day
  class Supplier
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id, :string
    attribute :name, :string
    attribute :color, :string
  end
end
