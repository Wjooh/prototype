module ApplicationHelper
  def subcategory_link(category_slug, subcategory_slug, category:)
    if category.bundles? && @category.present?
      "##{subcategory_slug}"
    else
      catalog_subcategory_path(category_slug, subcategory_slug)
    end
  end
end
