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
      assign_guest_params
    else
      if @party_type == "kids"
        @step = 3
        assign_guest_params
        @bundles = Bundle.matching_kids(age: @kids_age, gender: @kids_gender)
      else
        @step = 2
        assign_guest_params
      end
    end
  end

  private

  def assign_guest_params
    @kids_count = params[:kids_count].presence&.to_i
    @adults_count = params[:adults_count].presence&.to_i
    @guests_count = params[:guests_count].presence&.to_i
    @kids_age = params[:kids_age].presence&.to_i || 6
    @kids_gender = params[:kids_gender].presence&.to_i || 1
    @include_kids = params[:include_kids].present?
  end
end
