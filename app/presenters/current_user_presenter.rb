class CurrentUserPresenter
  ATTR_MAP = {
    first_name:   :eduPersonNickname,
    last_name:    :sn,
    email:        :mail,
    photo_url:    :url,
    affiliations: [:eduPersonAffiliation],
    entitlements: [:eduPersonEntitlement]

  }

  attr_reader :username
  attr_reader *ATTR_MAP.keys

  def initialize(session)
    @session = session

    if session_valid?
      @username = session['cas']['user']

      ATTR_MAP.each do |att, cas_att|
        value = if cas_att.is_a? Array
          extra_attr(cas_att.first)
        else
          extra_attr(cas_att.to_s).first
        end

        instance_variable_set "@#{att}", value
      end
    end
  end

  def name
    [first_name, last_name].compact.join(' ')
  end

  def authenticated?
    !username.nil?
  end

  def authorized?
    # TODO: pull from Settings and make it more flexible
    Array(entitlements).include? 'urn:biola:apps:all:developer'
  end

  private

  attr_reader :session

  def session_valid?
    session.has_key?('cas') && session['cas'].has_key?('user') && session['cas'].has_key?('extra_attributes')
  end

  def extra_attr(key)
    session['cas']['extra_attributes'][key.to_s]
  end
end
