class ManageIQ::Providers::TerraformEnterprise::AutomationManager::OrchestrationStack < ManageIQ::Providers::ExternalAutomationManager::OrchestrationStack
  include ProviderObjectMixin

  belongs_to :configuration_script,         :foreign_key => :configuration_script_id
  belongs_to :configuration_script_payload, :foreign_key => :configuration_script_base_id

  def self.display_name(number = 1)
    n_('Run (Terraform Enterprise)', 'Runs (Terraform Enterprise)', number)
  end

  def self.create_stack(workspace, options = {})
    run_id = raw_create_stack(workspace, options)

    create!(
      :name                         => workspace.name,
      :ext_management_system        => workspace.manager,
      :ems_ref                      => run_id,
      :status                       => "pending",
      :configuration_script         => workspace,
      :configuration_script_payload => workspace.parent
    )
  end

  def self.raw_create_stack(workspace, options = {})
    workspace.run(options)
  rescue => err
    _log.error("Failed to create run from workspace [#{workspace.name}]: #{err}")
    raise MiqException::MiqOrchestrationProvisionError, err.to_s, err.backtrace
  end

  def self.db_name
    'ConfigurationJob'
  end

  def raw_status
    Status.new(status)
  end

  def raw_stdout
    with_provider_connection do |connection|
      run     = provider_object(connection)
      plan_id = run&.dig("relationships", "plan", "data", "id")
      return if plan_id.nil?

      response = connection.get("plans/#{plan_id}/json-output")
      if response.status == 307 # HCP returns a HTTP 307 redirect for json-output
        location = response.headers["location"]
        response = connection.get(location)
        return unless response.success?
      end

      JSON.parse(response.body)
    end
  end

  def refresh_ems
    update_with_provider_object(provider_object)
  end

  def provider_object(connection = nil)
    connection ||= ext_management_system.connect
    response = connection.get("runs/#{ems_ref}")
    JSON.parse(response.body)["data"] if response.success?
  end

  private

  def update_with_provider_object(run)
    return if run.nil?

    update!(:status => run.dig("attributes", "status"))
  end
end
