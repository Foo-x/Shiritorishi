defmodule ShiritorishiWeb.PageController do
  use ShiritorishiWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
