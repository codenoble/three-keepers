class SyncinatorPresenter < ApplicationPresenter
  presents Syncinator

  def inactive?
    !model.active?
  end

  def queue_count
    @queue_count ||= model.unfinished_changesets.count
  end
end
