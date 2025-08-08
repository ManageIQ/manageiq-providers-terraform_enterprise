class ManageIQ::Providers::TerraformEnterprise::AutomationManager::Provision < MiqProvisionTask
  include StateMachine

  TASK_DESCRIPTION = N_("Terraform Enterprise Workspace Provision")
  ACTIVE_STATES = MiqRequest::ACTIVE_STATES
  def my_role(*)
    "ems_operations"
  end

  def my_queue_name
    source.manager&.queue_name_for_ems_operations
  end

  def self.get_description(*)
    ""
  end

  def update_and_notify_parent(upd_attr)
    upd_attr[:message] = upd_attr[:message][0, 255] if upd_attr.key?(:message)
    update!(upd_attr)
  end
end
