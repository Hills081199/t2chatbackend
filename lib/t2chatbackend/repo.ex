defmodule T2chatbackend.Repo do
  use Ecto.Repo,
    otp_app: :t2chatbackend,
    adapter: Ecto.Adapters.Postgres
end
