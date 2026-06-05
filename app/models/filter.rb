class Filter
  include ActiveModel::Model
  include ActiveModel::Attributes
  include FixtureLoadable

  attribute :name, :string

  def self.fixture_path
    Rails.root.join("db/fixtures/main.yml")
  end

  def self.load_records
    data = YAML.safe_load_file(fixture_path, symbolize_names: true)
    data[:filters].map { |attrs| new(name: attrs[:name]) }
  end
end
