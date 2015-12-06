class DepartmentEmailPresenter < ApplicationPresenter
  # Presents a department email Hash from the google-syncinator API. Most
  # presenters present a database object but a hash works fine too.
  presents Hash

  [:id, :address, :first_name, :last_name, :department, :title, :privacy, :org_unit_path, :state].each do |attrib|
    define_method(attrib) do
      model[attrib.to_s]
    end
  end
  alias :to_s :address

  def people
    @people ||= PersonPresenter.map(person_models)
  end

  def deprovision_schedules
    @deprovision_schedules ||= DeprovisionSchedulePresenter.map(model['deprovision_schedules'].to_a)
  end

  def exclusions
    @exclusions ||= ExclusionPresenter.map(model['exclusions'].to_a)
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

  def person_models
    @person_models = Array(model['uuids']).map { |uuid| Person.find_by(uuid: uuid) }
  end
end
