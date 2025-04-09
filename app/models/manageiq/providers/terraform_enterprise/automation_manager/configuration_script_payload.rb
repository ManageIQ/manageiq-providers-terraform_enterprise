class ManageIQ::Providers::TerraformEnterprise::AutomationManager::ConfigurationScriptPayload < ManageIQ::Providers::ExternalAutomationManager::ConfigurationScriptPayload
  def self.display_name(number = 1)
    n_('Workspace (%{provider_description})', 'Workspaces (%{provider_description})', number) % {:provider_description => module_parent.description}
  end
end
