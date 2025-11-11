class ManageIQ::Providers::TerraformEnterprise::Inventory::Collector < ManageIQ::Providers::Inventory::Collector
  def connection
    @connection ||= manager.connect
  end

  def orgs
    @orgs ||= paginated_get("organizations")
  end

  def projects
    @projects ||= orgs.flat_map { |org| paginated_get("organizations/#{org["id"]}/projects") }
  end

  def workspaces
    @workspaces ||= orgs.flat_map { |org| paginated_get("organizations/#{org["id"]}/workspaces") }
  end

  def workspaces_by_id
    @workspaces_by_id ||= workspaces.index_by { |ws| ws["id"] }
  end

  private

  def paginated_get(url, query_params = {})
    paginated_query_params = query_params
    result = []

    loop do
      response = connection.get(url, paginated_query_params)
      raise response.reason_phrase unless response.success?

      parsed_body = JSON.parse(response.body)

      result.concat(parsed_body["data"])

      meta_pagination = parsed_body.dig("meta", "pagination")
      if meta_pagination&.dig("next-page")
        paginated_query_params["page[number]"] = meta_pagination["next-page"]
      else
        break
      end
    end

    result
  end
end
