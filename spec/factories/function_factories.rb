FactoryGirl.define do
  factory :function do
    name "validate_credit_card_format"
    runtime "nodejs4.3"
    code "console.log('hello');"
  end
end
