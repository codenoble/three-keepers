class ExclusionsController < ApplicationController
  include LoadsEmail
  include SearchEmail
  include EmailAPI

  def new
    @form = ExclusionForm.new(exclusions_model)
  end

  def create
    @form = ExclusionForm.new(exclusions_model)
    args = params[:exclusion].merge(email_id: @email.id, creator_uuid: current_user.uuid)

    if @form.validate(args)
      @form.save do |hash|
        response = GoogleSyncinator::APIClient::Exclusions.new.create(args).perform

        handle_response(response, route: @email.class.model_name.singular_route_key)
      end
    else
      flash.now[:alert] = @form.errors.full_messages.join('. ') + '.'
      render :new
    end
  end

  def destroy
    response = GoogleSyncinator::APIClient::Exclusions.new.destroy(email_id: @email.id, id: params[:id]).perform

    if response.success?
      flash[:notice] = 'Exclusion deleted'
    else
      flash[:alert] = "Error from API: #{error_from_api(response)}"
    end

    redirect_to @email
  end

  private

  def exclusions_model
    OpenStruct.new(email_id: @email.id, creator_uuid: nil, starts_at: DateTime.now, ends_at: nil, reason: nil)
  end
end
