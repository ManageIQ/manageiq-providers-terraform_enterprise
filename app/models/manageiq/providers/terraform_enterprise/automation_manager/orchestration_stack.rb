class ManageIQ::Providers::TerraformEnterprise::AutomationManager::OrchestrationStack < ManageIQ::Providers::ExternalAutomationManager::OrchestrationStack
  belongs_to :configuration_script,         :foreign_key => :configuration_script_id
  belongs_to :configuration_script_payload, :foreign_key => :configuration_script_base_id

  def self.display_name(number = 1)
    n_('Run (Terraform Enterprise)', 'Runs (Terraform Enterprise)', number)
  end

  def self.create_stack(workspace, options = {})
    run_id = raw_create_stack(workspace, options)

    create!(
      :name                         => workspace.name,
      :ext_management_system        => workspace.manager,
      :ems_ref                      => run_id,
      :status                       => "pending",
      :configuration_script         => workspace,
      :configuration_script_payload => workspace.parent
    )
  end

  def self.raw_create_stack(workspace, options = {})
    workspace.run(options)
  rescue => err
    _log.error("Failed to create run from workspace [#{workspace.name}]: #{err}")
    raise MiqException::MiqOrchestrationProvisionError, err.to_s, err.backtrace
  end

  def self.db_name
    'ConfigurationJob'
  end
end
