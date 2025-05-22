RSpec.describe ManageIQ::Providers::TerraformEnterprise::AutomationManager::OrchestrationStack do
  let(:ems)    { FactoryBot.create(:ems_terraform_enterprise) }
  let(:stack)  { FactoryBot.create(:orchestration_stack_terraform_enterprise, :ext_management_system => ems, :status => status) }
  let(:status) { "pending" }

  describe "#raw_status" do
    it "returns a Status object" do
      expect(stack.raw_status).to be_kind_of(stack.class::Status)
    end

    describe "#reason" do
      let(:status) { "canceled" }

      it "returns a human friendly reason" do
        expect(stack.raw_status.reason).to eq("The run has been canceled.")
      end
    end

    describe "#succeeded?" do
      it "returns falsey" do
        expect(stack.raw_status.succeeded?).to be_falsey
      end

      context "with a successful status" do
        let(:status) { "planned_and_finished" }

        it "returns truthy" do
          expect(stack.raw_status.succeeded?).to be_truthy
        end
      end
    end

    describe "#failed?" do
      it "returns falsey" do
        expect(stack.raw_status.failed?).to be_falsey
      end

      context "with a failed state" do
        let(:status) { "errored" }

        it "returns truthy" do
          expect(stack.raw_status.failed?).to be_truthy
        end
      end
    end

    describe "#canceled?" do
      it "returns falsey" do
        expect(stack.raw_status.canceled?).to be_falsey
      end

      context "with a canceled state" do
        let(:status) { "force_canceled" }

        it "returns truthy" do
          expect(stack.raw_status.canceled?).to be_truthy
        end
      end
    end
  end

  describe "#refresh_ems" do
    # Authentications are required for the queue_refresh to succeed
    let(:ems) { FactoryBot.create(:ems_terraform_enterprise_with_vcr_authentication) }

    it "queues a refresh of the orchestration_stack" do
      stack.refresh_ems

      expect(MiqQueue.count).to eq(1)
      expect(MiqQueue.first).to have_attributes(
        :class_name  => "EmsRefresh",
        :method_name => "refresh",
        :data        => [[ems.class.name, ems.id]]
      )
    end
  end
end
