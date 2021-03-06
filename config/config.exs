# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :shiritorishi,
  ecto_repos: [Shiritorishi.Repo]

# Configures the endpoint
config :shiritorishi, ShiritorishiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "+VUgScXiW+whLXpcYumR7onjR7eggdDFs+cuvJJt7MIMtwZu58iXUj3FeEze9iZx",
  render_errors: [view: ShiritorishiWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Shiritorishi.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :phoenix, :json_library, Jason

config :shiritorishi, ShiritorishiWeb.Gettext, default_locale: "ja"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
