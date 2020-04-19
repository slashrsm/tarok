defmodule Tarok.GameStats do
  use GenServer
  alias Tarok.GameState
  require Logger

  def new_game(hand), do: GenServer.call(GameStats, {:new_game, hand})
  def klop(), do: GenServer.call(GameStats, {:klop})
  def standard(), do: GenServer.call(GameStats, {:standard})
  def my_game(), do: GenServer.call(GameStats, {:my_game, true, nil})
  def their_game(next_player), do: GenServer.call(GameStats, {:my_game, false, next_player})
  def i_took_talon(chunk), do: GenServer.call(GameStats, {:my_talon, chunk})
  def they_left_talon(chunk), do: GenServer.call(GameStats, {:their_talon, chunk})
  def i_play_card(card), do: GenServer.call(GameStats, {:i_play, card})

  def card_on_the_table(card, player),
    do: GenServer.call(GameStats, {:card_on_the_table, [{player, card}]})

  @spec card_on_the_table(any, any, any) :: any
  def card_on_the_table(card, player, talon_card),
    do: GenServer.call(GameStats, {:card_on_the_table, [{player, card}], talon_card})

  ###
  # GenServer API
  ###

  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      %{game: nil, send_back: Keyword.get(opts, :send_back_stats, true)},
      name: GameStats
    )
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:new_game, hand}, from, state) do
    game = GameState.create_from_hand(hand)
    Logger.debug("New game: " <> inspect(game))
    {:reply, game, %{state | game: game}, {:continue, {:update_stats, from}}}
  end

  def handle_call({:klop}, from, state) do
    game = GameState.klop(state.game)
    Logger.debug("Klop: " <> inspect(game))
    {:reply, game, %{state | game: game}, {:continue, {:update_stats, from}}}
  end

  def handle_call({:standard}, from, state) do
    game = GameState.standard(state.game)
    Logger.debug("Standard: " <> inspect(game))
    {:reply, game, %{state | game: game}, {:continue, {:update_stats, from}}}
  end

  def handle_call({:my_game, is_my, who_plays}, from, state) do
    game = GameState.my_game(state.game, is_my, who_plays)
    Logger.debug("My game: " <> inspect(game))
    {:reply, game, %{state | game: game}, {:continue, {:update_stats, from}}}
  end

  def handle_call({:card_on_the_table, [{player, card}]}, from, state) do
    game = GameState.card_on_the_table(state.game, {player, card})
    Logger.debug("Card on the table: " <> inspect(game))
    {:reply, game, %{state | game: game}, {:continue, {:update_stats, from}}}
  end

  def handle_call({:card_on_the_table, [{player, card}], talon_card}, from, state) do
    game = GameState.card_on_the_table(state.game, {player, card}, talon_card)
    Logger.debug("Card on the table with talon: " <> inspect(game))
    {:reply, game, %{state | game: game}, {:continue, {:update_stats, from}}}
  end

  def handle_call({:my_talon, chunk}, from, state) do
    game = GameState.add_to_hand(state.game, chunk)
    Logger.debug("My talon: " <> inspect(game))
    {:reply, game, %{state | game: game}, {:continue, {:update_stats, from}}}
  end

  def handle_call({:their_talon, chunk}, from, state) do
    game = GameState.add_to_won(state.game, chunk)
    Logger.debug("Their talon: " <> inspect(game))
    {:reply, game, %{state | game: game}, {:continue, {:update_stats, from}}}
  end

  def handle_call({:i_play, card}, from, state) do
    game =
      if GameState.need_to_move_hand_to_won(state.game) do
        GameState.move_from_hand_to_won(state.game, card)
      else
        state.game
      end
    Logger.debug("I play: " <> inspect(game))

    {:reply, game, %{state | game: game}, {:continue, {:update_stats, from}}}
  end

  def handle_continue({:update_stats, {destination, _}}, state) do
    if state.send_back do
      Process.send(destination, GameState.get_stats(state.game), [])
    end

    {:noreply, state}
  end
end
