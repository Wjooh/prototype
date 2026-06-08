class Subcategory
  include ActiveModel::Model
  include ActiveModel::Attributes
  include Slugged

  attribute :name, :string

  attr_reader :category

  def self.from_fixture(attrs, category:)
    new(
      name: attrs[:name],
      slug: attrs[:slug]
    ).tap { |subcategory| subcategory.instance_variable_set(:@category, category) }
  end

  def self.all
    Category.all.flat_map(&:subcategories)
  end

  def category_name
    category.name
  end

  def category_slug
    category.slug
  end

  def items_for(filter: nil)
    if category.bundles?
      Bundle.for_subcategory(slug, filter: filter)
    elsif category.products?
      Product.for_subcategory(slug, filter: filter)
    else
      []
    end
  end

  def has_items?(filter: nil)
    items_for(filter: filter).any?
  end
end
