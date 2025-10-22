class ManageIQ::Providers::TerraformEnterprise::AutomationManager < ManageIQ::Providers::ExternalAutomationManager
  include ProcessTasksMixin

  supports :create
  supports :catalog

  has_many :configuration_script_payloads, :foreign_key => :manager_id
  has_many :orchestration_stacks, :foreign_key => :ems_id

  def self.ems_type
    @ems_type ||= "terraform_enterprise".freeze
  end

  def self.description
    @description ||= "Terraform Enterprise".freeze
  end

  def self.catalog_types
    {"terraform_enterprise" => N_("Terraform Enterprise Workspace")}
  end

  def self.params_for_create
    {
      :fields => [
        {
          :component => 'sub-form',
          :name      => 'endpoints-subform',
          :title     => _('Endpoints'),
          :fields    => [
            {
              :component              => 'validate-provider-credentials',
              :name                   => 'authentications.default.valid',
              :skipSubmit             => true,
              :validationDependencies => %w[type zone_id provider_region],
              :fields                 => [
                {
                  :component    => "text-field",
                  :name         => "endpoints.default.url",
                  :label        => _("URL"),
                  :initialValue => "https://app.terraform.io",
                  :isRequired   => true,
                  :validate     => [{:type => "required"}],
                },
                {
                  :component    => "select",
                  :id           => "endpoints.default.verify_ssl",
                  :name         => "endpoints.default.verify_ssl",
                  :label        => _("SSL verification"),
                  :dataType     => "integer",
                  :isRequired   => true,
                  :validate     => [{:type => "required"}],
                  :initialValue => OpenSSL::SSL::VERIFY_PEER,
                  :options      => [
                    {
                      :label => _('Do not verify'),
                      :value => OpenSSL::SSL::VERIFY_NONE,
                    },
                    {
                      :label => _('Verify'),
                      :value => OpenSSL::SSL::VERIFY_PEER,
                    },
                  ]
                },
                {
                  :component  => "password-field",
                  :id         => "authentications.default.auth_key",
                  :name       => "authentications.default.auth_key",
                  :label      => "API Token",
                  :type       => "password",
                  :isRequired => true,
                  :validate   => [{:type => "required"}]
                },
              ]
            }
          ]
        }
      ]
    }
  end

  def self.raw_connect(args)
    default_endpoint       = args.dig("endpoints", "default")
    default_authentication = args.dig("authentications", "default")

    url, verify_ssl = default_endpoint.values_at("url", "verify_ssl")
    api_token       = ManageIQ::Password.try_decrypt(default_authentication["auth_key"]) if default_authentication
    api_token     ||= find(args["id"]).authentication_token("default")
    url             = URI.join(url, "/api/v2")

    require "faraday"
    Faraday.new(
      :url     => url,
      :headers => {
        "Authorization" => "Bearer #{api_token}",
        "Content-Type"  => "application/vnd.api+json"
      },
      :ssl     => {
        :verify_mode => verify_ssl
      }
    )
  end

  def self.verify_credentials(args)
    connection = raw_connect(args)
    connection.get("account/details").success?
  rescue => err
    raise MiqException::MiqInvalidCredentialsError, err.message
  end

  def verify_credentials(auth_type = nil, options = {})
    options[:auth_type] ||= auth_type
    self.class.verify_credentials(connect_options(options))
  end

  def connect(options = {})
    raise MiqException::MiqHostError, "No credentials defined" if missing_credentials?(options[:auth_type])

    self.class.raw_connect(connect_options(options))
  end

  def connect_options(options = {})
    {
      "endpoints"       => {
        "default" => {
          "url"        => url,
          "verify_ssl" => verify_ssl
        }
      },
      "authentications" => {
        "default" => {
          "auth_key" => authentication_token(options[:auth_type])
        }
      }
    }
  end

  def supported_auth_types
    %w[auth_key]
  end

  def required_credential_fields(_type)
    %i[auth_key]
  end
end
