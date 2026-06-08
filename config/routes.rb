Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "pages#index"
  post "layout_mode" => "layout_modes#update", as: :layout_mode
  get "packages" => "pages#catalog", defaults: { catalog_scope: "bundles" }, as: :packages
  get "packages/:category_slug/:subcategory_slug" => "pages#subcategory", defaults: { catalog_scope: "bundles" }, as: :package_subcategory
  get "catalog" => "pages#catalog", defaults: { catalog_scope: "products" }, as: :catalog
  get "catalog/:category_slug/:subcategory_slug" => "pages#subcategory", defaults: { catalog_scope: "products" }, as: :subcategory
end
