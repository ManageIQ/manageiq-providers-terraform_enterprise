class ManageIQ::Providers::TerraformEnterprise::AutomationManager::Stack < ManageIQ::Providers::ExternalAutomationManager::OrchestrationStack
  belongs_to :ext_management_system,        :foreign_key => :ems_id,                       :class_name => "ManageIQ::Providers::TerraformEnterprise::AutomationManager",                             :inverse_of => false
  belongs_to :configuration_script_payload, :foreign_key => :configuration_script_base_id, :class_name => "ManageIQ::Providers::TerraformEnterprise::AutomationManager::ConfigurationScriptPayload", :inverse_of => :stacks
  belongs_to :miq_task,                     :foreign_key => :ems_ref,                      :inverse_of => false

  class << self
    alias create_job     create_stack
    alias raw_create_job raw_create_stack

    def create_stack(workspace, options = {})
      job = raw_create_stack(workspace, options)

      miq_task = job&.miq_task

      create!(
        :name                         => workspace.name,
        :ext_management_system        => workspace.manager,
        :configuration_script_payload => workspace,
        :miq_task                     => miq_task,
        :status                       => miq_task&.state,
        :start_time                   => miq_task&.started_on
      )
    end

    def raw_create_stack(workspace, options = {})
      workspace.run(options)
    end
  end
end
