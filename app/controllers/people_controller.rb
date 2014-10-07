class PeopleController < ApplicationController
  def index
    @people = Person.all
    if params[:q]
      begin
        regex = Regexp.new(params[:q].gsub(/\s/, '.*'), Regexp::IGNORECASE)
        @people = @people.any_of(
          {first_name: regex},
          {preferred_name: regex},
          {last_name: regex},
          {display_name: regex},
          {title: regex},
          {department: regex},
          {residence: regex},
          {'emails.address' => regex},
          {'ids.identifier' => regex}
        )
      rescue RegexpError
        @people = Person.none
      end
    end
    @people = @people.asc(:last_name, :preferred_name).page(params[:page]).per(60)
  end

  def show
    @person = Person.find(params[:id])
  end
end
