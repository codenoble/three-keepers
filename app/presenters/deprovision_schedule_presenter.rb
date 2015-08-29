class DeprovisionSchedulePresenter < ApplicationPresenter
  # Presents an email Hash from the google-syncinator API. Most presenters
  #   present a database object but a hash works fine too.
  presents Hash

  def id
    model['id']
  end

  def action
    model['action']
  end

  def reason
    model['reason']
  end

  def scheduled_for
    DateTime.parse(model['scheduled_for']) if model['scheduled_for'].present?
  end

  def completed_at
    DateTime.parse(model['completed_at']) if model['completed_at'].present?
  end

  def canceled?
    model['canceled'].present?
  end

  def css_classes
    return 'text-muted' if canceled?

    classes = []
    classes << case action
    when /notify/
      'text-info'
    when 'suspend'
      'text-warning'
    when 'delete'
      'text-danger'
    when 'activate'
      'text-success'
    end

    classes << 'pending' if completed_at.blank?

    classes.join(' ')
  end

  def icon_class
    case action
    when /notify/
      'fa-envelope'
    when 'suspend'
      'fa-pause'
    when 'delete'
      'fa-remove'
    when 'activate'
      'fa-check'
    end
  end
end
