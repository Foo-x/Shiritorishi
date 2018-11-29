defmodule ShiritorishiWeb.PublicReplyView do
  use ShiritorishiWeb, :view

  def render("index.json", %{public_replies: public_replies}) do
    %{data: render_many(public_replies, ShiritorishiWeb.PublicReplyView, "public_reply.json")}
  end

  def render("public_reply.json", %{public_reply: public_reply}) do
    %{user: public_reply.user,
      word: public_reply.word}
  end
end
