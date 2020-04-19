defmodule Tarok.Count do
  @cards_value %{
    :c7 => 1,
    :c8 => 1,
    :c9 => 1,
    :c10 => 1,
    :cJ => 2,
    :cC => 3,
    :cQ => 4,
    :cK => 5,
    :h4 => 1,
    :h3 => 1,
    :h2 => 1,
    :h1 => 1,
    :hJ => 2,
    :hC => 3,
    :hQ => 4,
    :hK => 5,
    :s7 => 1,
    :s8 => 1,
    :s9 => 1,
    :s10 => 1,
    :sJ => 2,
    :sC => 3,
    :sQ => 4,
    :sK => 5,
    :d4 => 1,
    :d3 => 1,
    :d2 => 1,
    :d1 => 1,
    :dJ => 2,
    :dC => 3,
    :dQ => 4,
    :dK => 5,
    :i => 5,
    :ii => 1,
    :iii => 1,
    :iiii => 1,
    :v => 1,
    :vi => 1,
    :vii => 1,
    :viii => 1,
    :ix => 1,
    :x => 1,
    :xi => 1,
    :xii => 1,
    :xiii => 1,
    :xiv => 1,
    :xv => 1,
    :xvi => 1,
    :xvii => 1,
    :xviii => 1,
    :xix => 1,
    :xx => 1,
    :xxi => 5,
    :fool => 5
  }

  def get_score(cards) do
    cards
    |> Enum.chunk_every(3)
    |> Enum.map(&get_score_for_chunk/1)
    |> Enum.sum()
  end

  def get_score_for_chunk(chunk) when length(chunk) < 3 do
    {_scores, final_score} =
      Enum.map_reduce(chunk, 0, fn card, score ->
        {@cards_value[card], @cards_value[card] + score}
      end)

    final_score - 1
  end

  def get_score_for_chunk(chunk) do
    {_scores, final_score} =
      Enum.map_reduce(chunk, 0, fn card, score ->
        {@cards_value[card], @cards_value[card] + score}
      end)

    final_score - 2
  end
end
