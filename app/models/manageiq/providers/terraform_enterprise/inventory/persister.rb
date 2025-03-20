class ManageIQ::Providers::TerraformEnterprise::Inventory::Persister < ManageIQ::Providers::Inventory::Persister
  def initialize_inventory_collections
    add_collection(automation, :configuration_scripts)
  end
end
