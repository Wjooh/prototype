class PagesController < ApplicationController
  def index
    @bundles = Bundle.all
  end

  def catalog
    @filters = Filter.all
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
      Bundle.find_by_subcategory_slug(@subcategory.slug)&.cards
    elsif @nav_category.products?
      Product.find_by_subcategory_slug(@subcategory.slug)&.items
    end
  end
end
