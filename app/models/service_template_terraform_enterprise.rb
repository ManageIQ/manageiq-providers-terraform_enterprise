class ServiceTemplateTerraformEnterprise < ServiceTemplate
  include ServiceConfigurationMixin
  include ServiceTemplateAutomationMixin

  alias terraform_workspace configuration_script
  alias terraform_workspace= configuration_script=

  def self.default_provisioning_entry_point(_service_type)
    '/AutomationManagement/TerraformEnterprise/Service/Provisioning/StateMachines/Provision/CatalogItemInitialization'
  end

  def self.default_reconfiguration_entry_point
    nil
  end

  def self.default_retirement_entry_point
    nil
  end

  def self.create_catalog_item(options, _auth_user = nil)
    transaction do
      create_from_options(options).tap do |service_template|
        config_info = validate_config_info(options)

        service_template.terraform_workspace = if config_info[:configuration_script_id]
                                                 ConfigurationScript.find(config_info[:configuration_script_id])
                                               else
                                                 config_info[:configuration]
                                               end

        service_template.create_resource_actions(config_info)
      end
    end
  end

  def create_subtasks(_parent_service_task, _parent_service)
    # no sub task is needed for this service
    []
  end

  def my_zone
    configuration_script.manager.try(:my_zone)
  end

  def self.validate_config_info(options)
    config_info = options[:config_info] || {}
    config_info[:provision][:fqname] ||= default_provisioning_entry_point(SERVICE_TYPE_ATOMIC) if config_info.key?(:provision)

    raise _("Must provide a configuration_script_id") if config_info[:configuration_script_id].nil?

    config_info
  end

  private

  def update_service_resources(config_info, _auth_user = nil)
    return if !config_info.key?(:configuration_script_id) || config_info[:configuration_script_id] == configuration_script&.id

    service_resources.find_by(:resource_type => 'ConfigurationScriptBase').destroy
    self.configuration_script = ConfigurationScriptBase.find(config_info[:configuration_script_id])
  end

  def validate_update_config_info(options)
    super

    return unless options.key?(:config_info)

    self.class.validate_config_info(options)
  end
end
