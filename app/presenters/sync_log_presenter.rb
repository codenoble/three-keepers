class SyncLogPresenter < ApplicationPresenter
  include ActionView::Helpers::DateHelper

  presents SyncLog

  def finished_at
    model.errored_at || model.succeeded_at
  end

  def status_class
    if model.errored_at?
      'text-danger'
    elsif model.succeeded_at?
      'text-success'
    else
      'text-info'
    end
  end

  def icon
    if model.errored_at?
      'warning'
    elsif model.succeeded_at?
      'check'
    else
      'clock-o'
    end
  end

  def status
    if model.errored_at?
      'errored'
    elsif model.succeeded_at?
      'succeeded'
    else
      'pending'
    end
  end
end
