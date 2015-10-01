class DeprovisionSchedulesController < ApplicationController
  include SearchEmail
  include LoadsEmail
  include EmailAPI

  def new
    @form = DeprovisionScheduleForm.new(deprovision_schedule_model)
  end

  def create
    @form = DeprovisionScheduleForm.new(deprovision_schedule_model)
    args = params[:deprovision_schedule].slice(:action, :scheduled_for, :reason).merge(email_id: @email.id)

    if @form.validate(args)
      @form.save do |hash|
        response = GoogleSyncinator::APIClient::DeprovisionSchedules.new.create(args).perform

        handle_response(response)
      end
    else
      flash.now[:alert] = @form.errors.full_messages.join('. ') + '.'
      render :new
    end
  end

  def update
    response = GoogleSyncinator::APIClient::DeprovisionSchedules.new.update(email_id: @email.id, id: params[:id], canceled: params[:canceled]).perform

    if response.success?
      flash[:notice] = 'Deprovision schedule updated'
    else
      flash[:alert] = "Error from API: #{error_from_api(response)}"
    end

    redirect_to person_email_path(@email.id)
  end

  def destroy
    response = GoogleSyncinator::APIClient::DeprovisionSchedules.new.destroy(email_id: @email.id, id: params[:id]).perform

    if response.success?
      flash[:notice] = 'Deprovision schedule deleted'
    else
      flash[:alert] = "Error from API: #{error_from_api(response)}"
    end

    redirect_to person_email_path(@email.id)
  end

  private

  def deprovision_schedule_model
    OpenStruct.new(email_id: @email.id, action: nil, reason: nil, scheduled_for: DateTime.now)
  end
end
