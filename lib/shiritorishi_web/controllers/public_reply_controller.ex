defmodule ShiritorishiWeb.PublicReplyController do
  use ShiritorishiWeb, :controller
  alias Shiritorishi.Repo
  alias Shiritorishi.PublicReply

  def index(conn, _params) do
    public_replies = Repo.all(PublicReply)
    render conn, public_replies: public_replies
  end
end
