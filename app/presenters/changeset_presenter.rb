class ChangesetPresenter < ApplicationPresenter
  include ActionView::Helpers::DateHelper
  presents Changeset

  def person
    PersonPresenter.new(model.person)
  end

  def created_at_date
    model.created_at.to_date
  end

  def scoped_action
    [model.action, model.scope].join(' ').strip
  end

  def status_for(syncinator)
    sync_log = model.change_syncs.find_by(syncinator_id: syncinator.id).sync_logs.last

    if sync_log.nil?
      'unsynced'
    elsif sync_log.errored_at?
      "error: #{sync_log.message}"
    elsif sync_log.succeeded_at?
      sync_log.action
    else
      "sync started #{time_ago_in_words(sync_log.started_at)} ago"
    end
  end
end
