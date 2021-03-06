# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :iiif_works, IiifWorks.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "PtEEvRQYXRzFcW0xB+ixS6WsrjKYjPijuYcSNaJfu8DeEU8ZmalA7bv2MVWCxLnU",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: IiifWorks.PubSub,
           adapter: Phoenix.PubSub.PG2],
  solr_url: "http://localhost:8983/solr/hydra-development/select"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false
