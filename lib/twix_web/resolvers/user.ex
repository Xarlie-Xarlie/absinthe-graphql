defmodule TwixWeb.Resolvers.User do
  def get(%{id: id}, _context), do: Twix.get_user(id)
  def create(%{input: params}, _context), do: Twix.create_user(params)
  def update(%{input: params}, _context), do: Twix.update_user(params)
end
