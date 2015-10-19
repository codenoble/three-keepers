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
    if raw_email.nil?
      render file: "#{Rails.root}/public/404.html",  status: 404
    else
      @email = PersonEmailPresenter.new(raw_email)
      other_emails_response = GoogleSyncinator::APIClient::Emails.new.index(q: @email.address).perform
      raw_other_emails = other_emails_response.parse.reject do |eml|
        eml['uuid'] == raw_email['uuid']
      end
      @other_emails = EmailPresenter.map(raw_other_emails)
    end
  end

  def new
    @form = PersonEmailForm.new(new_email_model)
  end

  def create
    @form = PersonEmailForm.new(new_email_model)

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

  def edit
    @email = PersonEmailPresenter.new(raw_email)
    @form = UpdatePersonEmailForm.new(update_email_model(@email.address))
  end

  def update
    @form = UpdatePersonEmailForm.new(update_email_model)

    if @form.validate(params[:update_person_email])
      response = GoogleSyncinator::APIClient::PersonEmails.new.update(id: params[:id], address: @form.address).perform

      handle_response(response, email_id_param: 'id', failure_action: :edit)
    else
      flash.now[:alert] = @form.errors.full_messages.join('. ') + '.'
      render :edit
    end
  end

  private

  def new_email_model
    OpenStruct.new(uuid: nil, address: nil)
  end

  def update_email_model(address = nil)
    OpenStruct.new(address: address)
  end

  def raw_email
    @raw_email ||= (
      response = GoogleSyncinator::APIClient::PersonEmails.new.show(id: params[:id]).perform

      if response.status != 404
        response.parse
      end
    )
  end
end
