class ManageIQ::Providers::TerraformEnterprise::AutomationManager::OrchestrationStack::Status < ::OrchestrationStack::Status
  def initialize(status)
    self.status = status.downcase
    self.reason = self.class.run_state_to_description(status)
  end

  def succeeded?
    %w[planned_and_finished applied].include?(status)
  end

  def failed?
    %w[policy_soft_failed errored].include?(status)
  end

  def canceled?
    %w[discarded canceled force_canceled].include?(status)
  end

  def running?
    !succeeded? && !failed? && !canceled?
  end

  # Lookup table of run state descriptions
  # https://developer.hashicorp.com/terraform/cloud-docs/api-docs/run#run-states
  def self.run_state_to_description(status)
    case status
    when "pending"              then N_("Pending")
    when "fetching"             then N_("The run is waiting for HCP Terraform to fetch the configuration from VCS.")
    when "fetching_complete"    then N_("HCP Terraform has fetched the configuration from VCS and the run will continue.")
    when "pre_plan_running"     then N_("The pre-plan phase of the run is in progress.")
    when "pre_plan_completed"   then N_("The pre-plan phase of the run has completed.")
    when "queuing"              then N_("HCP Terraform is queuing the run to start the planning phase.")
    when "plan_queued"          then N_("HCP Terraform is waiting for its backend services to start the plan.")
    when "planning"             then N_("The planning phase of a run is in progress.")
    when "planned"              then N_("The planning phase of a run has completed.")
    when "cost_estimating"      then N_("The cost estimation phase of a run is in progress.")
    when "cost_estimated"       then N_("The cost estimation phase of a run has completed.")
    when "policy_checking"      then N_("The sentinel policy checking phase of a run is in progress.")
    when "policy_override"      then N_("A sentinel policy has soft failed, and a user can override it to continue the run.")
    when "policy_soft_failed"   then N_("A sentinel policy has soft failed for a plan-only run. This is a final state.")
    when "policy_checked"       then N_("The sentinel policy checking phase of a run has completed.")
    when "confirmed"            then N_("A user has confirmed the plan.")
    when "post_plan_running"    then N_("The post-plan phase of the run is in progress.")
    when "post_plan_completed"  then N_("The post-plan phase of the run has completed.")
    when "planned_and_finished" then N_("The run is completed.  This is a final state.")
    when "planned_and_saved"    then N_("The run has finished its planning, checks, and estimates, and can be confirmed for apply.")
    when "apply_queued"         then N_("The run should start as soon as the backend services that run terraform have available capacity.")
    when "applying"             then N_("Terraform is applying the changes specified in the plan.")
    when "applied"              then N_("Terraform has applied the changes specified in the plan.")
    when "discarded"            then N_("The run has been discarded. This is a final state.")
    when "errored"              then N_("The run has errored. This is a final state.")
    when "canceled"             then N_("The run has been canceled.")
    when "force_canceled"       then N_("A workspace admin forcefully canceled the run.")
    end
  end
end
