class ManageIQ::Providers::TerraformEnterprise::AutomationManager::Provision < ManageIQ::Providers::AutomationManager::Provision
  include StateMachine

  TASK_DESCRIPTION = N_("Terraform Enterprise Workspace Provision")
end
