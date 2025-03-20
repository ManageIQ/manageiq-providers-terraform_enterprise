class ManageIQ::Providers::TerraformEnterprise::Inventory::Collector < ManageIQ::Providers::Inventory::Collector
  def connection
    @connection ||= manager.connect
  end

  def orgs
    response = connection.get("organizations")
    JSON.parse(response.body)["data"]
  end

  def projects(org)
    response = connection.get("organizations/#{org["id"]}/projects")
    JSON.parse(response.body)["data"]
  end

  def workspaces(org)
    response = connection.get("organizations/#{org["id"]}/workspaces")
    JSON.parse(response.body)["data"]
  end
end
