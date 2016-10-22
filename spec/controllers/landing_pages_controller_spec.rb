describe LandingPagesController do
  describe "GET #show" do
    it "return 200 OK" do
      get :show
      expect(response).to be_ok
      expect(response.body).to include("functions")
    end
  end
end
