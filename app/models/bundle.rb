class Bundle
  include ActiveModel::Model
  include FixtureLoadable

  attr_reader :subcategory, :cards

  def self.fixture_path
    Rails.root.join("db/fixtures/bundles.yml")
  end

  def self.load_records
    YAML.safe_load_file(fixture_path, symbolize_names: true).map { |attrs| from_fixture(attrs) }
  end

  def self.from_fixture(attrs)
    bundle = new
    bundle.instance_variable_set(:@subcategory, Subcategory.find_by_slug(attrs[:subcategory]))
    bundle.instance_variable_set(
      :@cards,
      (attrs[:cards] || []).map { |card_attrs| BundleCard.new(**card_attrs) }
    )
    bundle
  end

  def self.find_by_subcategory_slug(slug)
    all.find { |bundle| bundle.subcategory&.slug == slug }
  end

  def subcategory_name
    subcategory&.name
  end
end
