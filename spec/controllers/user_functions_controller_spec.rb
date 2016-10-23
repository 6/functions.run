describe UserFunctionsController do
  describe "GET #show" do
    shared_examples "viewable" do
      it "returns OK with function details" do
        get :show, params: params
        expect(response).to be_ok
        expect(response.body).to include(function.name)
      end
    end

    shared_examples "not viewable" do
      it "returns 404" do
        get :show, params: params
        expect(response).to be_not_found
      end
    end

    let(:params) { {username: function.user.username, function_name: function.name} }

    context "function is public" do
      let!(:function) { FactoryGirl.create(:function, private: false) }

      context "not logged in" do
        it_behaves_like "viewable"
      end

      context "logged in, but not author" do
        before(:each) do
          stub_session!
        end

        it_behaves_like "viewable"
      end

      context "logged in as the author" do
        before(:each) do
          stub_session!(function.user)
        end

        it_behaves_like "viewable"
      end
    end

    context "function is private" do
      let!(:function) { FactoryGirl.create(:function, private: true) }

      context "not logged in" do
        it_behaves_like "not viewable"
      end

      context "logged in, but not author" do
        before(:each) do
          stub_session!
        end

        it_behaves_like "not viewable"
      end

      context "logged in as the author" do
        before(:each) do
          stub_session!(function.user)
        end

        it_behaves_like "viewable"
      end
    end

    context "with unknown user/function name" do
      let(:params) { {username: "invalid", function_name: "invalid"} }

      it_behaves_like "not viewable"
    end
  end
end
