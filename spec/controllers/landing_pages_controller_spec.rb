describe LandingPagesController do
  describe "GET #show" do
    context "logged out" do
      it "return 200 OK" do
        get :show
        expect(response).to be_ok
        expect(response.body).to include("functions")
      end
    end

    context "logged in" do
      let!(:current_user) { stub_session! }

      it "redirects to user path" do
        get :show
        expect(response).to redirect_to(user_path(current_user.username))
      end
    end
  end
end
