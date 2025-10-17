class ManageIQ::Providers::TerraformEnterprise::AutomationManager::ConfigurationScript < ManageIQ::Providers::ExternalAutomationManager::ConfigurationScript
  has_many :orchestration_stacks, :class_name => "ManageIQ::Providers::TerraformEnterprise::AutomationManager::OrchestrationStack", :foreign_key => :configuration_script_id, :inverse_of => :configuration_script, :dependent => :nullify

  def self.display_name(number = 1)
    n_('Workspace (Terraform Enterprise)', 'Workspaces (Terraform Enterprise)', number)
  end

  def self.stack_type
    "OrchestrationStack"
  end

  def self.manager_class
    module_parent
  end

  def my_zone
    manager&.my_zone
  end

  def run(options = {})
    variables = options[:variables] || []

    with_provider_connection do |tfe_client|
      request_body = {
        "data" => {
          "attributes"    => {
            "message"   => "Creating Run for Workspace name: [#{name}] manager_ref: [#{manager_ref}]",
            "variables" => variables
          },
          "type"          => "runs",
          "relationships" => {
            "workspace" => {
              "data" => {
                "type" => "workspaces",
                "id"   => manager_ref
              }
            }
          }
        }
      }

      response = tfe_client.post("runs", request_body.to_json)
      raise response.reason_phrase unless response.success?

      JSON.parse(response.body).dig("data", "id")
    end
  end
end
