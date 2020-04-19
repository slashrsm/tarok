defmodule Tarok do
  @moduledoc """
  Tarok keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  use Application

  def start(_type, _args) do
    Supervisor.start_link(
      [
        %{
          id: GameStats,
          start: {Tarok.GameStats, :start_link, []}
        }
      ],
      strategy: :one_for_one
    )
  end
end
