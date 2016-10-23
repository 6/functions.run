describe UsersController do
  describe "GET #new" do
    context "logged out" do
      it "returns OK" do
        get :new
        expect(response).to be_ok
      end
    end

    context "logged in" do
      let!(:current_user) { stub_session! }
      it "redirects to user_path" do
        get :new
        expect(response).to redirect_to(user_path(current_user.username))
      end
    end
  end

  describe "GET #show" do
    shared_examples "viewable" do
      it "returns OK with user details" do
        get :show, params: params
        expect(response).to be_ok
        expect(response.body).to include(user.username)
      end
    end

    shared_examples "not viewable" do
      it "returns 404" do
        get :show, params: params
        expect(response).to be_not_found
      end
    end

    context "for a valid user" do
      let!(:user) { FactoryGirl.create(:user) }
      let(:params) { {username: user.username} }

      context "logged out" do
        it_behaves_like "viewable"
      end

      context "logged in, but not self" do
        before(:each) do
          stub_session!
        end

        it_behaves_like "viewable"
      end

      context "logged in and viewing self" do
        before(:each) do
          stub_session!(user)
        end

        it_behaves_like "viewable"
      end
    end

    context "for an invalid user" do
      let(:params) { {username: "invalid"} }

      it_behaves_like "not viewable"
    end
  end

  describe "POST #create" do
    context "valid params" do
      let(:params) do
        {
          user: {
            username: "peter",
            email: "peter@example.com",
            password: "abcdef",
          },
        }
      end

      it "creates a User" do
        expect { post :create, params: params }.to change(User, :count).by(1)
        user = User.last
        expect(user.username).to eq("peter")
        expect(user.email).to eq("peter@example.com")
        expect(user.authenticate("abcdef")).to be_truthy
      end

      it "redirects to user path" do
        post :create, params: params
        expect(response).to redirect_to(user_path("peter"))
      end
    end

    context "invalid params" do
      let(:params) do
        {
          user: {
            username: "peter",
            email: "peter@example.com",
            password: "",
          },
        }
      end

      it "does not create a User" do
        expect { post :create, params: params }.not_to change(User, :count)
      end
    end
  end
end
