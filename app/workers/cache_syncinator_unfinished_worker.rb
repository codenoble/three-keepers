class CacheSyncinatorUnfinishedWorker
  include Sidekiq::Worker

  def perform
    Syncinator.all.each do |syncinator|
      syncinator.update unfinished_count: syncinator.unfinished_changesets.count
    end
  end
end
