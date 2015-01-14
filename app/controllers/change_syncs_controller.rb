class ChangeSyncsController < ApplicationController
  def update
    @changeset = Changeset.find(params[:changeset_id])
    @change_sync = @changeset.change_syncs.find(params[:id])
    sync_log = @change_sync.sync_logs.find_by(:succeeded_at.ne => nil)

    sync_log.message = "#{sync_log.message}\nReran by #{current_user.username} on #{Time.zone.now}.".strip
    @change_sync.run_after = Time.zone.now
    @change_sync.save!

    redirect_to @changeset, notice: "Sucessfully marked to be rerun"
  end
end
