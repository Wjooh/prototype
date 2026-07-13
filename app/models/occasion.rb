class Occasion
  include ActiveModel::Model
  include ActiveModel::Attributes
  include FixtureLoadable
  include Slugged

  attribute :name, :string
  attribute :default, :boolean, default: false

  def self.fixture_path
    Rails.root.join("db/fixtures/occasions.yml")
  end

  def self.load_records
    data = YAML.safe_load_file(fixture_path, symbolize_names: true)
    data[:occasions].map { |attrs| new(**attrs) }
  end

  def self.default
    all.find(&:default?) || all.first
  end

  def default?
    default == true
  end
end
