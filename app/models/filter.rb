class Filter
  include ActiveModel::Model
  include ActiveModel::Attributes
  include FixtureLoadable

  attribute :name, :string
  attribute :key, :string

  def self.fixture_path
    Rails.root.join("db/fixtures/main.yml")
  end

  def self.load_records
    data = YAML.safe_load_file(fixture_path, symbolize_names: true)
    data.flat_map do |scope, filters|
      filters.map { |attrs| new(name: attrs[:name], key: attrs[:key]) }
    end
  end

  def self.for_scope(scope)
    data = YAML.safe_load_file(fixture_path, symbolize_names: true)
    fixture_key = scope == "bundles" ? :bundle_filters : :product_filters
    data.fetch(fixture_key, []).map { |attrs| new(name: attrs[:name], key: attrs[:key]) }
  end
end
