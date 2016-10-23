describe SessionsController do
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

  describe "POST #create" do
    context "valid params with username" do
      let!(:user) { FactoryGirl.create(:user, password: "abcdef") }
      let(:params) do
        {
          email_or_username: user.username,
          password: "abcdef",
        }
      end

      it "logs in the user" do
        expect(session[:user_id]).to be_nil
        post :create, params: params
        expect(session[:user_id]).to eq(user.id)
      end

      it "redirects to user path" do
        post :create, params: params
        expect(response).to redirect_to(user_path(user.username))
      end
    end

    context "valid params with email" do
      let!(:user) { FactoryGirl.create(:user, password: "abcdef") }
      let(:params) do
        {
          email_or_username: user.email,
          password: "abcdef",
        }
      end

      it "logs in the user" do
        expect(session[:user_id]).to be_nil
        post :create, params: params
        expect(session[:user_id]).to eq(user.id)
      end

      it "redirects to user path" do
        post :create, params: params
        expect(response).to redirect_to(user_path(user.username))
      end
    end

    context "invalid params" do
      let(:params) do
        {
          email_or_username: "invalid",
          password: "abcdef",
        }
      end

      it "does not log in the user" do
        expect(session[:user_id]).to be_nil
        post :create, params: params
        expect(session[:user_id]).to be_nil
      end
    end
  end
end
