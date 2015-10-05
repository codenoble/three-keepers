class CacheSyncinatorWorker
  include Sidekiq::Worker

  def perform
    Syncinator.all.each do |syncinator|
      CacheSyncinatorErroredWorker.perform_async syncinator.id.to_s
      CacheSyncinatorPendingWorker.perform_async syncinator.id.to_s
    end
  end
end
