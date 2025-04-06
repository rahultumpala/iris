import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :iris, IrisWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "PALAnRNg7aBSVo6TIVVYDjqu4YkjivOsLOLRySE2pAU4DUlVVm5gJfzWfhvnCwYm",
  server: false

# In test we don't send emails
config :iris, Iris.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
