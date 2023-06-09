import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :accounts_management_api, AccountsManagementAPI.Repo,
  username: System.get_env("DB_USERNAME"),
  password: System.get_env("DB_PASSWORD"),
  hostname: System.get_env("DB_HOSTNAME"),
  database: "accounts_management_api_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :accounts_management_api, AccountsManagementAPIWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "YAlNEnICfq4za1vuz3Ewd3mOeFgeGBFP8khk6kExo41/e+t7MIhS+KfietpTVMV6",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

config :accounts_management_api, AccountsManagementAPIWeb.Auth.Guardian,
  secret_key: "SECRET_KEY_BASE"

# Configure argon2_elixir to speed up tests
config :argon2_elixir,
  t_cost: 1,
  m_cost: 8

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
