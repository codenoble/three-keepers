class AccountEmailsController < ApplicationController
  def search
    response = GoogleSyncinator::APIClient::AccountEmails.new.search(q: params[:term]).perform

    addresses = response.parse.map do |account_email|
      {label: account_email['address'], value: account_email['id']}
    end

    render json: addresses.to_json, callback: params[:jsonCallback]
  end
end
