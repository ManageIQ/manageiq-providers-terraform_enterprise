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
    end

    def assert_ems_counts
      expect(ems.configuration_script_payloads.count).to eq(2)
      expect(ems.configuration_scripts.count).to eq(3)
    end
  end
end
