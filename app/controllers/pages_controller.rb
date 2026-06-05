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
    @nav_categories = product_categories
    @active_subcategory_slug = nil
    @subcategories = @nav_categories.flat_map { |category|
      category[:subcategories].map { |subcategory|
        subcategory.merge(category: category[:name], category_slug: category[:slug])
      }
    }
  end

  def subcategory
    @nav_category = fixture_categories.find { |category|
      category[:slug] == params[:category_slug]
    }
    @subcategory = @nav_category&.dig(:subcategories)&.find { |subcategory|
      subcategory[:slug] == params[:subcategory_slug]
    }

    if @nav_category.nil? || @subcategory.nil?
      raise ActionController::RoutingError, "Not Found"
    end

    @nav_categories = [ @nav_category ]
    @active_subcategory_slug = @subcategory[:slug]
    @items = bundle_items_for(@subcategory[:slug]) if @nav_category[:type] == "bundles"
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

  def bundle_items_for(subcategory_slug)
    fixture_bundles.find { |bundle| bundle[:subcategory] == subcategory_slug }
      &.dig(:cards) || []
  end

  def fixture_bundles
    @fixture_bundles ||= YAML.safe_load_file(
      Rails.root.join("db/fixtures/bundles.yml"),
      symbolize_names: true
    )
  end
end
