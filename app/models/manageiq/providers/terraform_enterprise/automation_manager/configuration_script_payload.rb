class ManageIQ::Providers::TerraformEnterprise::AutomationManager::ConfigurationScriptPayload < ManageIQ::Providers::ExternalAutomationManager::ConfigurationScriptPayload
  has_many :stacks, :class_name => "ManageIQ::Providers::TerraformEnterprise::AutomationManager::Stack", :foreign_key => :configuration_script_base_id, :inverse_of => :configuration_script_payload, :dependent => :nullify

  def self.display_name(number = 1)
    n_('Workspace (%{provider_description})', 'Workspaces (%{provider_description})', number) % {:provider_description => module_parent.description}
  end

  def run(vars = {}, _userid = nil)
    self.class.module_parent::Job.create_job(self, vars).tap(&:signal_start)
  end
end
