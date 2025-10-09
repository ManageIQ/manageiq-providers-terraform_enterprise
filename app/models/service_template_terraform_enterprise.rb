class ServiceTemplateTerraformEnterprise < ServiceTemplate
  include ServiceTemplateAutomationMixin

  def self.create_catalog_item(options, auth_user = nil)
    transaction do
      create_from_options(options).tap do |service_template|
        config_info = options[:config_info].except(:provision, :retirement, :reconfigure)
        validate_config_info!(config_info)

        wf_class = ManageIQ::Providers::TerraformEnterprise::AutomationManager::ProvisionWorkflow
        wf       = wf_class.new(config_info, auth_user)
        request  = wf.make_request(nil, config_info)
        service_template.add_resource(request)
        service_template.create_resource_actions(options[:config_info])
      end
    end
  end

  def self.validate_config_info!(config_info)
    raise _("Must provide a source_id") if config_info[:source_id].nil?
  end

  private

  def validate_update_config_info(options)
    config_info = super

    self.class.validate_config_info!(config_info)
    config_info
  end
end
