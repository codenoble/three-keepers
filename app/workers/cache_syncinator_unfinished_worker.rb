class CacheSyncinatorUnfinishedWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly.minute_of_hour(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55) }

  def perform
    Syncinator.all.each do |syncinator|
      syncinator.update unfinished_count: syncinator.unfinished_changesets.count
    end
  end
end
