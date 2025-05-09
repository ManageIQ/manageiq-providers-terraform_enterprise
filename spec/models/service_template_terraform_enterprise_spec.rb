RSpec.describe ServiceTemplateTerraformEnterprise do
  let(:terraform_enterprise)       { FactoryBot.create(:ems_terraform_enterprise) }
  let(:configuration_script)       { FactoryBot.create(:configuration_script_terraform_enterprise, :manager => terraform_enterprise) }
  let(:service_dialog)             { FactoryBot.create(:dialog) }
  let(:provision_resource_action)  { FactoryBot.create(:resource_action, :action => 'Provision') }
  let(:catalog_item_options) do
    {
      :name         => "Terraform Enterprise",
      :service_type => "atomic",
      :prov_type    => "generic_terraform_enterprise",
      :display      => "false",
      :description  => "a description",
      :config_info  => {
        :configuration_script_id => configuration_script.id,
        :provision               => {
          :fqname    => provision_resource_action.fqname,
          :dialog_id => service_dialog.id
        }
      }
    }
  end

  describe ".create_catalog_item" do
    it "creates and returns a terraform enterprise catalog item" do
      service_template = described_class.create_catalog_item(catalog_item_options)

      expect(service_template.name).to eq("Terraform Enterprise")
      expect(service_template.service_resources.count).to eq(1)
      expect(service_template.dialogs.first).to eq(service_dialog)
      expect(service_template.resource_actions.pluck(:action)).to match_array(%w[Provision])
      expect(service_template.configuration_script).to eq(configuration_script)
      expect(service_template.config_info).to eq(catalog_item_options[:config_info])
    end

    it "raises an exception if configuration_script_id is missing" do
      catalog_item_options[:config_info].delete(:configuration_script_id)

      expect { described_class.create_catalog_item(catalog_item_options) }
        .to raise_error(StandardError, "Must provide a configuration_script_id")
    end
  end

  describe "#update_catalog_item" do
    let(:service_template)         { ServiceTemplateTerraformEnterprise.create_catalog_item(catalog_item_options) }
    let(:new_configuration_script) { FactoryBot.create(:configuration_script_terraform_enterprise, :manager => terraform_enterprise) }

    it "updates the service_template" do
      service_template.update_catalog_item(
        {
          :name         => "Updated Terraform Enterprise",
          :service_type => "atomic",
          :prov_type    => "generic_terraform_enterprise",
          :display      => "false",
          :description  => "a description",
          :config_info  => {
            :configuration_script_id => new_configuration_script.id,
            :provision               => {
              :fqname    => provision_resource_action.fqname,
              :dialog_id => service_dialog.id
            }
          }
        }
      )

      expect(service_template.reload).to have_attributes(
        :name                 => "Updated Terraform Enterprise",
        :configuration_script => new_configuration_script
      )
    end
  end
end
