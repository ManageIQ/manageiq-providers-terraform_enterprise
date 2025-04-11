class ServiceTerraformEnterprise < ServiceGeneric
  delegate :terraform_workspace, :to => :service_template, :allow_nil => true

  def my_zone
    miq_request&.my_zone
  end

  def execute(action)
    task_opts = {
      :action => "Launching Terraform Enterprise Workspace",
      :userid => "system"
    }

    queue_opts = {
      :args        => [action],
      :class_name  => self.class.name,
      :instance_id => id,
      :method_name => "launch_terraform_workspace",
      :role        => "ems_operations",
      :zone        => my_zone
    }

    task_id = MiqTask.generic_action_with_callback(task_opts, queue_opts)
    task    = MiqTask.wait_for_taskid(task_id)
    raise task.message unless task.status_ok?
  end

  def launch_terraform_workspace(action)
    workspace = terraform_workspace(action)
    stack = ManageIQ::Providers::TerraformEnterprise::AutomationManager::Stack.create_stack(workspace, options)
    add_resource!(stack, :name => action)
  end

  private

  def job(action)
    stack(action)&.miq_task&.job
  end
end
