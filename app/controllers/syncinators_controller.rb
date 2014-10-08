class SyncinatorsController < ApplicationController
  def index
    @syncinators = Syncinator.all.asc(:name)
  end

  def show
    @syncinator = Syncinator.find(params[:id])
    @changesets = Changeset.where('change_syncs.syncinator_id' => @syncinator.id).desc(:created_at).page(params[:page])
  end
end
