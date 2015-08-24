class ExclusionsController < ApplicationController
  before_action :load_email

  def new
    @form = ExclusionForm.new(exclusions_model)
  end

  def create
    if @email.primary?
      @form = ExclusionForm.new(exclusions_model)
      args = params[:exclusion].merge(email_id: params[:email_id], creator_uuid: current_user.uuid)

      if @form.validate(args)
        @form.save do |hash|
          response = GoogleSyncinator::APIClient::Exclusions.new.create(args).perform

          if !response.success?
            err_message = response.parse.has_key?('error') ? response.parse['error'] : response.body
            flash.now[:alert] = "Error from API: #{err_message}"
            render :new
          else
            redirect_to email_path(response.parse['email_id'])
          end
        end
      else
        flash.now[:alert] = @form.errors.full_messages.join('. ') + '.'
        render :new
      end
    else
      flash[:alert] = 'Exclusions can only be created on primary emails'
      redirect_to email_path(@email.id)
    end
  end

  def destroy
    response = GoogleSyncinator::APIClient::Exclusions.new.destroy(email_id: @email.id, id: params[:id]).perform

    if response.success?
      flash[:notice] = 'Exclusion deleted'
    else
      err_message = response.parse.has_key?('error') ? response.parse['error'] : response.body
      flash[:alert] = "Error from API: #{err_message}"
    end

    redirect_to email_path(@email.id)
  end

  private

  def load_email
    response = GoogleSyncinator::APIClient::Emails.new.show(id: params[:email_id]).perform

    if response.status == 404
      render file: "#{Rails.root}/public/404.html",  status: 404
    else
      raw_email = response.parse
      @email = EmailPresenter.new(raw_email)
    end
  end

  def exclusions_model
    OpenStruct.new(email_id: @email.id, creator_uuid: nil, starts_at: DateTime.now, ends_at: nil, reason: nil)
  end
end
