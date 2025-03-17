describe ManageIQ::Providers::TerraformEnterprise::AutomationManager do
  let(:ems) { FactoryBot.create(:ems_terraform_enterprise) }

  it ".ems_type" do
    expect(described_class.ems_type).to eq("terraform_enterprise")
  end

  it ".description" do
    expect(described_class.description).to eq("Terraform Enterprise")
  end
end
