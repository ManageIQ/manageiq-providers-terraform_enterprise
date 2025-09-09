class ManageIQ::Providers::TerraformEnterprise::Inventory::Parser < ManageIQ::Providers::Inventory::Parser
  def parse
    orgs
    projects
    workspaces
    runs
  end

  def orgs
    collector.orgs.each do |org|
    end
  end

  def projects
    collector.projects.each do |project|
    end
  end

  def workspaces
    collector.workspaces.each do |workspace|
      variables = collector.workspace_variables[workspace["id"]].to_h do |var|
        var["attributes"]&.values_at("key", "value")
      end

      vcs_repo = workspace.dig("attributes", "vcs-repo")
      if vcs_repo
        configuration_script_source = persister.configuration_script_sources.build(
          :manager_ref => vcs_repo["repository-http-url"],
          :name        => vcs_repo["identifier"],
          :scm_url     => vcs_repo["repository-http-url"],
          :scm_branch  => vcs_repo["branch"]
        )

        payload_name = vcs_repo["display-identifier"]
        payload_name << "@#{vcs_repo["branch"]}" if vcs_repo["branch"].present?

        payload = persister.configuration_script_payloads.build(
          :manager_ref                 => workspace["id"],
          :name                        => payload_name,
          :configuration_script_source => configuration_script_source
        )
      end

      persister.configuration_scripts.build(
        :manager_ref => workspace["id"],
        :name        => workspace.dig("attributes", "name"),
        :description => workspace.dig("attributes", "description"),
        :parent      => payload,
        :variables   => variables
      )
    end
  end

  def runs
    collector.runs.each do |run|
      workspace_id = run.dig("relationships", "workspace", "data", "id")
      workspace    = collector.workspaces_by_id[workspace_id]

      persister.orchestration_stacks.build(
        :ems_ref              => run["id"],
        :name                 => workspace.dig("attributes", "name"),
        :status               => run.dig("attributes", "status"),
        :configuration_script => persister.configuration_scripts.lazy_find(workspace_id)
      )
    end
  end
end
