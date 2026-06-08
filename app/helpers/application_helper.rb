module ApplicationHelper
  def catalog_link_params
    request.query_parameters.slice("filter").symbolize_keys
  end

  def packages_path_with_params(**extra)
    packages_path(**catalog_link_params, **extra)
  end

  def catalog_path_with_params(**extra)
    catalog_path(**catalog_link_params, **extra)
  end

  def subcategory_path_with_params(category_slug, subcategory_slug, **extra)
    category = Category.find_by_slug(category_slug)
    link_params = catalog_link_params.merge(extra)

    if category&.bundles?
      package_subcategory_path(category_slug, subcategory_slug, **link_params)
    else
      subcategory_path(category_slug, subcategory_slug, **link_params)
    end
  end
end
