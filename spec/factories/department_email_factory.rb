FactoryGirl.define do
  factory :department_email_hash, class: Hash do
    _type { 'DepartmentEmail' }
    id { Faker::Number.number(10) }
    address { Faker::Internet.email }
    first_name { Faker::Company.name.split(/[^a-zA-Z]/).first }
    last_name { Faker::Company.name.split(/[^a-zA-Z]/).last }
    department { Faker::Commerce.department }
    title { Faker::Team.name }
    privacy { false }
    org_unit_path { '/' }
    state { :active }
    uuids { [create(:person).uuid] }
    deprovision_schedules { [] }
    exclusions { [] }

    initialize_with { attributes.stringify_keys }
  end
end
