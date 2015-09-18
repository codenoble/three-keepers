class CacheSyncinatorPendingWorker
  include Sidekiq::Worker

  def perform(syncinator_id)
    syncinator = Syncinator.find(syncinator_id)
    syncinator.update pending_count: syncinator.pending_changesets.count
  end
end
