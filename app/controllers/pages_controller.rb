class PagesController < ApplicationController
  def index
    @home = true
    @bundle_categories = Category.bundles.select(&:has_items?)
    @product_categories = Category.products
  end

  def inspo
    @inspo = true
    @category = nil
    @active_subcategory_slug = nil
    @nav_categories = Category.bundles.select(&:has_items?)
    @subcategories = @nav_categories.flat_map(&:subcategories_with_items)
  end

  def catalog
    if params[:category_slug].present?
      @category = Category.find_by_slug(params[:category_slug])
      raise ActionController::RoutingError, "Not Found" if @category.nil?
    end
    @active_subcategory_slug = nil

    if @category
      raise ActionController::RoutingError, "Not Found" unless @category.has_items?

      if @category.bundles?
        @nav_categories = [@category]
        @subcategories = @category.subcategories_with_items
        @product_categories = Category.products
      else
        @nav_categories = Category.products.select(&:has_items?)
        @subcategories = @category.subcategories_with_items
        @active_category_slug = @category.slug
      end
    else
      @nav_categories = Category.products.select(&:has_items?)
      @subcategories = @nav_categories.flat_map(&:subcategories_with_items)
      @product_categories = nil
    end
  end

  def subcategory
    @category = nil
    @nav_category = Category.find_by_slug(params[:category_slug])
    @subcategory = @nav_category&.find_subcategory(params[:subcategory_slug])

    if @nav_category.nil? || @subcategory.nil? || !@nav_category.products? || !@subcategory.has_items?
      raise ActionController::RoutingError, "Not Found"
    end

    @nav_categories = Category.products.select(&:has_items?)
    @active_category_slug = @nav_category.slug
    @active_subcategory_slug = @subcategory.slug
    @items = @subcategory.items_for
  end

  def bundle_subcategory
    @category = Category.find_by_slug(params[:category_slug])
    @subcategory = @category&.find_subcategory(params[:subcategory_slug])

    if @category.nil? || @subcategory.nil? || !@category.bundles? || !@subcategory.has_items?
      raise ActionController::RoutingError, "Not Found"
    end

    @nav_categories = [@category]
    @active_subcategory_slug = @subcategory.slug
    @items = @subcategory.items_for
    @product_categories = Category.products
  end
end
