Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "pages#index"
  get "parties" => "pages#catalog", defaults: { category_slug: "parties" }, as: :parties
  get "parties/:subcategory_slug" => "pages#bundle_subcategory", defaults: { category_slug: "parties" }, as: :parties_subcategory
  get "kids" => "pages#catalog", defaults: { category_slug: "kids" }, as: :kids
  get "kids/:subcategory_slug" => "pages#bundle_subcategory", defaults: { category_slug: "kids" }, as: :kids_subcategory
  get "corporate" => "pages#catalog", defaults: { category_slug: "corporate" }, as: :corporate
  get "corporate/:subcategory_slug" => "pages#bundle_subcategory", defaults: { category_slug: "corporate" }, as: :corporate_subcategory
  get "inspo" => "pages#inspo", as: :inspo
  get "catalog" => "pages#catalog", as: :catalog
  get "catalog/:category_slug/:subcategory_slug" => "pages#subcategory", as: :catalog_subcategory
  get "catalog/:category_slug" => "pages#catalog", as: :catalog_category
end
