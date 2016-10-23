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

  describe "GET #new" do
    context "logged in" do
      before(:each) { stub_session! }

      it "returns OK" do
        get :new
        expect(response).to be_ok
      end
    end

    context "logged out" do
      it "redirects to login page" do
        get :new
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "POST #create" do
    let!(:lambda_create_function) do
      allow(AWS_LAMBDA_CLIENT).to receive(:create_function)
    end
    let(:params) do
      {
        function: {
          name: "my_function",
          runtime: "nodejs4.3",
        }
      }
    end

    context "logged in" do
      before(:each) { stub_session! }

      context "AWS successfully creates remote function" do
        it "returns OK and creates a Function" do
          expect { post :create, params: params }.to change(Function, :count).by(1)
          function = Function.last
          expect(response).to redirect_to(user_function_path(function.user.username, function.name))
        end
      end

      context "AWS errors when creating remote function" do
        before(:each) do
          lambda_create_function.and_raise(RuntimeError)
        end

        it "returns 500 and does not create a Function" do
          expect { post :create, params: params }.not_to change(Function, :count)
          expect(response.status).to eq(500)
        end
      end
    end

    context "logged out" do
      it "redirects to login" do
        post :create, params: params
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "GET #edit" do
    let!(:function) { FactoryGirl.create(:function) }
    let(:params) { {id: function.id} }

    context "logged in as the author" do
      before(:each) { stub_session!(function.user) }

      it "returns OK" do
        get :edit, params: params
        expect(response).to be_ok
      end
    end

    context "logged in, but not author" do
      before(:each) { stub_session! }

      it "returns 404" do
        get :edit, params: params
        expect(response).to be_not_found
      end
    end

    context "logged out" do
      it "redirects to login page" do
        get :edit, params: params
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "PUT #update" do
    let!(:function) { FactoryGirl.create(:function, name: "old_name") }

    context "user is authorized, valid params" do
      let(:params) do
        {
          id: function.id,
          function: {
            name: "new_name",
          }
        }
      end
      before(:each) { stub_session!(function.user) }

      it "redirects and updates" do
        put :update, params: params
        function.reload
        expect(response).to redirect_to(user_function_path(function.user.username, function.name))
        expect(function.name).to eq("new_name")
      end
    end

    context "user is authorized, invalid params" do
      let(:params) do
        {
          id: function.id,
          function: {
            name: "",
          }
        }
      end
      before(:each) { stub_session!(function.user) }

      it "does not update, returns 200" do
        put :update, params: params
        expect(response).to be_ok
        expect(function.reload.name).to eq("old_name")
      end
    end

    context "user is unauthorized" do
      let(:params) do
        {
          id: function.id,
          function: {
            name: "new_name",
          }
        }
      end
      before(:each) { stub_session! }

      it "returns 404 and does not update" do
        put :update, params: params
        expect(response).to be_not_found
        expect(function.reload.name).to eq("old_name")
      end
    end

    context "logged out" do
      let(:params) do
        {
          id: function.id,
          function: {
            name: "new_name",
          }
        }
      end

      it "redirects to login page" do
        put :update, params: params
        expect(response).to redirect_to(new_session_path)
      end
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
