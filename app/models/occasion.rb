class Occasion
  include ActiveModel::Model
  include ActiveModel::Attributes
  include FixtureLoadable
  include Slugged

  KINDS = %w[private corporate].freeze

  attribute :name, :string
  attribute :kind, :string, default: "private"
  attribute :default, :boolean, default: false

  def self.fixture_path
    Rails.root.join("db/fixtures/occasions.yml")
  end

  def self.load_records
    data = YAML.safe_load_file(fixture_path, symbolize_names: true)
    data[:occasions].map { |attrs| new(**attrs) }
  end

  def self.for_kind(kind)
    all.select { |occasion| occasion.kind == kind.to_s }
  end

  def self.default(kind: "private")
    for_kind(kind).find(&:default?) || for_kind(kind).first
  end

  def default?
    default == true
  end
end
