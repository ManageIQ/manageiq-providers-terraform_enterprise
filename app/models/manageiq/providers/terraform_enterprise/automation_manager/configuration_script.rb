class ManageIQ::Providers::TerraformEnterprise::AutomationManager::ConfigurationScript < ManageIQ::Providers::ExternalAutomationManager::ConfigurationScript
  def self.display_name(number = 1)
    n_('Workspace (%{provider_description})', 'Workspaces (%{provider_description})', number) % {:provider_description => module_parent.description}
  end

  def self.stack_type
    "Job"
  end
end
