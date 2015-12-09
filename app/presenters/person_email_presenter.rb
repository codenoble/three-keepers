class PersonEmailPresenter < ApplicationPresenter
  # Presents a person email Hash from the google-syncinator API. Most presenters
  #   present a database object but a hash works fine too.
  presents Hash

  def id
    model['id']
  end

  def address
    model['address']
  end
  alias :to_s :address

  def person
    @person ||= PersonPresenter.new(person_model) if person_model.present?
  end

  def state
    model['state']
  end

  def deprovision_schedules
    @deprovision_schedules ||= DeprovisionSchedulePresenter.map(model['deprovision_schedules'].to_a)
  end

  def exclusions
    @exclusions ||= ExclusionPresenter.map(model['exclusions'].to_a)
  end

  def alias_emails
    @alias_emails ||= AliasEmailPresenter.map(model['alias_emails'].to_a)
  end

  def exclusion_summary
    [].tap { |summaries|
      {past?: 'passed', current?: 'active', future?: 'upcoming'}.each do |meth, adj|
        if (count = exclusions.select(&meth).length) > 0
          summaries << %{<span class="#{adj}">#{count} #{adj}</span>}
        end
      end
    }.join(', ').html_safe
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

  def uuid
    model['uuid']
  end

  def person_model
    @person_model ||= Person.where(uuid: uuid).first if uuid.present?
  end
end
