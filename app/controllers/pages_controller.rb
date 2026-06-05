class PagesController < ApplicationController
  def index
    subcategories_by_slug = fixture_subcategories_by_slug

    @bundles = YAML.safe_load_file(
      Rails.root.join("db/fixtures/bundles.yml"),
      symbolize_names: true
    ).map { |bundle|
      subcategory = subcategories_by_slug.fetch(bundle[:subcategory])
      bundle.merge(subcategory_name: subcategory[:name])
    }
  end

  def main
    data = YAML.safe_load_file(
      Rails.root.join("db/fixtures/main.yml"),
      symbolize_names: true
    )
    @filters = data[:filters]
    @categories = product_categories
    @subcategories = @categories.flat_map { |category|
      category[:subcategories].map { |subcategory|
        subcategory.merge(category: category[:name])
      }
    }
  end

  private

  def fixture_categories
    @fixture_categories ||= YAML.safe_load_file(
      Rails.root.join("db/fixtures/categories.yml"),
      symbolize_names: true
    )[:categories]
  end

  def product_categories
    fixture_categories.select { |category| category[:type] == "products" }
  end

  def fixture_subcategories_by_slug
    fixture_categories.flat_map { |category| category[:subcategories] }
      .index_by { |subcategory| subcategory[:slug] }
  end
end
