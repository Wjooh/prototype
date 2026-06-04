class PagesController < ApplicationController
  def index
    @bundle_rows = YAML.safe_load_file(
      Rails.root.join("db/fixtures/bundle_rows.yml"),
      symbolize_names: true
    )
  end
end
