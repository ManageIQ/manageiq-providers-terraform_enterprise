class ManageIQ::Providers::TerraformEnterprise::AutomationManager < ManageIQ::Providers::ExternalAutomationManager
  supports :create

  def self.ems_type
    @ems_type ||= "terraform_enterprise".freeze
  end

  def self.description
    @description ||= "Terraform Enterprise".freeze
  end
end
