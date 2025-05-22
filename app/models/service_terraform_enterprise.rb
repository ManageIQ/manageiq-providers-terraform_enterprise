class ServiceTerraformEnterprise < Service
  include ServiceConfigurationMixin

  alias_method :terraform_workspace, :configuration_script
  alias_method :terraform_workspace=, :configuration_script=

  def launch_stack
    stack_class = "#{terraform_workspace.class.module_parent.name}::#{terraform_workspace.class.stack_type}".constantize

    _log.info("Launching Terraform Enterprise Run")

    @stack = stack_class.create_stack(terraform_workspace, {})
    add_resource(@stack)
    save!
    @stack
  end

  def stack(_action = nil)
    @stack ||= service_resources.find_by(:resource_type => "OrchestrationStack").try(:resource)
  end
end
