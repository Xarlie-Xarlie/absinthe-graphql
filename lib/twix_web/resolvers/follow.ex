defmodule TwixWeb.Resolvers.Follow do
  def follow(%{input: %{user_id: user_id, follower_id: follower_id}}, _context) do
    case Twix.add_follower(user_id, follower_id) do
      {:ok, result} ->
        Absinthe.Subscription.publish(TwixWeb.Endpoint, result, new_follow: "new_follow_topic")
        {:ok, result}

      error ->
        error
    end
  end
end
