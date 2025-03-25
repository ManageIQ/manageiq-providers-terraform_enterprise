class ManageIQ::Providers::TerraformEnterprise::Inventory::Persister < ManageIQ::Providers::Inventory::Persister
  def initialize_inventory_collections
    add_collection(automation, :configuration_scripts)
    add_collection(automation, :configuration_script_sources)
    add_collection(automation, :configuration_script_payloads) do |builder|
      builder.add_properties(:manager_ref => %i[manager_ref])
      builder.add_default_values(:manager => manager)
    end
  end
end
