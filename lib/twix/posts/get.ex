defmodule Twix.Posts.Get do
  alias Twix.Posts.Post
  alias Twix.Repo
  import Ecto.Query

  def call(user, page, page_size) do
    from(p in Post, as: :p)
    |> where([p: p], p.user_id == ^user.id)
    |> limit(^page_size)
    |> offset((^page - 1) * ^page_size)
    |> Repo.all()
    |> then(&{:ok, &1})
  end
end
