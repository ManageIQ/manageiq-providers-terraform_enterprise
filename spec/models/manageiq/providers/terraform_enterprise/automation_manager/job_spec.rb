RSpec.describe ManageIQ::Providers::TerraformEnterprise::AutomationManager::Job do
  let(:ems)       { FactoryBot.create(:ems_terraform_enterprise) }
  let(:workspace) { FactoryBot.create(:terraform_enterprise_workspace, :manager => ems) }
  let(:job)       { described_class.create_job(workspace, vars).tap { |job| job.state = state } }
  let(:state)     { "waiting_to_start" }
  let(:vars)      { {"name" => "stack123"} }

  describe ".create_job" do
    it "create a job" do
      expect(described_class.create_job(workspace, vars)).to have_attributes(
        :type    => "ManageIQ::Providers::TerraformEnterprise::AutomationManager::Job",
        :options => {
          :configuration_script_payload_id => workspace.id,
          :vars                            => vars
        }
      )
    end
  end

  describe "#execute" do
    let(:tfe_client)   { double("TerraformEnterpriseClient") }
    let(:run_id)       { "12345" }
    let(:run_response) { double("Result") }

    before do
      allow(job).to receive(:ext_management_system).and_return(ems)
      allow(ems).to receive(:connect).and_return(tfe_client)
      allow(tfe_client)
        .to receive(:post)
        .with("runs", a_string_including("{\"type\":\"workspaces\",\"id\":\"#{workspace.manager_ref}\"}}"))
        .and_return(run_response)
    end

    it "creates a Run" do
      expect(run_response).to receive(:success?).and_return(true)
      expect(run_response).to receive(:body).and_return("{\"data\":{\"id\":\"#{run_id}\"}}")

      job.execute

      expect(job.options).to include(
        :configuration_script_payload_id => workspace.id,
        :run_id                          => run_id,
        :vars                            => vars
      )
    end

    it "aborts the job on failure" do
      expect(run_response).to receive(:success?).and_return(false)

      job.execute

      expect(job).to have_attributes(
        :state  => "finished",
        :status => "error"
      )
    end
  end

  describe "#signal" do
    %w[start pre_execute execute poll_runner post_execute finish abort_job cancel error].each do |signal|
      shared_examples_for "allows #{signal} signal" do
        it signal.to_s do
          expect(job).to receive(signal.to_sym)
          job.signal(signal.to_sym)
        end
      end
    end

    %w[start execute poll_runner post_execute finish abort_job cancel error].each do |signal|
      shared_examples_for "doesn't allow #{signal} signal" do
        it signal.to_s do
          expect { job.signal(signal.to_sym) }.to raise_error(RuntimeError, /#{signal} is not permitted at state #{job.state}/)
        end
      end
    end

    context "waiting_to_start" do
      let(:state) { "waiting_to_start" }

      it_behaves_like "allows start signal"
      it_behaves_like "doesn't allow execute signal"
      it_behaves_like "doesn't allow poll_runner signal"
      it_behaves_like "doesn't allow post_execute signal"
      it_behaves_like "allows finish signal"
      it_behaves_like "allows abort_job signal"
      it_behaves_like "allows cancel signal"
      it_behaves_like "allows error signal"
    end

    context "pre_execute" do
      let(:state) { "pre_execute" }

      it_behaves_like "doesn't allow start signal"
      it_behaves_like "doesn't allow execute signal"
      it_behaves_like "doesn't allow poll_runner signal"
      it_behaves_like "doesn't allow post_execute signal"
      it_behaves_like "allows finish signal"
      it_behaves_like "allows abort_job signal"
      it_behaves_like "allows cancel signal"
      it_behaves_like "allows error signal"
    end

    context "running" do
      let(:state) { "running" }

      it_behaves_like "doesn't allow start signal"
      it_behaves_like "doesn't allow execute signal"
      it_behaves_like "allows poll_runner signal"
      it_behaves_like "allows post_execute signal"
      it_behaves_like "allows finish signal"
      it_behaves_like "allows abort_job signal"
      it_behaves_like "allows cancel signal"
      it_behaves_like "allows error signal"
    end

    context "post_execute" do
      let(:state) { "post_execute" }

      it_behaves_like "doesn't allow start signal"
      it_behaves_like "doesn't allow execute signal"
      it_behaves_like "doesn't allow poll_runner signal"
      it_behaves_like "doesn't allow post_execute signal"
      it_behaves_like "allows finish signal"
      it_behaves_like "allows abort_job signal"
      it_behaves_like "allows cancel signal"
      it_behaves_like "allows error signal"
    end

    context "finished" do
      let(:state) { "finished" }

      it_behaves_like "doesn't allow start signal"
      it_behaves_like "doesn't allow execute signal"
      it_behaves_like "doesn't allow poll_runner signal"
      it_behaves_like "doesn't allow post_execute signal"
      it_behaves_like "allows finish signal"
      it_behaves_like "allows abort_job signal"
      it_behaves_like "allows cancel signal"
      it_behaves_like "allows error signal"
    end
  end

  describe "#start" do
    it "moves to state pre_execute" do
      job.signal(:start)
      expect(job.reload.state).to eq("execute")
    end
  end

  describe "#poll_runner" do
    let(:state) { "running" }

    context "still running" do
      before { expect(job).to receive(:running?).and_return(true) }

      it "requeues poll_runner" do
        job.signal(:poll_runner)
        expect(job.reload.state).to eq("running")
      end
    end

    context "completed" do
      before { expect(job).to receive(:run_status).twice.and_return("planned_and_finished") }

      it "moves to state finished" do
        job.signal(:poll_runner)
        expect(job.reload.state).to eq("finished")
      end
    end
  end
end
