FactoryGirl.define do
  factory :alias_email_hash, class: Hash do
    _type { 'AliasEmail' }
    id { Faker::Number.number(10) }
    address { Faker::Internet.email }
    state { :active }
    account_email_id { build(:person_email_hash)['id'] }

    initialize_with { attributes.stringify_keys }
  end
end
