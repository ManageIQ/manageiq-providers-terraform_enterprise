class ManageIQ::Providers::TerraformEnterprise::Inventory::Parser < ManageIQ::Providers::Inventory::Parser
  def parse
    orgs
    projects
    workspaces
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
        :parent      => payload
      )
    end
  end
end
