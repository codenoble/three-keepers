class ChangesetsController < ApplicationController
  def show
    @changeset = ChangesetPresenter.find(params[:id])
  end
end
