module ManageIQ
  module Providers
    module TerraformEnterprise
      class Engine < ::Rails::Engine
        isolate_namespace ManageIQ::Providers::TerraformEnterprise

        config.autoload_paths << root.join('lib').to_s

        def self.vmdb_plugin?
          true
        end

        def self.plugin_name
          _('Terraform Enterprise Provider')
        end

        def self.init_loggers
          $terraform_enterprise_log ||= Vmdb::Loggers.create_logger("terraform_enterprise.log")
        end

        def self.apply_logger_config(config)
          Vmdb::Loggers.apply_config_value(config, $terraform_enterprise_log, :level_terraform_enterprise)
        end
      end
    end
  end
end
