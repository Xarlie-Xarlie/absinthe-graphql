defmodule Twix.Posts.AddLike do
  alias Ecto.Changeset
  alias Twix.Posts.Post
  alias Twix.Repo

  def call(id) do
    case Repo.get(Post, id) do
      nil -> {:error, :not_found}
      post -> add_like(post)
    end
  end

  defp add_like(post) do
    Changeset.change(post, likes: post.likes + 1)
    |> Repo.update()
  end
end
