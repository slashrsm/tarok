defmodule Tarok.Rules do
  alias Tarok.Card

  def who_won_table([{winner, :i}, {_, :xxi}, {_, :fool}]), do: winner
  def who_won_table([{winner, :i}, {_, :fool}, {_, :xxi}]), do: winner
  def who_won_table([{_, :fool}, {winner, :i}, {_, :xxi}]), do: winner
  def who_won_table([{_, :fool}, {_, :xxi}, {winner, :i}]), do: winner
  def who_won_table([{_, :xxi}, {_, :fool}, {winner, :i}]), do: winner
  def who_won_table([{_, :xxi}, {winner, :i}, {_, :fool}]), do: winner

  def who_won_table([{_, card3}, {_, card2}, {_, card1}] = table) do
    if [card3, card2, card1] |> Card.includes_tarock() do
      [winning_card | _] =
        [card3, card2, card1]
        |> Card.get_tarocks_from_list()
        |> Enum.sort(fn card1, card2 ->
          Card.get_strength()[card1] > Card.get_strength()[card2]
        end)

      get_winner_by_card(table, winning_card)
    else
      [winning_card | _] =
        [card3, card2, card1]
        |> Card.get_color_from_list(card1 |> Card.get_color())
        |> Enum.sort(fn card1, card2 ->
          Card.get_strength()[card1] > Card.get_strength()[card2]
        end)

      get_winner_by_card(table, winning_card)
    end
  end

  defp get_winner_by_card([{winner, card} | _], winning_card) when card == winning_card,
    do: winner

  defp get_winner_by_card([_ | rest], winning_card), do: get_winner_by_card(rest, winning_card)
end
