FactoryGirl.define do
  factory :email_hash, class: Hash do
    id { Faker::Number.number(10) }
    sequence(:uuid) { |n| create(:person).uuid }
    address { Faker::Internet.email }
    primary { true }
    state { :active }
    deprovision_schedules { [] }
    exclusions { [] }

    initialize_with { attributes.stringify_keys }
  end
end
