defmodule Tarok.GameState do
  alias Tarok.Card
  alias Tarok.Count
  alias Tarok.Rules

  defstruct [
    :game_type,
    :my_game,
    :hand,
    :won,
    :available_cards,
    :current_table,
    :my_buddy
  ]

  @type t :: %__MODULE__{
          game_type: nil | :klop | :standard,
          my_game: nil | boolean,
          hand: MapSet.t(),
          won: MapSet.t(),
          available_cards: MapSet.t(),
          current_table: [:atom],
          my_buddy: nil | 1 | 2
        }

  def create_from_hand(hand, game_type \\ nil, my_game \\ nil) do
    hand = MapSet.new(hand)
    all = MapSet.new(Card.get_all())
    %__MODULE__{
      game_type: game_type,
      my_game: my_game,
      hand: hand,
      won: MapSet.new(),
      available_cards: MapSet.difference(all, hand),
      current_table: [],
      my_buddy: nil
    }
  end

  @spec klop(Tarok.GameState.t()) :: Tarok.GameState.t()
  def klop(%__MODULE__{} = game), do: Map.put(game, :game_type, :klop)
  def standard(%__MODULE__{} = game), do: Map.put(game, :game_type, :standard)
  def my_game(%__MODULE__{} = game, true, _), do: %{game | my_game: true}

  def my_game(%__MODULE__{} = game, false, player) do
    %{game | my_game: true, my_buddy: if(player == 1, do: 2, else: 1)}
  end

  def need_to_move_hand_to_won(%__MODULE__{} = game), do: Enum.count(game.hand) > 16

  def add_to_hand(%__MODULE__{} = game, chunk),
    do: %{game | hand: MapSet.union(MapSet.new(chunk), game.hand), available_cards: MapSet.difference(game.available_cards, MapSet.new(chunk))}

  def remove_from_available(%__MODULE__{} = game, chunk),
    do: %{game | available_cards: MapSet.difference(game.available_cards, MapSet.new(chunk))}

  def add_to_won(%__MODULE__{} = game, chunk),
    do: %{game | won: MapSet.union(MapSet.new(chunk), game.won), available_cards: MapSet.difference(game.available_cards, MapSet.new(chunk))}

  def move_from_hand_to_won(%__MODULE__{} = game, card) do
    %{game | won: MapSet.put(game.won, card), hand: MapSet.delete(game.hand, card)}
  end

  def card_on_the_table(%__MODULE__{} = game, {player, card}, talon_card) do
    game = %{game | current_table: [{player, card} | game.current_table]}

    cond do
      Enum.count(game.current_table) < 3 ->
        game

      i_won_the_table(game) ->
        [{_, card3}, {_, card2}, {_, card1}] = game.current_table

        %{
          game
          | current_table: [],
            won: MapSet.union(game.won, MapSet.new([card3, card2, card1, talon_card])),
            available_cards:
              MapSet.difference(
                game.available_cards,
                MapSet.new([card3, card2, card1, talon_card])
              )
        }

      true ->
        [{_, card3}, {_, card2}, {_, card1}] = game.current_table

        %{
          game
          | current_table: [],
            available_cards:
              MapSet.difference(
                game.available_cards,
                MapSet.new([card3, card2, card1, talon_card])
              )
        }
    end
  end

  def card_on_the_table(%__MODULE__{} = game, {player, card}) do
    game = %{game | current_table: [{player, card} | game.current_table]}

    cond do
      Enum.count(game.current_table) < 3 ->
        game

      i_won_the_table(game) ->
        [{_, card3}, {_, card2}, {_, card1}] = game.current_table

        %{
          game
          | current_table: [],
            won: MapSet.union(game.won, MapSet.new([card3, card2, card1])),
            available_cards:
              MapSet.difference(game.available_cards, MapSet.new([card3, card2, card1]))
        }

      true ->
        [{_, card3}, {_, card2}, {_, card1}] = game.current_table

        %{
          game
          | current_table: [],
            available_cards:
              MapSet.difference(game.available_cards, MapSet.new([card3, card2, card1]))
        }
    end
  end

  def i_won_the_table(%__MODULE__{} = game) do
    my_buddy = game.my_buddy

    case Rules.who_won_table(game.current_table) do
      0 -> true
      ^my_buddy -> true
      _ -> false
    end
  end

  def available_tarock_count(%__MODULE__{available_cards: available}) do
    Card.get_tarocks()
    |> MapSet.new()
    |> MapSet.intersection(available)
    |> Enum.count()
  end

  def available_color_count(%__MODULE__{available_cards: available}, color) do
    available
    |> Card.get_color_from_list(color)
    |> Enum.count()
  end

  @spec get_stats(Tarok.GameState.t()) :: %{optional(<<_::16, _::_*8>>) => binary | number}
  def get_stats(%__MODULE__{} = game) do
    %{
      "T#" => available_tarock_count(game),
      "Curr. Score" => game.won |> MapSet.to_list() |> Count.get_score(),
      "♣" => available_color_count(game, :club),
      "♥" => available_color_count(game, :heart),
      "♠" => available_color_count(game, :spade),
      "♦" => available_color_count(game, :diamond),
      #"Av. Cards" =>
      #  Enum.map(game.available_cards, &Card.get_human_name(&1)) |> Enum.join(" ")
    }
  end
end
