module Slugged
  extend ActiveSupport::Concern

  included do
    attribute :slug, :string
  end

  class_methods do
    def find_by_slug(slug)
      all.find { |record| record.slug == slug }
    end

    def find_by_slug!(slug)
      find_by_slug(slug) || raise(ActiveRecord::RecordNotFound, "Couldn't find #{name} with slug=#{slug}")
    end
  end
end
