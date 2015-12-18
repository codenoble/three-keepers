class AccountEmailsController < ApplicationController
  def search
    response = GoogleSyncinator::APIClient::AccountEmails.new.search(q: params[:term]).perform

    addresses = response.parse.map do |account_email|
      if account_email['state'] != 'deleted'
        {label: account_email['address'], value: account_email['id']}
      end
    end.compact

    render json: addresses.to_json, callback: params[:jsonCallback]
  end
end
