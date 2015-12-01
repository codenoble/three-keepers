class PeopleController < ApplicationController
  def index
    people = filter(params[:q])

    @raw_people = people.asc(:last_name, :preferred_name).page(params[:page])
    @people = PersonPresenter.map(@raw_people)
  end

  def show
    @person = PersonPresenter.find(params[:id])
    @changesets = Kaminari.paginate_array(@person.changesets).page(params[:page]).per(Settings.page.per)
  end

  def search
    results = filter(params[:term]).map do |p|
      presenter = PersonPresenter.new(p)

      {label: presenter.name_and_id, value: p.uuid}
    end
    render json: results.to_json, callback: params[:jsonCallback]
  end

  private

  def filter(query)
    return Person.all if query.blank?

    begin
      regex = Regexp.new(query.gsub(/\s/, '.*'), Regexp::IGNORECASE)
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

      Person.where(:id.in => ids)
    rescue RegexpError
      Person.none
    end
  end
end
