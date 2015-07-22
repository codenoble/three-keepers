class ChangesetPresenter < ApplicationPresenter
  include ActionView::Helpers::DateHelper

  Status = Struct.new(:status, :weight, :message) do
    alias :to_s :message
  end

  presents Changeset

  def person
    PersonPresenter.new(model.person)
  end

  def change_syncs
    ChangeSyncPresenter.map(model.change_syncs)
  end

  def title
    "#{model.action.titleize} #{model.scope} record for #{person.name}"
  end

  def created_at_s
    model.created_at.to_formatted_s(:shortish)
  end

  def scoped_action
    [model.action, model.scope].join(' ').strip
  end

  def status
    statuses = model.change_syncs.map do |change_sync|
      sync_log_status(change_sync.sync_logs.last)
    end

    statuses.sort_by(&:weight).first
  end

  def status_for(syncinator)
    change_sync = model.change_syncs.find_by(syncinator_id: syncinator.id)
    sync_log_status(change_sync.sync_logs.last)
  end

  private

  def sync_log_status(sync_log)
    if sync_log.nil?
      Status.new(:unsynced, 2, 'unsynced')
    elsif sync_log.errored_at?
      Status.new(:error, 1, "error: #{sync_log.message}")
    elsif sync_log.action ==:destroy
      Status.new(:deleted, 4, 'deleted')
    elsif sync_log.succeeded_at?
      options = {'create' => 5, 'update' => 6, 'skip' => 7}
      Status.new(:success, options[sync_log.action.to_s], sync_log.action.to_s)
    else
      Status.new(:started, 3, "sync started #{time_ago_in_words(sync_log.started_at)} ago")
    end
  end
end
