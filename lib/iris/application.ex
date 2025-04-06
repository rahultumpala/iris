defmodule Iris.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      IrisWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:iris, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Iris.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Iris.Finch},
      # Start a worker by calling: Iris.Worker.start_link(arg)
      # {Iris.Worker, arg},
      # Start to serve requests, typically the last entry
      IrisWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Iris.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    IrisWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
