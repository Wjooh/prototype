class PagesController < ApplicationController
  def index
    @bundles = Bundle.all
  end

  def main
    @filters = Filter.all
    @nav_categories = Category.products
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
    @items = Bundle.find_by_subcategory_slug(@subcategory.slug)&.cards if @nav_category.bundles?
  end
end
