FactoryGirl.define do
  factory :function do
    user
    sequence(:name) { |n| "function_#{n}" }
    runtime "nodejs4.3"
    code "console.log('hello');"
  end
end
