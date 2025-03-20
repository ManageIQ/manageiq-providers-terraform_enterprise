class ManageIQ::Providers::TerraformEnterprise::Inventory::Parser < ManageIQ::Providers::Inventory::Parser
  def parse
    workspaces
  end

  def workspaces
    collector.orgs.each do |org|
      collector.workspaces(org).each do |workspace|
        persister.configuration_scripts.build(
          :manager_ref => workspace["id"],
          :name        => workspace.dig("attributes", "name")
        )
      end
    end
  end
end
