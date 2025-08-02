defmodule T2chatbackend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      T2chatbackendWeb.Telemetry,
      T2chatbackend.Repo,
      {DNSCluster, query: Application.get_env(:t2chatbackend, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: T2chatbackend.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: T2chatbackend.Finch},
      # Start a worker by calling: T2chatbackend.Worker.start_link(arg)
      # {T2chatbackend.Worker, arg},
      # Start to serve requests, typically the last entry
      T2chatbackendWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: T2chatbackend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    T2chatbackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
