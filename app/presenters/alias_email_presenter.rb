class AliasEmailPresenter < ApplicationPresenter
  # Presents an alias email Hash from the google-syncinator API. Most presenters
  #   present a database object but a hash works fine too.
  presents Hash

  def id
    model['id']
  end

  def address
    model['address']
  end
  alias :to_s :address

  def person_email
    @person_email ||= PersonEmailPresenter.new(person_email_hash)
  end

  def state
    model['state']
  end

  def css_classes
    case state
    when 'active'
      'text-success'
    when 'suspended'
      'text-warning'
    when 'deleted'
      'text-danger'
    end
  end

  # Font Awesome CSS class
  def icon_class
    case state
    when 'active'
      'fa-check'
    when 'suspended'
      'fa-pause'
    when 'deleted'
      'fa-remove'
    end
  end

  private

  def person_email_hash
    @person_email_hash ||= GoogleSyncinator::APIClient::PersonEmails.new.show(id: model['account_email_id'].to_s).perform.parse
  end
end
