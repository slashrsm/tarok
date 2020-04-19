defmodule Tarok.RulesTest do
  use ExUnit.Case

  test "who_won_table/1 for all honors" do
    assert 0 == Tarok.Rules.who_won_table([{0, :i}, {1, :xxi}, {2, :fool}])
    assert 1 == Tarok.Rules.who_won_table([{1, :i}, {2, :fool}, {0, :xxi}])
    assert 0 == Tarok.Rules.who_won_table([{2, :fool}, {0, :i}, {1, :xxi}])
    assert 2 == Tarok.Rules.who_won_table([{0, :fool}, {1, :xxi}, {2, :i}])
    assert 0 == Tarok.Rules.who_won_table([{1, :xxi}, {2, :fool}, {0, :i}])
    assert 1 == Tarok.Rules.who_won_table([{0, :xxi}, {1, :i}, {2, :fool}])
  end

  test "who_won_table/1 if includes honors" do
    assert 0 == Tarok.Rules.who_won_table([{0, :i}, {1, :d4}, {2, :d1}])
    assert 1 == Tarok.Rules.who_won_table([{1, :i}, {2, :sK}, {0, :sQ}])
    assert 2 == Tarok.Rules.who_won_table([{2, :fool}, {0, :i}, {1, :sK}])
    assert 0 == Tarok.Rules.who_won_table([{0, :fool}, {1, :h4}, {2, :i}])
    assert 1 == Tarok.Rules.who_won_table([{1, :xxi}, {2, :h1}, {0, :i}])
    assert 0 == Tarok.Rules.who_won_table([{0, :xxi}, {1, :hK}, {2, :hQ}])
    assert 0 == Tarok.Rules.who_won_table([{0, :xi}, {1, :v}, {2, :ii}])
  end

  test "who_won_table/1 if only colors" do
    assert 0 == Tarok.Rules.who_won_table([{1, :hQ}, {2, :d1}, {0, :hK}])
    assert 1 == Tarok.Rules.who_won_table([{1, :sK}, {2, :s10}, {0, :s7}])
    assert 2 == Tarok.Rules.who_won_table([{2, :s10}, {0, :s8}, {1, :s9}])
    assert 2 == Tarok.Rules.who_won_table([{0, :hK}, {1, :hQ}, {2, :s10}])
    assert 2 == Tarok.Rules.who_won_table([{1, :dK}, {2, :s10}, {0, :s7}])
  end
end
