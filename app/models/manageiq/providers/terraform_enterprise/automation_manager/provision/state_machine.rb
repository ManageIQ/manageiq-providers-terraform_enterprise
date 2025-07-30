module ManageIQ::Providers::TerraformEnterprise::AutomationManager::Provision::StateMachine
  def run_provision
    signal :preprovision
  end

  def preprovision
    signal :provision
  end

  def provision
    stack_class = "#{source.class.module_parent}::#{source.class.stack_type}".constantize
    stack       = stack_class.create_stack(source)

    phase_context[:stack_id] = stack.id
    save!

    signal :check_provisioned
  end

  def check_provisioned
    if running?
      stack.refresh_ems
      requeue_phase
    else
      signal :post_provision
    end
  end

  def post_provision
    signal :finish
  end

  def running?
    stack.raw_status.running?
  end

  def finish
  end

  def stack
    @stack ||= source.manager.orchestration_stacks.find(phase_context[:stack_id])
  end
end
