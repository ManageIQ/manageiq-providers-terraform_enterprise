FactoryBot.define do
  factory :ems_terraform_enterprise,
          :aliases => ["manageiq/providers/terraform_enterprise/automation_manager"],
          :class   => "ManageIQ::Providers::TerraformEnterprise::AutomationManager",
          :parent  => :automation_manager

  factory :ems_terraform_enterprise_with_vcr_authentication, :parent => :ems_terraform_enterprise do
    zone { EvmSpecHelper.local_miq_server.zone }
    after(:create) do |ems|
      ems.authentications << FactoryBot.create(:authentication, :auth_key => VcrSecrets.terraform_enterprise.api_key)
    end
  end
end
