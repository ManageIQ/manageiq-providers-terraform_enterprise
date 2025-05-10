FactoryBot.define do
  factory :terraform_enterprise_workspace,
          :class  => "ManageIQ::Providers::TerraformEnterprise::AutomationManager::ConfigurationScriptPayload",
          :parent => :configuration_script_payload
end
