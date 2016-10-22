FactoryGirl.define do
  factory :function do
    name "validate-credit-card-format"
    runtime "nodejs"
    code "console.log('hello');"
  end
end
