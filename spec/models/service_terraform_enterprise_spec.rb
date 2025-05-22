RSpec.describe ServiceTerraformEnterprise do
  let(:terraform_enterprise) { FactoryBot.create(:ems_terraform_enterprise) }
  let(:configuration_script) { FactoryBot.create(:configuration_script_terraform_enterprise, :manager => terraform_enterprise) }
  let(:service_template)     { FactoryBot.create(:service_template_terraform_enterprise, :name => "Terraform Enterprise").tap { |s| s.service_resources.create(:resource => configuration_script)} }
  let(:service)              { FactoryBot.create(:service_terraform_enterprise, :service_template => service_template, :name => "Terraform Enterprise").tap { |s| s.service_resources.create(:resource => configuration_script)} }

  describe "#launch_stack" do
    let(:tf_run_id) { "run-abcd" }

    before do
      allow(terraform_enterprise.class::OrchestrationStack).to receive(:raw_create_stack).and_return(tf_run_id)
    end

    it "creates an OrchestrationStack" do
      stack = service.launch_stack

      expect(stack).to have_attributes(
        :type                  => terraform_enterprise.class::OrchestrationStack.name,
        :ext_management_system => terraform_enterprise,
        :ems_ref               => tf_run_id,
        :configuration_script  => configuration_script
      )
    end

    it "Adds the OrchestrationStack to the service's ServiceResources" do
      stack = service.launch_stack
      expect(service.reload.stack).to eq(stack)
    end
  end
end
