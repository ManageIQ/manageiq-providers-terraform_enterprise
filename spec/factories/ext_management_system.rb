FactoryBot.define do
  factory :ems_terraform_enterprise,
  :aliases => ["manageiq/providers/terraform_enterprise/automation_manager"],
  :class   => "ManageIQ::Providers::TerraformEnterprise::AutomationManager",
  :parent  => :automation_manager
end
