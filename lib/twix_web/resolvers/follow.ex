defmodule TwixWeb.Resolvers.Follow do
  def follow(%{input: %{user_id: user_id, follower_id: follower_id}}, _context) do
    Twix.add_follower(user_id, follower_id)
  end
end
