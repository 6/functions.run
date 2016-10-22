FactoryGirl.define do
  factory :function do
    name "validate-credit-card-format"
    runtime "nodejs4.3"
    code "console.log('hello');"
  end
end
