class Product
  include ActiveModel::Model
  include FixtureLoadable

  attr_reader :subcategory, :items

  def self.fixture_path
    Rails.root.join("db/fixtures/products.yml")
  end

  def self.load_records
    YAML.safe_load_file(fixture_path, symbolize_names: true).map { |attrs| from_fixture(attrs) }
  end

  def self.from_fixture(attrs)
    product = new
    product.instance_variable_set(:@subcategory, Subcategory.find_by_slug(attrs[:subcategory]))
    product.instance_variable_set(
      :@items,
      (attrs[:items] || []).map { |item_attrs| ProductItem.new(**item_attrs) }
    )
    product
  end

  def self.find_by_subcategory_slug(slug)
    all.find { |product| product.subcategory&.slug == slug }
  end

  def subcategory_name
    subcategory&.name
  end
end
