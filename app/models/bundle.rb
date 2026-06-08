class Bundle
  include ActiveModel::Model
  include ActiveModel::Attributes
  include FixtureLoadable

  attribute :title, :string
  attribute :price, :string
  attribute :image_url, :string

  attr_reader :subcategory

  def self.fixture_path
    Rails.root.join("db/fixtures/bundles.yml")
  end

  def self.load_records
    YAML.safe_load_file(fixture_path, symbolize_names: true).flat_map { |attrs| from_fixture(attrs) }
  end

  def self.from_fixture(attrs)
    category = Category.find_by_slug(attrs[:category])
    subcategory = category&.find_subcategory(attrs[:subcategory])
    (attrs[:items] || []).map do |item_attrs|
      new(**item_attrs).tap { |bundle| bundle.instance_variable_set(:@subcategory, subcategory) }
    end
  end

  def self.for_subcategory(subcategory)
    all.select do |bundle|
      bundle.subcategory&.slug == subcategory.slug &&
        bundle.subcategory&.category_slug == subcategory.category_slug
    end
  end

  def subcategory_name
    subcategory&.name
  end

  def to_h
    attributes.slice("title", "price", "image_url").symbolize_keys
  end
end
