class PagesController < ApplicationController
  def index
  end

  def catalog
    @audience = params[:audience]
    @nav_categories = nav_categories
    @active_subcategory_slug = nil
    @subcategories = @nav_categories.flat_map { |category| category.subcategories_with_items(audience: @audience) }
    @product_categories = Category.products if @audience.present?
  end

  def subcategory
    @audience = nil
    @nav_category = Category.find_by_slug(params[:category_slug])
    @subcategory = @nav_category&.find_subcategory(params[:subcategory_slug])

    if @nav_category.nil? || @subcategory.nil? || !@nav_category.products? || !@subcategory.has_items?
      raise ActionController::RoutingError, "Not Found"
    end

    @nav_categories = nav_categories
    @active_subcategory_slug = @subcategory.slug
    @items = @subcategory.items_for
  end

  private

  def nav_categories
    if @audience.present?
      Category.bundles.select { |category| category.has_items?(audience: @audience) }
    else
      Category.products.select(&:has_items?)
    end
  end
end
