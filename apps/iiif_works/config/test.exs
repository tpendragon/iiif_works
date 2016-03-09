use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :iiif_works, IiifWorks.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :iiif_works, IiifWorks.Repo,
  adapter: Fedora.Ecto,
  url: "http://localhost:8984/rest",
  ldp_root: "testing",
  pool_size: 10
