defmodule Tarok.CardTest do
  use ExUnit.Case

  test "includes_tarock/1" do
    assert false == Tarok.Card.includes_tarock([:d4, :dK, :dQ])
    assert true == Tarok.Card.includes_tarock([:i, :dK, :dQ])
    assert true == Tarok.Card.includes_tarock([:fool, :dK, :dQ])
    assert true == Tarok.Card.includes_tarock([:x, :dK, :dQ])
    assert true == Tarok.Card.includes_tarock([:x, :xi, :dQ])
    assert true == Tarok.Card.includes_tarock([:x, :xi, :xii])
  end

  test "get_tarocks_from_list/1" do
    assert [] == Tarok.Card.get_tarocks_from_list([:d4, :dK, :dQ])
    assert [:i] == Tarok.Card.get_tarocks_from_list([:i, :dK, :dQ])
    assert [:fool] == Tarok.Card.get_tarocks_from_list([:fool, :dK, :dQ])
    assert [:x] == Tarok.Card.get_tarocks_from_list([:x, :dK, :dQ])
    assert [:x, :xi] == Tarok.Card.get_tarocks_from_list([:x, :xi, :dQ])
    assert [:x, :xi, :xii] == Tarok.Card.get_tarocks_from_list([:x, :xi, :xii])
  end

  test "get_color/1" do
    assert :diamond == Tarok.Card.get_color(:d4)
    assert :heart == Tarok.Card.get_color(:hQ)
    assert :spade == Tarok.Card.get_color(:s7)
    assert :club == Tarok.Card.get_color(:c10)
    assert nil == Tarok.Card.get_color(:x)
  end

  test "get_color_from_list/2" do
    assert [:dK, :d1, :dJ] == Tarok.Card.get_color_from_list([:dK, :d1, :dJ], :diamond)
    assert [] == Tarok.Card.get_color_from_list([:dK, :d1, :dJ], :spade)
    assert [:hK, :h1] == Tarok.Card.get_color_from_list([:hK, :h1, :sJ], :heart)
    assert [:hK, :h1] == Tarok.Card.get_color_from_list([:hK, :h1, :x], :heart)
  end
end
