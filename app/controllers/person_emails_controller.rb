class PersonEmailsController < ApplicationController
  include SearchEmail
  include EmailAPI

  def search
    response = GoogleSyncinator::APIClient::Emails.new.index(q: params[:term]).perform

    addresses = response.parse.each_with_object([]) do |pe, addrs|
      if pe['_type'] == 'PersonEmail'
        addrs << {label: pe['address'], value: pe['id']}
      end
    end
    render json: addresses.to_json, callback: params[:jsonCallback]
  end

  def show
    response = GoogleSyncinator::APIClient::PersonEmails.new.show(id: params[:id]).perform

    if response.status == 404
      render file: "#{Rails.root}/public/404.html",  status: 404
    else
      raw_email = response.parse
      @email = PersonEmailPresenter.new(raw_email)
      other_emails_response = GoogleSyncinator::APIClient::Emails.new.index(q: @email.address).perform
      raw_other_emails = other_emails_response.parse.reject do |eml|
        eml['uuid'] == raw_email['uuid']
      end
      @other_emails = EmailPresenter.map(raw_other_emails)
    end
  end

  def new
    @form = PersonEmailForm.new(email_model)
  end

  def create
    @form = PersonEmailForm.new(email_model)

    if @form.validate(params[:person_email])
      @form.save do |hash|
        response = GoogleSyncinator::APIClient::PersonEmails.new.create(params[:person_email]).perform

        handle_response(response, email_id_param: 'id')
      end
    else
      flash.now[:alert] = @form.errors.full_messages.join('. ') + '.'
      render :new
    end
  end

  private

  def email_model
    OpenStruct.new(uuid: nil, address: nil)
  end
end
