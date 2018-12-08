defmodule Shiritorishi.Application do
  use Application
  alias Shiritorishi.Repo
  alias Shiritorishi.PublicReply
  import Ecto.Query, only: [order_by: 2, limit: 2]

  @public_replies_max_length 50

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

    :ok = Honeydew.start_queue(:my_queue)
    :ok = Honeydew.start_workers(:my_queue, ShiritorishiWeb.RoomChannel.Worker, num: 1)

    :ets.new(:public_replies, [:public, :named_table])
    :ets.insert(:public_replies, {"public_replies", get_public_replies()})

    link
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ShiritorishiWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def get_public_replies() do
    PublicReply
      |> order_by([desc: :id])
      |> limit(@public_replies_max_length)
      |> Repo.all
      |> Enum.sort_by(&(&1.id), &>=/2)
      |> Enum.map(&(PublicReply.take_info(&1)))
  end
end
