# Accounts Management Lib

Manage users accounts Lib.
Allow to extract the dependency between app and accounts management.

## Model

```mermaid
erDiagram

    users {
        uuid id
        character_varying email
        character_varying password_hash
        character_varying name
        character_varying last_name
        character_varying picture
        character_varying locale
        character_varying status
        datetime start_date
        datetime confirmed_at
    }

    addresses {
        uuid id
        uuid user_id
        character_varying type
        character_varying name
        character_varying line_1
        character_varying line_2
        character_varying city
        character_varying state
        character_varying country_code
        character_varying zip_code
        bool default
    }

    phones {
        uuid id
        uuid user_id
        character_varying type
        character_varying name
        character_varying number
        bool default
        bool verified
    }

    users ||--|{ addresses : has
    users ||--|{ phones : has

```

## Dependencies

Not for now

## Include in your project


`mix.exs`

```elixir
defp deps do
[
  # ...
] ++ internal_deps()
end

defp internal_deps() do
  [
    # After dev things
    # {:accounts_management_api, "~> 0.1.0", git: "https://github.com/Taskero/accounts_management_api.git", branch: "main"},
    {:accounts_management_api, "~> 0.1.0", path: "../accounts_management_api"}
  ]
end
```

`config/config.exs`

```elixir
 import Config

 config :project,
-  ecto_repos: [Project.Repo],
+  ecto_repos: [Project.Repo, AccountsManagementAPI.Repo],

+config :accounts_management_api, AccountsManagementAPIWeb.Endpoint,
+  url: [host: "localhost"],
+  render_errors: [
+    formats: [json: AccountsManagementAPIWeb.ErrorJSON],
+    layout: false
+  ],
+  pubsub_server: AccountsManagementAPI.PubSub,
+  live_view: [signing_salt: "SOMETHING"]

+config :accounts_management_api, AccountsManagementAPI.Mailer, adapter: Swoosh.Adapters.Local
```

optional to get log from this

```elixir
+config :logger,
+   backends: [:console],
+   compile_time_purge_matching: [
+     [application: :accounts_management_api]
+   ]
```

`config/test.exs`

```elixir
+config :accounts_management_api, AccountsManagementAPI.Repo,
+  username: System.get_env("DB_USERNAME"),
+  password: System.get_env("DB_PASSWORD"),
+  hostname: System.get_env("DB_HOSTNAME"),
+  database: "db_test#{System.get_env("MIX_TEST_PARTITION")}",
+  pool: Ecto.Adapters.SQL.Sandbox,
+  pool_size: 10
+
+config :accounts_management_api, AccountsManagementAPIWeb.Auth.Guardian,
+  secret_key: "SECRET_KEY_BASE"
```


`config/dev.exs`

```elixir
config :accounts_management_api, AccountsManagementAPI.Repo,
   username: "postgres",
   password: "postgres",
   hostname: "localhost",
   database: "taskero_dev",
   stacktrace: true,
   show_sensitive_data_on_connection_error: true,
   pool_size: 10
```

`lib/project_web/router.ex` for rest API

```elixir
+  import AccountsManagementAPIWeb.UserAuth
+
+  pipeline :auth do
+    plug AccountsManagementAPIWeb.Auth.Pipeline
+  end
+
+  # API ####################
+
+  # Unsecure routes
+  scope "/api", AccountsManagementAPIWeb do
+    pipe_through :api
+
+    resources "/auth", AuthController, only: [:create]
+    resources "/auth/refresh", AuthController, only: [:create]
+    resources "/users", UserController, only: [:create]
+  end
+
+  # Secure routes
+  scope "/api", AccountsManagementAPIWeb do
+    pipe_through [:api, :auth]
+
+    resources "/users", UserController, only: [:index, :show, :update, :delete] do
+      resources("/addresses", AddressController, only: [:index, :create, :show, :update, :delete])
+      resources("/phones", PhoneController, only: [:index, :create, :show, :update, :delete])
+    end
+  end


+  # UI #################### (Live Views)
+
+  scope "/", AccountsManagementAPIWeb do
+    pipe_through([:browser])
+
+    delete("/users/log-out", UserSessionController, :delete)
+
+    live_session :current_user,
+      on_mount: [{AccountsManagementAPIWeb.UserAuth, :mount_current_user}] do
+      live("/users/confirm/:token", UserConfirmationLive, :edit)
+      live("/users/confirm", UserConfirmationInstructionsLive, :new)
+    end
+  end
+
+  ## Authentication routes
+
+  scope "/", AccountsManagementAPIWeb do
+    pipe_through([:browser, :redirect_if_user_is_authenticated])
+
+    live_session :redirect_if_user_is_authenticated,
+      on_mount: [{AccountsManagementAPIWeb.UserAuth, :redirect_if_user_is_authenticated}] do
+      live("/users/register", UserRegistrationLive, :new)
+      live("/users/log-in", UserLoginLive, :new)
+      live("/users/reset_password", UserForgotPasswordLive, :new)
+      live("/users/reset_password/:token", UserResetPasswordLive, :edit)
+    end
+
+    post("/users/log-in", UserSessionController, :create)
+  end
```

For testing create a [ExMachina Factory](https://github.com/thoughtbot/ex_machina) `/test/support/factories.ex`

```elixir
defmodule AccountsManagementAPI.Test.Factories do
+  use ExMachina.Ecto, repo: AccountsManagementAPI.Repo
+  alias AccountsManagementAPI.Accounts.{User, Address, Phone}
+
+  def user_factory do ... end
+  def address_factory do ... end
+  def phone_factory do ... end
end
```

create the test with:

```elixir
defmodule ExampleControllerTest do
  use ProjectWeb.ConnCase

  import AccountsManagementAPI.Test.Factories

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(AccountsManagementAPI.Repo)
  end
```

Happy coding 🐣 !
