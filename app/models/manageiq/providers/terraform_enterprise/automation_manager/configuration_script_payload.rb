class ManageIQ::Providers::TerraformEnterprise::AutomationManager::ConfigurationScriptPayload < ManageIQ::Providers::ExternalAutomationManager::ConfigurationScriptPayload
  has_many :orchestration_stacks, :class_name => "ManageIQ::Providers::TerraformEnterprise::AutomationManager::OrchestrationStack", :foreign_key => :configuration_script_base_id, :inverse_of => :configuration_script_payload, :dependent => :nullify

  def self.display_name(number = 1)
    n_('Terraform Template (Terraform Enterprise)', 'Terraform Templates (Terraform Enterprise)', number)
  end
end
