FactoryGirl.define do
  factory :invocation_response, class: OpenStruct do
    skip_create
    
    status_code 200
    function_error nil
    log_result "U1RBUlQgUmVxdWVzdElkOiBkM2RhMGM1Zi05ODY1LTExZTYtYWU0Yy04M2Q3ZjZmZGNhNjQgVmVyc2lvbjogJExBVEVTVApFTkQgUmVxdWVzdElkOiBkM2RhMGM1Zi05ODY1LTExZTYtYWU0Yy04M2Q3ZjZmZGNhNjQKUkVQT1JUIFJlcXVlc3RJZDogZDNkYTBjNWYtOTg2NS0xMWU2LWFlNGMtODNkN2Y2ZmRjYTY0CUR1cmF0aW9uOiAwLjE3IG1zCUJpbGxlZCBEdXJhdGlvbjogMTAwIG1zIAlNZW1vcnkgU2l6ZTogMTI4IE1CCU1heCBNZW1vcnkgVXNlZDogMjggTUIJCg=="
    payload { StringIO.new("some response string") }
  end
end
