# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :planner,
  ecto_repos: [Planner.Repo]

# Configures the endpoint
config :planner, PlannerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "SUNLcOWtisgdCWMIRDKt6UNgJiLmb0G/ILPVyQHYcjFQduIOoirTA9w34OZPUdfw",
  render_errors: [view: PlannerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Planner.PubSub,
  live_view: [signing_salt: "LL2G5/1K"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
