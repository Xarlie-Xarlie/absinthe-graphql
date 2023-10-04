defmodule Twix.Followers.Follow do
  alias Twix.Repo
  alias Twix.Users.User
  alias Twix.Followers.Follower

  def call(user_id, follower_id) do
    with {:ok, _user} <- get_user(user_id),
         {:ok, _follower} <- get_user(follower_id) do
      create_follwer(user_id, follower_id)
    end
  end

  defp create_follwer(user_id, follower_id) do
    %{following_id: user_id, follower_id: follower_id}
    |> Follower.changeset()
    |> Repo.insert()
  end

  defp get_user(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      %User{} = user -> {:ok, Repo.preload(user, :posts)}
    end
  end
end
