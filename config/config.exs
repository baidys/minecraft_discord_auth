# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ueberauth, Ueberauth,
  providers: [
    discord: {Ueberauth.Strategy.Discord, [default_scope: "identify guilds"]}
  ]

config :ueberauth, Ueberauth.Strategy.Discord.OAuth,
  client_id: System.fetch_env!("DISCORD_CLIENT_ID"),
  client_secret: System.fetch_env!("DISCORD_CLIENT_SECRET")

config :auth_backend,
  ecto_repos: [AuthBackend.Repo],
  generators: [timestamp_type: :utc_datetime],
  smp_secret: System.fetch_env!("SMP_SECRET"),
  guild_id: System.fetch_env!("GUILD_ID"),
  mc_server_ip: System.fetch_env!("MC_SERVER_IP")

# Configures the endpoint
config :auth_backend, AuthBackendWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: AuthBackendWeb.ErrorHTML, json: AuthBackendWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: AuthBackend.PubSub,
  live_view: [signing_salt: "CCIXtHQx"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :auth_backend, AuthBackend.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  auth_backend: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.7",
  auth_backend: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
