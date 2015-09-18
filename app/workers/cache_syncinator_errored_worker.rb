class CacheSyncinatorErroredWorker
  include Sidekiq::Worker

  def perform(syncinator_id)
    syncinator = Syncinator.find(syncinator_id)
    syncinator.update errored_count: syncinator.errored_changesets.count
  end
end
