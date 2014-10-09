class ChangeSyncPresenter < ApplicationPresenter
  presents ChangeSync

  def sync_logs
    SyncLogPresenter.map(model.sync_logs)
  end
end
