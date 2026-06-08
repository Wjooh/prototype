class Bundle
  include ActiveModel::Model
  include ActiveModel::Attributes
  include FixtureLoadable

  attribute :title, :string
  attribute :price, :string
  attribute :image_url, :string
  attribute :kids, :boolean, default: false
  attribute :corporate, :boolean, default: false
  attribute :weddings, :boolean, default: false

  attr_reader :subcategory

  def self.fixture_path
    Rails.root.join("db/fixtures/bundles.yml")
  end

  def self.load_records
    YAML.safe_load_file(fixture_path, symbolize_names: true).flat_map { |attrs| from_fixture(attrs) }
  end

  def self.from_fixture(attrs)
    subcategory = Subcategory.find_by_slug(attrs[:subcategory])
    (attrs[:items] || []).map do |item_attrs|
      new(**item_attrs).tap { |bundle| bundle.instance_variable_set(:@subcategory, subcategory) }
    end
  end

  def self.for_subcategory(slug, filter: nil)
    items = all.select { |bundle| bundle.subcategory&.slug == slug }
    apply_filter(items, filter)
  end

  def self.apply_filter(items, filter)
    case filter
    when "kids" then items.select(&:kids)
    when "corporate" then items.select(&:corporate)
    when "weddings" then items.select(&:weddings)
    else items
    end
  end

  def subcategory_name
    subcategory&.name
  end

  def to_h
    attributes.symbolize_keys
  end
end
