class AssistantController < ApplicationController
  PARTY_TYPES = [
    {
      key: "adults",
      label: "Adults",
      description: "Birthday, dinner party, or celebration with friends",
      icon: "sparkles"
    },
    {
      key: "kids",
      label: "Kids",
      description: "Birthday bash or playdate for the little ones",
      icon: "gift"
    },
    {
      key: "corporate",
      label: "Corporate",
      description: "Office party, team event, or client gathering",
      icon: "building-office-2"
    }
  ].freeze

  VALID_PARTY_TYPES = PARTY_TYPES.map { |type| type[:key] }.freeze

  def show
    @step = [params.fetch(:step, 1).to_i, 1].max
    @party_types = PARTY_TYPES
    @party_type = params[:party_type].presence

    if @step >= 2
      unless VALID_PARTY_TYPES.include?(@party_type)
        redirect_to assistant_path and return
      end
    end

    case @step
    when 1
      @step = 1
    when 2
      @step = 2
      if adults? || corporate?
        assign_occasion_params
      else
        assign_guest_params
      end
    when 3
      if kids?
        @step = 3
        assign_guest_params
        @bundles = Bundle.matching_kids(age: @kids_age, gender: @kids_gender)
      elsif adults? || corporate?
        @step = 3
        assign_occasion_params
        assign_guest_params
      else
        @step = 2
        assign_guest_params
      end
    else
      if kids?
        @step = 3
        assign_guest_params
        @bundles = Bundle.matching_kids(age: @kids_age, gender: @kids_gender)
      elsif adults? || corporate?
        @step = 3
        assign_occasion_params
        assign_guest_params
      else
        @step = 2
        assign_guest_params
      end
    end
  end

  private

  def adults?
    @party_type == "adults"
  end

  def kids?
    @party_type == "kids"
  end

  def corporate?
    @party_type == "corporate"
  end

  def occasion_kind
    corporate? ? "corporate" : "private"
  end

  def assign_occasion_params
    @occasions = Occasion.for_kind(occasion_kind)
    @occasion = @occasions.find { |o| o.slug == params[:occasion] } || Occasion.default(kind: occasion_kind)
  end

  def assign_guest_params
    @kids_count = params[:kids_count].presence&.to_i
    @adults_count = params[:adults_count].presence&.to_i
    @guests_count = params[:guests_count].presence&.to_i
    @kids_age = params[:kids_age].presence&.to_i || 6
    @kids_gender = params[:kids_gender].presence&.to_i || 1
    @include_kids = params[:include_kids].present?
  end
end
