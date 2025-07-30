FactoryBot.define do
  factory :miq_provision_terraform_enterprise, :parent => :miq_provision, :class => "ManageIQ::Providers::TerraformEnterprise::AutomationManager::Provision"
end
