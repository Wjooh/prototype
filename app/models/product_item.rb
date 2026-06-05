class ProductItem
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :title, :string
  attribute :price, :string
  attribute :image_url, :string
  attribute :kids, :boolean, default: false
  attribute :corporate, :boolean, default: false

  def to_h
    attributes.symbolize_keys
  end
end
