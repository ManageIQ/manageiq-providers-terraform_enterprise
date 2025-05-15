describe ManageIQ::Providers::TerraformEnterprise::AutomationManager::Refresher do
  include Spec::Support::EmsRefreshHelper

  let(:ems) { FactoryBot.create(:ems_terraform_enterprise_with_vcr_authentication, :url => "https://app.terraform.io") }

  describe "#refresh" do
    it "performs a full refresh" do
      first_refresh, second_refresh = 2.times.map do
        with_vcr { ems.refresh }
        serialize_inventory
      end

      assert_inventory_not_changed(first_refresh, second_refresh)
      assert_ems_counts
      assert_specific_configuration_script_source
      assert_specific_configuration_script_payload
      assert_specific_configuration_script
      assert_specific_orchestration_stack
    end

    def assert_ems_counts
      expect(ems.configuration_script_sources.count).to eq(1)
      expect(ems.configuration_script_payloads.count).to eq(1)
      expect(ems.configuration_scripts.count).to eq(2)
      expect(ems.orchestration_stacks.count).to eq(3)
    end

    def assert_specific_configuration_script_source
      configuration_script_source = ems.configuration_script_sources.find_by(:name => "agrare/terraform-test")
      expect(configuration_script_source).to have_attributes(
        :manager_ref => "https://github.com/agrare/terraform-test",
        :name        => "agrare/terraform-test",
        :type        => "ManageIQ::Providers::TerraformEnterprise::AutomationManager::ConfigurationScriptSource",
        :scm_url     => "https://github.com/agrare/terraform-test",
        :scm_branch  => "master"
      )
    end

    def assert_specific_configuration_script_payload
      configuration_script_payload = ems.configuration_script_payloads.find_by(:manager_ref => "ws-BkpXRVrXTfUNXuxT")
      expect(configuration_script_payload).to have_attributes(
        :manager_ref                 => "ws-BkpXRVrXTfUNXuxT",
        :name                        => "agrare/terraform-test@master",
        :type                        => "ManageIQ::Providers::TerraformEnterprise::AutomationManager::ConfigurationScriptPayload",
        :configuration_script_source => ems.configuration_script_sources.find_by(:name => "agrare/terraform-test")
      )
    end

    def assert_specific_configuration_script
      configuration_script = ems.configuration_scripts.find_by(:manager_ref => "ws-BkpXRVrXTfUNXuxT")
      expect(configuration_script).to have_attributes(
        :manager_ref => "ws-BkpXRVrXTfUNXuxT",
        :parent      => ems.configuration_script_payloads.find_by(:name => "agrare/terraform-test@master"),
        :type        => "ManageIQ::Providers::TerraformEnterprise::AutomationManager::ConfigurationScript"
      )
    end

    def assert_specific_orchestration_stack
      orchestration_stack = ems.orchestration_stacks.find_by(:ems_ref => "run-dvL1cMGifahRqsYQ")
      expect(orchestration_stack).to have_attributes(
        :ems_ref => "run-dvL1cMGifahRqsYQ",
        :name    => "test-workspace",
        :status  => "planned_and_finished",
        :configuration_script => ems.configuration_scripts.find_by(:name => "test-workspace")
      )
    end
  end
end
