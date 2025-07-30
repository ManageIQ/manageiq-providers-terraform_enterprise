class ManageIQ::Providers::TerraformEnterprise::AutomationManager::Provision < MiqProvisionTask
  include StateMachine

  TASK_DESCRIPTION = N_("Terraform Enterprise Workspace Provision")

  def self.request_class
    MiqProvisionConfigurationScriptRequest
  end

  def my_role(*)
    "ems_operations"
  end

  def my_queue_name
    source.manager&.queue_name_for_ems_operations
  end
end
