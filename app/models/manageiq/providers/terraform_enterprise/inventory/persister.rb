class ManageIQ::Providers::TerraformEnterprise::Inventory::Persister < ManageIQ::Providers::Inventory::Persister
  def initialize_inventory_collections
    add_collection(automation, :configuration_scripts)
    add_collection(automation, :configuration_script_sources)
    add_collection(automation, :configuration_script_payloads)
    add_collection(automation, :orchestration_stacks) do |builder|
      builder.default_values = {:ext_management_system => manager}
    end
  end
end
