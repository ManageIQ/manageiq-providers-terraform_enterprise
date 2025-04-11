class ManageIQ::Providers::TerraformEnterprise::AutomationManager::Job < Job
  def self.create_job(workspace, vars)
    super(:configuration_script_payload_id => workspace.id, :vars => vars)
  end

  def start
    queue_signal(:execute)
  end

  def execute
    tfe_client = ext_management_system.connect

    run_request = {
      "data" => {
        "attributes"    => {
          "message" => "Creating Run for Job guid [#{guid}]"
        },
        "type"          => "runs",
        "relationships" => {
          "workspace" => {
            "data" => {
              "type" => "workspaces",
              "id"   => configuration_script_payload.manager_ref
            }
          }
        }
      }
    }

    run_response = tfe_client.post("runs", run_request.to_json)
    if run_response.success?
      run = JSON.parse(run_response.body)["data"]
      options[:run_id] = run["id"]
      save!
    else
      abort_job
    end

    queue_poll_runner
  end

  def poll_runner
    running? ? queue_poll_runner : signal(:post_execute)
  end

  def post_execute
    if success?
      signal(:finish)
    else
      abort_job("Failed to run workspace", "error")
    end
  end

  alias initializing dispatch_start
  alias finish       process_finished
  alias abort_job    process_abort
  alias cancel       process_cancel
  alias error        process_error

  protected

  def running?
    %w[errored discarded policy_soft_failed planned_and_finished].exclude?(run_status(options[:run_id]))
  end

  def success?
    run_status(options[:run_id]) == "planned_and_finished"
  end

  def load_transitions
    self.state ||= 'initialize'

    {
      :initializing => {'initialize'       => 'waiting_to_start'},
      :start        => {'waiting_to_start' => 'execute'},
      :execute      => {'execute'          => 'running'},
      :poll_runner  => {'running'          => 'running'},
      :post_execute => {'running'          => 'post_execute'},
      :finish       => {'*'                => 'finished'},
      :abort_job    => {'*'                => 'aborting'},
      :cancel       => {'*'                => 'canceling'},
      :error        => {'*'                => '*'}
    }
  end

  private

  def configuration_script_payload
    @configuration_script_payload ||= self.class.module_parent::ConfigurationScriptPayload.find(options[:configuration_script_payload_id])
  end

  def ext_management_system
    @ext_management_system ||= configuration_script_payload.manager
  end

  def queue_poll_runner
    queue_signal(:poll_runner, :deliver_on => Time.now.utc + poll_interval)
  end

  def poll_interval
    options.fetch(:poll_interval, 1.minute).to_i
  end

  def run_status(run_id)
    result = ext_management_system.connect.get("runs/#{run_id}")
    return unless result.success?

    run = JSON.parse(result.body)["date"]
    run.dig("attributes", "status")
  end
end
