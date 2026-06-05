class PagesController < ApplicationController
  def index
    @bundle_categories = Category.bundles
    @product_categories = Category.products
  end

  def catalog
    @filters = Filter.all
    @active_filter = params[:filter].presence
    @nav_categories = Category.for_type(params[:type])
    @active_subcategory_slug = nil
    @subcategories = @nav_categories.flat_map(&:subcategories)
  end

  def subcategory
    @nav_category = Category.find_by_slug(params[:category_slug])
    @subcategory = @nav_category&.find_subcategory(params[:subcategory_slug])

    if @nav_category.nil? || @subcategory.nil?
      raise ActionController::RoutingError, "Not Found"
    end

    @nav_categories = [ @nav_category ]
    @active_subcategory_slug = @subcategory.slug
    @items = if @nav_category.bundles?
      Bundle.for_subcategory(@subcategory.slug)
    elsif @nav_category.products?
      Product.for_subcategory(@subcategory.slug)
    end
  end
end
