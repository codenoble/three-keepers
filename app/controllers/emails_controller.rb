class EmailsController < ApplicationController
  include SearchEmail
  include EmailAPI

  def index
    args = params.slice(:page, :q).to_h.reject { |k,v| v.blank? }

    response = GoogleSyncinator::APIClient::Emails.new.index(args).perform
    @raw_emails = prep_for_kaminari(response)
    @emails = EmailPresenter.map(@raw_emails)
  end
end
