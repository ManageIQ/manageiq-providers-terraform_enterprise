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
      vcs_repo = workspace.dig("attributes", "vcs-repo")
      if vcs_repo
        configuration_script_source = persister.configuration_script_sources.build(
          :manager_ref => vcs_repo["repository-http-url"],
          :name        => vcs_repo["identifier"],
          :scm_url     => vcs_repo["repository-http-url"],
          :scm_branch  => vcs_repo["branch"]
        )
      end

      persister.configuration_script_payloads.build(
        :manager_ref                 => workspace["id"],
        :name                        => workspace.dig("attributes", "name"),
        :configuration_script_source => configuration_script_source
      )
    end
  end

  def runs
    collector.runs.each do |run|
      workspace_id = run.dig("relationships", "workspace", "data", "id")
      persister.configuration_scripts.build(
        :manager_ref => run["id"],
        :parent      => persister.configuration_script_payloads.lazy_find(workspace_id)
      )
    end
  end
end
