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
end
