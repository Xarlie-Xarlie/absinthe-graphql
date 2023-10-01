defmodule Twix do
  @moduledoc """
  Twix keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Twix.Users

  defdelegate create_user(params), to: Users.Create, as: :call
  defdelegate get_user(params), to: Users.Get, as: :call
  defdelegate update_user(params), to: Users.Update, as: :call
end
