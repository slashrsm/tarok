defmodule Tarok.GameStateTest do
  use ExUnit.Case

  test "need_to_move_hand_to_won/1" do
    full_hand = [
      :c7,
      :c8,
      :c9,
      :c10,
      :cJ,
      :cC,
      :cQ,
      :cK,
      :h4,
      :h3,
      :h2,
      :h1,
      :hJ,
      :hC,
      :hQ,
      :hK,
    ]

    assert false == Tarok.GameState.create_from_hand([]) |> Tarok.GameState.need_to_move_hand_to_won()
    assert true == Tarok.Card.includes_tarock([:i, :dK, :dQ])
    assert true == Tarok.Card.includes_tarock([:fool, :dK, :dQ])
    assert true == Tarok.Card.includes_tarock([:x, :dK, :dQ])
    assert true == Tarok.Card.includes_tarock([:x, :xi, :dQ])
    assert true == Tarok.Card.includes_tarock([:x, :xi, :xii])
  end

end
