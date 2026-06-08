module ApplicationHelper
  def bundle_category_path(category)
    public_send(:"#{category.slug}_path")
  end

  def subcategory_link(category_slug, subcategory_slug, category:)
    if category.bundles? && (@category.present? || @inspo)
      "##{subcategory_anchor_id(category_slug, subcategory_slug)}"
    elsif category.bundles? && @home
      "#{bundle_category_path(category)}##{subcategory_anchor_id(category_slug, subcategory_slug)}"
    else
      catalog_subcategory_path(category_slug, subcategory_slug)
    end
  end

  def subcategory_anchor_id(category_slug, subcategory_slug)
    @inspo ? "#{category_slug}-#{subcategory_slug}" : subcategory_slug
  end
end
