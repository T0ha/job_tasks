# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :jobs,
  ecto_repos: [Jobs.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configure the endpoint
config :jobs, JobsWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: JobsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Jobs.PubSub,
  live_view: [signing_salt: "yfD1gxdF"]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Register a custom MIME type so jobs can be rendered as a bash script
config :mime, :types, %{
  "text/x-shellscript" => ["sh"]
}

# ".sh" already maps to "application/x-sh" in mime's built-in table;
# prefer our type for that extension.
config :mime, :extensions, %{
  "sh" => "text/x-shellscript"
}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
