class PeopleController < ApplicationController
  def index
    people = Person.all

    if params[:q]
      begin
        regex = Regexp.new(params[:q].gsub(/\s/, '.*'), Regexp::IGNORECASE)
        ids = Person.collection.aggregate(
          {:$project =>
            {
              uuid: '$uuid',
              display_name: '$display_name',
              title: '$title',
              department: '$department',
              residence: '$residence',
              'emails.address' => '$emails.address',
              'ids.identifier' => '$ids.identifier',
              legal_name: {:$concat => ['$first_name', ' ', '$last_name']},
              full_name: {:$concat => ['$preferred_name', ' ', '$last_name']}
            }
          },
          {:$match => {:$or => [
            {uuid: regex},
            {display_name: regex},
            {title: regex},
            {department: regex},
            {residence: regex},
            {'emails.address' => regex},
            {'ids.identifier' => regex},
            {legal_name: regex},
            {full_name: regex}
          ]}}
        ).map{|p| p[:_id]}

        people = Person.where(:id.in => ids)
      rescue RegexpError
        people = Person.none
      end
    end

    @raw_people = people.asc(:last_name, :preferred_name).page(params[:page])
    @people = PersonPresenter.map(@raw_people)
  end

  def show
    @person = PersonPresenter.find(params[:id])
  end
end
