describe FunctionsController do
  describe "GET #index" do
    shared_examples "lists functions" do
      let!(:public_function) { FactoryGirl.create(:function, private: false) }
      let!(:private_function) { FactoryGirl.create(:function, private: true) }

      it "returns OK and lists public functions only" do
        get :index
        expect(response).to be_ok
        expect(response.body).to include(public_function.name)
        expect(response.body).not_to include(private_function.name)
      end
    end

    context "logged out" do
      it_behaves_like "lists functions"
    end

    context "logged in" do
      before(:each) { stub_session! }

      it_behaves_like "lists functions"
    end
  end

  describe "DELETE #destroy" do
    let!(:function) { FactoryGirl.create(:function) }
    let!(:lambda_delete_function) do
      allow(AWS_LAMBDA_CLIENT).to receive(:delete_function)
        .with(function_name: function.remote_id)
    end

    context "user is authorized" do
      before(:each) { stub_session!(function.user) }

      context "AWS successfully deletes remote function" do
        it "destroys the local function" do
          delete :destroy, params: {id: function.id}
          expect{ function.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "redirects to user" do
          delete :destroy, params: {id: function.id}
          expect(response).to redirect_to user_path(function.user.username)
        end
      end

      context "AWS errors when deleting remote function" do
        before(:each) do
          lambda_delete_function.and_raise(RuntimeError)
        end

        it "returns 500 and does not destroy local function" do
          expect { delete :destroy, params: {id: function.id} }.not_to change(Function, :count)
          expect(response.status).to eq(500)
        end
      end
    end

    context "not logged in" do
      it "does not destroy function" do
        expect { delete :destroy, params: {id: function.id} }.not_to change(Function, :count)
      end
    end

    context "logged in but not function author" do
      before(:each) { stub_session! }

      it "does not destroy function" do
        expect { delete :destroy, params: {id: function.id} }.not_to change(Function, :count)
      end
    end
  end
end
