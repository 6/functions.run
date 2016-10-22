describe Function do
  describe "#destroy_remote_and_self!" do
    let(:function) { FactoryGirl.create(:function) }
    let!(:lamda_delete_function) do
      allow(AWS_LAMBDA_CLIENT).to receive(:delete_function)
        .with(function_name: function.remote_id)
    end

    context "successfully deletes remote AWS function" do
      it "destroys local function as well" do
        function.destroy_remote_and_self!
        expect{ function.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "errors when deleting remote AWS function" do
      before(:each) do
        lamda_delete_function.and_raise(StandardError)
      end

      it "does not destroy local function" do
        function.destroy_remote_and_self! rescue nil
        expect(function.reload).to be_present
      end
    end
  end
end
