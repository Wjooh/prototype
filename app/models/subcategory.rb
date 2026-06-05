class Subcategory
  include ActiveModel::Model
  include ActiveModel::Attributes
  include Slugged

  attribute :name, :string
  attribute :product_count, :integer

  attr_reader :category

  def self.from_fixture(attrs, category:)
    new(
      name: attrs[:name],
      slug: attrs[:slug],
      product_count: attrs[:product_count]
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
end
