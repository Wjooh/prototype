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
    link_params = build_catalog_params(extra)

    if category&.bundles?
      package_subcategory_path(category_slug, subcategory_slug, **link_params)
    else
      subcategory_path(category_slug, subcategory_slug, **link_params)
    end
  end

  def current_catalog_path(**extra)
    link_params = build_catalog_params(extra)

    if controller.action_name == "subcategory"
      if params[:catalog_scope] == "bundles"
        package_subcategory_path(params[:category_slug], params[:subcategory_slug], **link_params)
      else
        subcategory_path(params[:category_slug], params[:subcategory_slug], **link_params)
      end
    elsif params[:catalog_scope] == "bundles"
      packages_path(**link_params)
    else
      catalog_path(**link_params)
    end
  end

  def build_catalog_params(extra)
    params = catalog_link_params.merge(extra)
    params.delete(:filter) if extra.key?(:filter) && extra[:filter].nil?
    params.compact
  end

  def apply_filter_url(filter_key)
    current_catalog_path(filter: filter_key)
  end

  def clear_filter_url
    current_catalog_path(filter: nil)
  end
end
