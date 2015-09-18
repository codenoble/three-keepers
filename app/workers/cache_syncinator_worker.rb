class CacheSyncinatorWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly.minute_of_hour(0, 5, 30, 45) }

  def perform
    Syncinator.all.each do |syncinator|
      CacheSyncinatorErroredWorker.perform_async syncinator.id.to_s
      CacheSyncinatorPendingWorker.perform_async syncinator.id.to_s
    end
  end
end
