defmodule Tarok.Count do
  @cards_value %{
    0x00 => 1,
    0x01 => 1,
    0x02 => 1,
    0x03 => 1,
    0x04 => 2,
    0x05 => 3,
    0x06 => 4,
    0x07 => 5,
    0x08 => 1,
    0x09 => 1,
    0x0A => 1,
    0x0B => 1,
    0x0C => 2,
    0x0D => 3,
    0x0E => 4,
    0x0F => 5,
    0x10 => 1,
    0x11 => 1,
    0x12 => 1,
    0x13 => 1,
    0x14 => 2,
    0x15 => 3,
    0x16 => 4,
    0x17 => 5,
    0x18 => 1,
    0x19 => 1,
    0x1A => 1,
    0x1B => 1,
    0x1C => 2,
    0x1D => 3,
    0x1E => 4,
    0x1F => 5,
    0x20 => 5,
    0x21 => 1,
    0x22 => 1,
    0x23 => 1,
    0x24 => 1,
    0x25 => 1,
    0x26 => 1,
    0x27 => 1,
    0x28 => 1,
    0x29 => 1,
    0x2A => 1,
    0x2B => 1,
    0x2C => 1,
    0x2D => 1,
    0x2E => 1,
    0x2F => 1,
    0x30 => 1,
    0x31 => 1,
    0x32 => 1,
    0x33 => 1,
    0x34 => 5,
    0x35 => 5
  }

  def get_score(cards) do
    cards
    |> Enum.chunk_every(3)
    |> Enum.map(&get_score_for_chunk/1)
    |> Enum.sum()
  end

  def get_score_for_chunk(chunk) when length(chunk) < 3 do
    {_scores, final_score} =
      Enum.map_reduce(chunk, 0, fn card_id, score ->
        {@cards_value[card_id], @cards_value[card_id] + score}
      end)

    final_score - 1
  end

  def get_score_for_chunk(chunk) do
    {_scores, final_score} =
      Enum.map_reduce(chunk, 0, fn card_id, score ->
        {@cards_value[card_id], @cards_value[card_id] + score}
      end)

    final_score - 2
  end
end
