# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Load .env file if it exists
if File.exists?(".env") do
  File.stream!(".env")
  |> Stream.map(&String.trim/1)
  |> Stream.map(fn line ->
    case String.split(line, "=", parts: 2) do
      [key, value] -> {key, String.trim(value, "\"")}
      _ -> nil
    end
  end)
  |> Stream.reject(&is_nil/1)
  |> Enum.each(fn {key, value} ->
    System.put_env(key, value)
  end)
end


config :t2chatbackend,
  ecto_repos: [T2chatbackend.Repo],
  generators: [timestamp_type: :utc_datetime]

config :t2chatbackend, :supabase,
  supabase_url: System.get_env("SUPABASE_URL") || "your-supabase-url",
  supabase_service_key: System.get_env("SUPABASE_SERVICE_ROLE_KEY") || "your-service-role-key"

# Configures the endpoint
config :t2chatbackend, T2chatbackendWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: T2chatbackendWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: T2chatbackend.PubSub,
  live_view: [signing_salt: "RBLh+JCq"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :t2chatbackend, T2chatbackend.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  t2chatbackend: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  t2chatbackend: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
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
