class ManageIQ::Providers::TerraformEnterprise::AutomationManager::ProvisionWorkflow < ManageIQ::Providers::AutomationManager::ProvisionWorkflow
  def dialog_name_from_automate(message = 'get_dialog_name', extra_attrs = {})
    extra_attrs['platform'] ||= 'terraform_enterprise'
    super
  end

  def allowed_configuration_scripts(*args)
    ManageIQ::Providers::TerraformEnterprise::AutomationManager::ConfigurationScript.all.map do |cs|
      build_ci_hash_struct(cs, %w[name description])
    end
  end
end
