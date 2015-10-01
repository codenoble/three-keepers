FactoryGirl.define do
  factory :person_email_hash, class: Hash do
    _type { 'PersonEmail' }
    id { Faker::Number.number(10) }
    sequence(:uuid) { |n| create(:person).uuid }
    address { Faker::Internet.email }
    state { :active }
    deprovision_schedules { [] }
    exclusions { [] }

    initialize_with { attributes.stringify_keys }
  end
end
