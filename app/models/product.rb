class Product
  include ActiveModel::Model
  include ActiveModel::Attributes
  include FixtureLoadable

  attribute :title, :string
  attribute :price, :string
  attribute :image_url, :string
  attribute :kids, :boolean, default: false
  attribute :corporate, :boolean, default: false
  attribute :uk_popular, :boolean, default: false
  attribute :mediterranean, :boolean, default: false
  attribute :eastern_european, :boolean, default: false
  attribute :georgian, :boolean, default: false

  CUISINE_TAGS = {
    uk_popular: "UK Popular",
    mediterranean: "Mediterranean",
    eastern_european: "Eastern European",
    georgian: "Georgian"
  }.freeze

  attr_reader :subcategory

  def self.fixture_path
    Rails.root.join("db/fixtures/products.yml")
  end

  def self.load_records
    YAML.safe_load_file(fixture_path, symbolize_names: true).flat_map { |attrs| from_fixture(attrs) }
  end

  def self.from_fixture(attrs)
    subcategory = Subcategory.find_by_slug(attrs[:subcategory])
    (attrs[:items] || []).map do |item_attrs|
      new(**item_attrs).tap { |product| product.instance_variable_set(:@subcategory, subcategory) }
    end
  end

  def self.for_subcategory(slug, filter: nil, audience: nil)
    items = all.select { |product| product.subcategory&.slug == slug }
    items = apply_filter(items, filter)
    sort_by_audience(items, audience)
  end

  def self.sort_by_audience(items, audience)
    return items if audience.blank?

    attribute = audience.to_sym
    return items unless %i[kids corporate].include?(attribute)

    items.sort_by { |product| product.public_send(attribute) ? 0 : 1 }
  end

  def self.apply_filter(items, filter)
    case filter
    when "uk-popular" then items.select(&:uk_popular)
    when "mediterranean" then items.select(&:mediterranean)
    when "eastern-european" then items.select(&:eastern_european)
    when "georgian" then items.select(&:georgian)
    else items
    end
  end

  def self.for_category(category)
    slugs = category.subcategories.map(&:slug)
    all.select { |product| slugs.include?(product.subcategory&.slug) }
  end

  def subcategory_name
    subcategory&.name
  end

  def cuisine_tag_labels
    CUISINE_TAGS.filter_map { |key, label| label if public_send(key) }
  end

  def to_h
    attributes.slice("title", "price", "image_url", "kids", "corporate").symbolize_keys.merge(cuisine_tags: cuisine_tag_labels)
  end
end
