describe Api::InvocationsController do
  describe "POST #create" do
    let!(:lambda_invoke) do
      allow(AWS_LAMBDA_CLIENT).to receive(:invoke)
    end
    let(:params) do
      {
        function_id: function.id,
        payload: '{"some-input": 123}',
      }
    end

    shared_examples "authorized" do
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

    shared_examples "unauthorized" do
      it "returns 404" do
        post :create, params: params
        expect(response.status).to eq(404)
      end
    end

    context "logged in as author of public function" do
      let(:function) { FactoryGirl.create(:function, private: false) }
      before(:each) do
        stub_api_key!(function.user)
      end

      it_behaves_like "authorized"
    end

    context "logged in as author of private function" do
      let(:function) { FactoryGirl.create(:function, private: true) }
      before(:each) do
        stub_api_key!(function.user)
      end

      it_behaves_like "authorized"
    end

    context "logged in, function is public but not author" do
      let(:function) { FactoryGirl.create(:function, private: false) }
      before(:each) do
        stub_api_key!
      end

      it_behaves_like "authorized"
    end

    context "not logged in, but function is public" do
      let(:function) { FactoryGirl.create(:function, private: false) }

      it_behaves_like "authorized"
    end

    context "not logged in, function is private" do
      let(:function) { FactoryGirl.create(:function, private: true) }

      it_behaves_like "unauthorized"
    end

    context "logged in but not author of private function" do
      let(:function) { FactoryGirl.create(:function, private: true) }
      before(:each) { stub_api_key! }

      it_behaves_like "unauthorized"
    end
  end
end
