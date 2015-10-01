class AliasEmailsController < ApplicationController
  include SearchEmail
  include EmailAPI

  def show
    response = GoogleSyncinator::APIClient::AliasEmails.new.show(id: params[:id]).perform

    if response.status == 404
      render file: "#{Rails.root}/public/404.html",  status: 404
    else
      raw_email = response.parse
      @email = AliasEmailPresenter.new(raw_email)
      other_emails_response = GoogleSyncinator::APIClient::Emails.new.index(q: @email.address).perform
      raw_other_emails = other_emails_response.parse.reject do |eml|
        eml['uuid'] == raw_email['uuid']
      end
      @other_emails = EmailPresenter.map(raw_other_emails)
    end
  end

  def new
    @form = AliasEmailForm.new(email_model)
  end

  def create
    @form = AliasEmailForm.new(email_model)

    if @form.validate(params[:alias_email])
      @form.save do |hash|
        response = GoogleSyncinator::APIClient::AliasEmails.new.create(params[:alias_email]).perform

        handle_response(response, email_id_param: 'id', route: :alias_email)
      end
    else
      flash.now[:alert] = @form.errors.full_messages.join('. ') + '.'
      render :new
    end
  end

  private

  def email_model
    OpenStruct.new(account_email_id: nil, address: nil)
  end
end
