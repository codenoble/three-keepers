class ChangeSyncPresenter < ApplicationPresenter
  presents ChangeSync

  def sync_logs
    @sync_logs ||= SyncLogPresenter.map(model.sync_logs.desc(:started_at))
  end

  def succeeded?
    sync_logs.any? &:succeeded?
  end
end
