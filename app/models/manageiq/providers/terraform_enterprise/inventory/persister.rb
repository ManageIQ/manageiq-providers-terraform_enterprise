class ManageIQ::Providers::TerraformEnterprise::Inventory::Persister < ManageIQ::Providers::Inventory::Persister
  def initialize_inventory_collections
    add_collection(automation, :configuration_scripts)
    add_collection(automation, :configuration_script_sources)
    add_collection(automation, :configuration_script_payloads)
  end
end
