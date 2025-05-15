RSpec.describe ManageIQ::Providers::TerraformEnterprise::AutomationManager::OrchestrationStack do
  let(:stack) { FactoryBot.create(:orchestration_stack_terraform_enterprise, :ext_management_system => terraform_enterprise) }

  describe "#raw_status" do
  end

  describe "#refresh_ems" do
  end
end
