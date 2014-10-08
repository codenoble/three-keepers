class SyncinatorPresenter < ApplicationPresenter
  presents Syncinator

  def inactive?
    !model.active?
  end

  def queue_count
    @queue_count ||= model.startable_changesets.count
  end
end
