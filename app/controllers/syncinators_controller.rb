class SyncinatorsController < ApplicationController
  def index
    syncinators = Syncinator.all.asc(:name)
    @syncinators = SyncinatorPresenter.map(syncinators)
  end

  def show
    @syncinator = SyncinatorPresenter.find(params[:id])
    @raw_changesets = Changeset.where('change_syncs.syncinator_id' => @syncinator.id).desc(:created_at).page(params[:page])
    @changesets = ChangesetPresenter.map(@raw_changesets)
  end
end
