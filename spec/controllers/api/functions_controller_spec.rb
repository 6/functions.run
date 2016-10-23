describe Api::FunctionsController do
  describe "GET #show" do
    let!(:function) { FactoryGirl.create(:function) }

    it "returns OK with function attributes" do
      get :show, params: {id: function.id}
      expect(response).to be_ok
      expect(response_json[:name]).to eq(function.name)
    end
  end

  describe "POST #create" do
    let!(:lambda_create_function) do
      allow(AWS_LAMBDA_CLIENT).to receive(:create_function)
    end
    let(:params) do
      {
        name: "my_function",
        code: "console.log('yo')",
        runtime: "nodejs4.3",
      }
    end
    before(:each) { stub_api_key! }

    context "AWS successfully creates remote function" do
      it "returns OK and creates a Function" do
        expect { post :create, params: params }.to change(Function, :count).by(1)
        expect(response).to be_ok
        expect(response_json[:name]).to eq("my_function")
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

  describe "PUT #update" do
    let(:function) { FactoryGirl.create(:function, name: "old_fn", description: "old", code: "console.log('old')", private: false) }
    before(:each) { stub_api_key!(function.user) }

    context "with only local function params specified" do
      let(:params) do
        {
          id: function.id,
          name: "new_function",
          description: "new",
          private: true,
        }
      end

      it "updates the specified attributes" do
        put :update, params: params
        function.reload
        expect(function.name).to eq("new_function")
        expect(function.description).to eq("new")
        expect(function).to be_private
      end

      it "does not call update_remote_function!" do
        expect_any_instance_of(Function).not_to receive(:update_remote_function!)
        put :update, params: params
      end
    end

    context "with code param specified" do
      let(:code) { "console.log('new')" }
      let(:params) do
        {
          id: function.id,
          code: code,
        }
      end

      it "calls update_remote_function!" do
        expect_any_instance_of(Function).to receive(:update_remote_function!).with(hash_including(code: code))
        put :update, params: params
      end
    end

    context "with configuration params specified" do
      let(:params) do
        {
          id: function.id,
          runtime: "python2.7",
          timeout: 2,
          memory_size: 128,
        }
      end

      it "calls update_remote_function!" do
        expect_any_instance_of(Function).to receive(:update_remote_function!)
          .with(hash_including(runtime: "python2.7", timeout: "2", memory_size: "128"))
        put :update, params: params
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:function) { FactoryGirl.create(:function) }
    let!(:lambda_delete_function) do
      allow(AWS_LAMBDA_CLIENT).to receive(:delete_function)
        .with(function_name: function.remote_id)
    end
    before(:each) { stub_api_key!(function.user) }

    context "AWS successfully deletes remote function" do
      it "returns OK and destroys the local function" do
        delete :destroy, params: {id: function.id}
        expect(response).to be_ok
        expect{ function.reload }.to raise_error(ActiveRecord::RecordNotFound)
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
end
