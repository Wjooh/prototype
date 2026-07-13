class Bundle
  include ActiveModel::Model
  include ActiveModel::Attributes
  include FixtureLoadable

  AGE_BANDS = [
    { key: "baby", range: 0...2 },
    { key: "toddler", range: 2...4 },
    { key: "preschool", range: 4...6 },
    { key: "kids", range: 6...10 },
    { key: "tweens", range: 10...13 },
    { key: "teens", range: 13..18 }
  ].freeze

  GENDER_MATCHES = {
    0 => %w[boys neutral],
    1 => %w[neutral],
    2 => %w[girls neutral]
  }.freeze

  attribute :title, :string
  attribute :price, :string
  attribute :image_url, :string
  attribute :gender, :string

  attr_reader :subcategory, :ages

  def self.fixture_path
    Rails.root.join("db/fixtures/bundles.yml")
  end

  def self.load_records
    YAML.safe_load_file(fixture_path, symbolize_names: true).flat_map { |attrs| from_fixture(attrs) }
  end

  def self.from_fixture(attrs)
    category = Category.find_by_slug(attrs[:category])
    subcategory = category&.find_subcategory(attrs[:subcategory])
    (attrs[:items] || []).map do |item_attrs|
      ages = Array(item_attrs[:ages]).map(&:to_s)
      new(**item_attrs.except(:ages)).tap do |bundle|
        bundle.instance_variable_set(:@subcategory, subcategory)
        bundle.instance_variable_set(:@ages, ages)
      end
    end
  end

  def self.for_subcategory(subcategory)
    all.select do |bundle|
      bundle.subcategory&.slug == subcategory.slug &&
        bundle.subcategory&.category_slug == subcategory.category_slug
    end
  end

  def self.age_band_for(age)
    age = age.to_i
    AGE_BANDS.find { |band| band[:range].cover?(age) }&.fetch(:key)
  end

  def self.matching_kids(age:, gender:)
    age_band = age_band_for(age)
    genders = GENDER_MATCHES.fetch(gender.to_i, %w[neutral])

    all.select do |bundle|
      bundle.subcategory&.category_slug == "kids" &&
        genders.include?(bundle.gender) &&
        bundle.ages.include?(age_band)
    end
  end

  def subcategory_name
    subcategory&.name
  end

  def to_h
    attributes.slice("title", "price", "image_url").symbolize_keys
  end
end
