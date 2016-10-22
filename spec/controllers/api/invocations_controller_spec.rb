describe Api::InvocationsController do
  describe "POST #create" do
    let(:function) { FactoryGirl.create(:function) }
    let!(:lambda_invoke) do
      allow(AWS_LAMBDA_CLIENT).to receive(:invoke)
    end
    let(:params) do
      {
        function_id: function.id,
        payload: '{"some-input": 123}',
      }
    end

    context "AWS successfully invokes function" do
      let(:invocation_response) { FactoryGirl.build(:invocation_response) }
      before(:each) do
        lambda_invoke.and_return(invocation_response)
      end

      it "returns 200 with invocation details" do
        post :create, params: params
        expect(response).to be_ok
        expect(response_json[:log_result]).to eq(invocation_response.log_result)
        expect(response_json[:error]).to eq(invocation_response.function_error)
        expect(response_json[:payload]).to eq(invocation_response.payload.string)
      end
    end

    context "AWS errors when invoking function" do
      before(:each) do
        lambda_invoke.and_raise(RuntimeError)
      end

      it "returns 500" do
        post :create, params: params
        expect(response.status).to eq(500)
      end
    end
  end
end
