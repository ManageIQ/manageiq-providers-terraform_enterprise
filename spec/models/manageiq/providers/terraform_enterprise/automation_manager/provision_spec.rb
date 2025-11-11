describe ManageIQ::Providers::TerraformEnterprise::AutomationManager::Provision do
  let(:admin)        { FactoryBot.create(:user_admin) }
  let(:zone)         { EvmSpecHelper.local_miq_server.zone }
  let(:ems)          { FactoryBot.create(:ems_terraform_enterprise, :zone => zone).tap { |ems| ems.authentications << FactoryBot.create(:authentication, :status => "Valid", :auth_key => "abcd") } }
  let(:workspace)    { FactoryBot.create(:configuration_script_terraform_enterprise, :manager => ems) }
  let(:miq_request)  { FactoryBot.create(:miq_provision_request, :requester => admin, :source => workspace)}
  let(:options)      { {:source => [workspace.id, workspace.name]} }
  let(:new_stack)    { FactoryBot.create(:orchestration_stack_terraform_enterprise, :ext_management_system => ems, :status => stack_status) }
  let(:stack_status) { "pending" }
  let(:phase)        { nil }
  let(:subject)     do
    FactoryBot.create(
      :miq_provision_terraform_enterprise,
      :userid       => admin.userid,
      :miq_request  => miq_request,
      :source       => workspace,
      :request_type => 'template',
      :state        => 'pending',
      :status       => 'Ok',
      :options      => options,
      :phase        => phase
    )
  end

  it ".my_role" do
    expect(subject.my_role).to eq("ems_operations")
  end

  it ".my_queue_name" do
    expect(subject.my_queue_name).to eq(ems.queue_name_for_ems_operations)
  end

  describe ".run_provision" do
    before do
      allow(described_class.module_parent::OrchestrationStack).to receive(:create_stack).with(workspace).and_return(new_stack)
    end

    it "calls create_stack" do
      expect(described_class.module_parent::OrchestrationStack).to receive(:create_stack)

      subject.run_provision
    end

    it "sets stack_id" do
      subject.run_provision

      expect(subject.reload.phase_context).to include(:stack_id => new_stack.id)
    end

    it "queues check_provisioned" do
      subject.instance_variable_set(:@stack, new_stack)
      allow(new_stack).to receive(:provider_object).and_return({"attributes" => {"status" => "planning"}})

      subject.run_provision

      expect(subject.reload.phase).to eq("check_provisioned")
    end

    context "when create_stack fails" do
      before do
        expect(described_class.module_parent::OrchestrationStack).to receive(:create_stack).and_raise
      end

      it "marks the job as failed" do
        subject.run_provision

        expect(subject.reload).to have_attributes(:state => "finished", :status => "Error")
      end
    end
  end

  describe "check_provisioned" do
    let(:phase) { "check_provisioned" }

    before do
      allow(new_stack).to receive(:provider_object).and_return({"attributes" => {"status" => stack_status}})
      subject.instance_variable_set(:@stack, new_stack)
      subject.phase_context[:stack_id] = new_stack.id
    end

    context "when the plan is still running" do
      let(:stack_status) { "planning" }

      it "requeues check_provisioned" do
        subject.check_provisioned

        expect(subject.reload).to have_attributes(
          :phase  => "check_provisioned",
          :state  => "pending",
          :status => "Ok"
        )
      end
    end

    context "when the plan is finished" do
      let(:stack_status) { "planned_and_finished" }

      it "finishes the job" do
        subject.check_provisioned

        expect(subject.reload).to have_attributes(
          :phase  => "finish",
          :state  => "finished",
          :status => "Ok"
        )
      end
    end

    context "when the plan is errored" do
      let(:stack_status) { "errored" }

      it "finishes the job" do
        subject.phase_context[:stack_id] = new_stack.id
        subject.check_provisioned

        expect(subject.reload).to have_attributes(
          :phase  => "finish",
          :state  => "finished",
          :status => "Error"
        )
      end
    end
  end
end
