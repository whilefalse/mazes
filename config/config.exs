# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :mazes, MazesWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "p3u61W74qzyqdl+czb5sM8jDyAN6zzwOs1bp5cOqb8OCVzrkK0BJAtay70R3CV3r",
  render_errors: [view: MazesWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Mazes.PubSub,
  live_view: [signing_salt: "PaxSsjvh"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
