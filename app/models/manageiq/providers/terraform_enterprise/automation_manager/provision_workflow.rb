class ManageIQ::Providers::TerraformEnterprise::AutomationManager::ProvisionWorkflow < MiqProvisionConfigurationScriptWorkflow
  def self.default_dialog_file
    'miq_provision_configuration_script_dialogs'
  end

  def validate(*)
    true
  end

  def allowed_configuration_scripts(_options = {})
    @allowed_configuration_scripts ||= begin
      ::ConfigurationScript.where(:id => @values[:src_configuration_script_ids]).collect do |cs|
        build_ci_hash_struct(cs, [:name])
      end
    end
  end
end
