class BundleCard
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :title, :string
  attribute :price, :string
  attribute :image_url, :string

  def to_h
    attributes.symbolize_keys
  end
end
