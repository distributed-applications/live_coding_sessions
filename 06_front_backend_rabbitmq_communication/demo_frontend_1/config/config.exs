# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :demo_frontend_1, DemoFrontend1Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "82BPQq1omDcVOauOguVn1m5t8PPOj+aSrwas7dQGfTfZnH+LLcIZLaUPcpgzEUg3",
  render_errors: [view: DemoFrontend1Web.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: DemoFrontend1.PubSub,
  live_view: [signing_salt: "Ci4JLBso"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :demo_frontend_1, DemoFrontend1.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
