class PeopleController < ApplicationController
  def index
    @people = Person.all.asc(:last_name, :preferred_name).page(params[:page]).per(60)
  end

  def show
    @person = Person.find(params[:id])
  end
end
