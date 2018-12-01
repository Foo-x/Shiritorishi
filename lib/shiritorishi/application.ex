defmodule Shiritorishi.Application do
  use Application
  alias Shiritorishi.Repo
  alias Shiritorishi.PublicReply
  import Ecto.Query, only: [order_by: 2, first: 1]

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Shiritorishi.Repo, []),
      # Start the endpoint when the application starts
      supervisor(ShiritorishiWeb.Endpoint, []),
      # Start your own worker by calling: Shiritorishi.Worker.start_link(arg1, arg2, arg3)
      # worker(Shiritorishi.Worker, [arg1, arg2, arg3]),
      ShiritorishiWeb.Presence
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Shiritorishi.Supervisor]
    link = Supervisor.start_link(children, opts)

    :ets.new(:public_replies, [:public, :named_table])
    :ets.insert(:public_replies, {"last_char", get_last_word_char()})

    link
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ShiritorishiWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def get_last_word_char() do
    PublicReply
      |> order_by([desc: :id])
      |> first
      |> Repo.one
      |> Map.get(:word)
      |> String.last
  end
end
