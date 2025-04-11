class ServiceTemplateTerraformEnterprise < ServiceTemplate
  def self.default_provisioning_entry_point(_service_type)
    '/Service/Generic/StateMachines/GenericLifecycle/provision'
  end

  def self.default_reconfiguration_entry_point
    nil
  end

  def self.default_retirement_entry_point
    nil
  end

  def self.create_catalog_item(options, _auth_user)
    options      = options.merge(:service_type => SERVICE_TYPE_ATOMIC, :prov_type => 'generic_terraform_enterprise')
    config_info  = validate_config_info(options[:config_info])

    transaction do
      create_from_options(options).tap do |service_template|
        service_template.options[:config_info] = config_info
        service_template.create_resource_actions(config_info)
      end
    end
  end

  def update_catalog_item(options, auth_user = nil)
    config_info = validate_update_config_info(options)
    unless config_info
      update!(options)
      return reload
    end

    config_info.deep_merge!(create_dialogs(config_info))

    options[:config_info] = config_info

    super
  end

  private_class_method def self.validate_config_info(info)
    info[:provision][:fqname] ||= default_provisioning_entry_point(SERVICE_TYPE_ATOMIC) if info.key?(:provision)

    raise _("Must provide a configuration_script_payload_id") if info.dig(:provision, :configuration_script_payload_id).nil?

    info
  end

  def terraform_workspace(action)
    template_id = config_info.dig(action.downcase.to_sym, :configuration_script_payload_id)
    return if template_id.nil?

    ManageIQ::Providers::TerraformEnterprise::AutomationManager::ConfigurationScriptPayload.find(template_id)
  end
end
