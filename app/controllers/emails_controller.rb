class EmailsController < ApplicationController
  include EmailAPI

  def index
    page = params[:page] || 1

    # TODO: handle searching
    # TODO: handle pagination
    @raw_emails = GoogleSyncinator::APIClient::Emails.new.index(page: page).perform.parse
    @emails = EmailPresenter.map(@raw_emails)
  end

  def show
    response = GoogleSyncinator::APIClient::Emails.new.show(id: params[:id]).perform

    if response.status == 404
      render file: "#{Rails.root}/public/404.html",  status: 404
    else
      raw_email = response.parse
      @email = EmailPresenter.new(raw_email)
      other_emails_response = GoogleSyncinator::APIClient::Emails.new.index(q: @email.address).perform
      raw_other_emails = other_emails_response.parse.reject do |eml|
        eml['uuid'] == raw_email['uuid']
      end
      @other_emails = EmailPresenter.map(raw_other_emails)
    end
  end

  def new
    @form = EmailForm.new(email_model)
  end

  def create
    @form = EmailForm.new(email_model)

    if @form.validate(params[:email])
      @form.save do |hash|
        response = GoogleSyncinator::APIClient::Emails.new.create(params[:email]).perform

        handle_response(response, email_id_param: 'id')
      end
    else
      flash.now[:alert] = @form.errors.full_messages.join('. ') + '.'
      render :new
    end
  end

  private

  def email_model
    OpenStruct.new(uuid: nil, address: nil, primary: false)
  end
end
