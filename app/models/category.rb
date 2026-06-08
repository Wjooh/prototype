class Category
  include ActiveModel::Model
  include ActiveModel::Attributes
  include FixtureLoadable
  include Slugged

  attribute :name, :string
  attribute :type, :string

  attr_reader :subcategories

  def self.fixture_path
    Rails.root.join("db/fixtures/categories.yml")
  end

  def self.load_records
    data = YAML.safe_load_file(fixture_path, symbolize_names: true)
    data[:categories].map { |attrs| from_fixture(attrs) }
  end

  def self.from_fixture(attrs)
    category = new(name: attrs[:name], slug: attrs[:slug], type: attrs[:type])
    category.instance_variable_set(
      :@subcategories,
      (attrs[:subcategories] || []).map { |subcategory_attrs|
        Subcategory.from_fixture(subcategory_attrs, category: category)
      }
    )
    category
  end

  def self.products
    all.select(&:products?)
  end

  def self.bundles
    all.select(&:bundles?)
  end

  def self.for_type(type)
    case type
    when "bundles" then bundles
    when "products" then products
    else all
    end
  end

  def products?
    type == "products"
  end

  def bundles?
    type == "bundles"
  end

  def find_subcategory(slug)
    subcategories.find { |subcategory| subcategory.slug == slug }
  end

  def subcategories_with_items(filter: nil)
    subcategories.select { |subcategory| subcategory.has_items?(filter: filter) }
  end

  def has_items?(filter: nil)
    subcategories_with_items(filter: filter).any?
  end
end
