FactoryBot.define do
  factory :configuration_script_terraform_enterprise,
          :class  => "ManageIQ::Providers::TerraformEnterprise::AutomationManager::ConfigurationScript",
          :parent => :configuration_script_base
end
