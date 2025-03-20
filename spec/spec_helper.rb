if ENV['CI']
  require 'simplecov'
  SimpleCov.start
end

Dir[Rails.root.join("spec/shared/**/*.rb")].sort.each { |f| require f }
Dir[File.join(__dir__, "support/**/*.rb")].sort.each { |f| require f }

require "manageiq/providers/terraform_enterprise"

VCR.configure do |config|
  config.ignore_hosts 'codeclimate.com' if ENV['CI']
  config.cassette_library_dir = File.join(ManageIQ::Providers::TerraformEnterprise::Engine.root, 'spec/vcr_cassettes')

  secrets = Rails.application.secrets
  secrets.terraform_enterprise.each_key do |key|
    placeholder_val = secrets.terraform_enterprise_defaults[key]
    secret_val      = secrets.terraform_enterprise[key]

    config.define_cassette_placeholder(placeholder_val) { secret_val }
  end
end
