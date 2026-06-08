module ApplicationHelper
  def catalog_page?
    request.path.start_with?("/catalog")
  end

  def bundle_category_path(category)
    public_send(:"#{category.slug}_path")
  end

  def bundle_subcategory_path(category, subcategory_slug)
    public_send(:"#{category.slug}_subcategory_path", subcategory_slug)
  end

  def product_category_path(category)
    catalog_category_path(category.slug)
  end

  def subcategory_link(category_slug, subcategory_slug, category:)
    if category.bundles?
      bundle_subcategory_path(category, subcategory_slug)
    else
      catalog_subcategory_path(category_slug, subcategory_slug)
    end
  end

  def subcategory_anchor_id(category_slug, subcategory_slug)
    @inspo ? "#{category_slug}-#{subcategory_slug}" : subcategory_slug
  end
end
