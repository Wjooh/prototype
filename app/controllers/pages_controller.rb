class PagesController < ApplicationController
  def index
    @bundle_categories = Category.bundles
    @product_categories = Category.products
  end

  def catalog
    @active_filter = params[:filter].presence
    @filters = Filter.for_scope(params[:catalog_scope])
    @nav_categories = filtered_nav_categories
    @active_subcategory_slug = nil
    @subcategories = @nav_categories.flat_map { |category| category.subcategories_with_items(filter: @active_filter) }
  end

  def subcategory
    @nav_category = Category.find_by_slug(params[:category_slug])
    @subcategory = @nav_category&.find_subcategory(params[:subcategory_slug])

    if @nav_category.nil? || @subcategory.nil? || !category_matches_scope?(@nav_category, params[:catalog_scope])
      raise ActionController::RoutingError, "Not Found"
    end

    @active_filter = params[:filter].presence
    @filters = Filter.for_scope(params[:catalog_scope])
    @nav_categories = filtered_nav_categories
    @active_subcategory_slug = @subcategory.slug
    @items = if @nav_category.bundles?
      Bundle.for_subcategory(@subcategory.slug, filter: @active_filter)
    elsif @nav_category.products?
      Product.for_subcategory(@subcategory.slug, filter: @active_filter)
    end
  end

  private

  def filtered_nav_categories
    categories = Category.for_type(params[:catalog_scope])
    return categories if @active_filter.blank?

    categories.select { |category| category.has_items?(filter: @active_filter) }
  end

  def category_matches_scope?(category, scope)
    case scope
    when "bundles" then category.bundles?
    when "products" then category.products?
    else false
    end
  end
end
