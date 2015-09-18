class SyncinatorsController < ApplicationController
  def index
    syncinators = Syncinator.all.asc(:name)
    @active_queued_syncinators = SyncinatorPresenter.map(syncinators.where(active: true, queue_changes: true))
    @active_syncinators = SyncinatorPresenter.map(syncinators.where(active: true, queue_changes: false))
    @disabled_syncinators = SyncinatorPresenter.map(syncinators.where(active: false))
  end

  def show
    @syncinator = SyncinatorPresenter.find(params[:id])
    @raw_changesets = if params[:unfinished]
      @syncinator.unfinished_changesets
    elsif params[:errored]
      @syncinator.errored_changesets
    elsif params[:pending]
      @syncinator.pending_changesets
    else
      @syncinator.changesets.desc(:created_at)
    end
    @raw_changesets = @raw_changesets.page(params[:page])
    @changesets = ChangesetPresenter.map(@raw_changesets)
  end
end
