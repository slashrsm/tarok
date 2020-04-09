defmodule Tarok.Socket do
  @behaviour Phoenix.Socket.Transport
  require Logger
  use Bitwise

  @cards %{
    0x00 => "♣7",
    0x01 => "♣8",
    0x02 => "♣9",
    0x03 => "♣10",
    0x04 => "♣B",
    0x05 => "♣C",
    0x06 => "♣D",
    0x07 => "♣K",
    0x08 => "♥4",
    0x09 => "♥3",
    0x0A => "♥2",
    0x0B => "♥1",
    0x0C => "♥B",
    0x0D => "♥C",
    0x0E => "♥D",
    0x0F => "♥K",
    0x10 => "♠7",
    0x11 => "♠8",
    0x12 => "♠9",
    0x13 => "♠10",
    0x14 => "♠B",
    0x15 => "♠C",
    0x16 => "♠D",
    0x17 => "♠K",
    0x18 => "♦4",
    0x19 => "♦3",
    0x1A => "♦2",
    0x1B => "♦1",
    0x1C => "♦B",
    0x1D => "♦C",
    0x1E => "♦D",
    0x1F => "♦K",
    0x20 => "I",
    0x21 => "II",
    0x22 => "III",
    0x23 => "IV",
    0x24 => "V",
    0x25 => "VI",
    0x26 => "VII",
    0x27 => "VIII",
    0x28 => "IX",
    0x29 => "X",
    0x2A => "XI",
    0x2B => "XII",
    0x2C => "XIII",
    0x2D => "XIV",
    0x2E => "XV",
    0x2F => "XVI",
    0x30 => "XVII",
    0x31 => "XVIII",
    0x32 => "XIX",
    0x33 => "XX",
    0x34 => "XXI",
    0x35 => "Škis"
  }

  @color_hand_bits %{
    black: %{
      0x01 => "7",
      0x02 => "8",
      0x04 => "9",
      0x08 => "10",
      0x10 => "B",
      0x20 => "C",
      0x40 => "D",
      0x80 => "K"
    },
    red: %{
      0x01 => "4",
      0x02 => "3",
      0x04 => "2",
      0x08 => "1",
      0x10 => "B",
      0x20 => "C",
      0x40 => "D",
      0x80 => "K"
    }
  }

  @color_hand_bits %{
    black: %{
      0x01 => "7",
      0x02 => "8",
      0x04 => "9",
      0x08 => "10",
      0x10 => "B",
      0x20 => "C",
      0x40 => "D",
      0x80 => "K"
    },
    red: %{
      0x01 => "4",
      0x02 => "3",
      0x04 => "2",
      0x08 => "1",
      0x10 => "B",
      0x20 => "C",
      0x40 => "D",
      0x80 => "K"
    }
  }

  @tarock_hand_bits %{
    0x01 => 1,
    0x02 => 2,
    0x04 => 3,
    0x08 => 4,
    0x10 => 5,
    0x20 => 6,
    0x40 => 7,
    0x80 => 8
  }

  def child_spec(_opts) do
    %{id: Task, start: {Task, :start_link, [fn -> :ok end]}, restart: :transient}
  end

  def connect(_args) do
    {:ok, %{}}
  end

  def init(state) do
    {:ok, state}
  end

  def handle_in({<<0x01, msg::binary>>, _opts}, state) do
    Logger.info("Rx: #{parse_message(msg)}")
    # Logger.info("RxS: #{msg}")
    {:ok, state}
  end

  def handle_in({<<0x00, msg::binary>>, _opts}, state) do
    Logger.info("Tx: #{parse_message(msg)}")
    # Logger.info("TxS: #{msg}")
    {:ok, state}
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  def parse_message(<<0x09, 0x00, 0x00, card::size(8)>>) do
    "I play card: " <> @cards[card]
  end

  def parse_message(<<0x08, 0x00, set_nr::size(8)>>) do
    "From talon I take set ##{set_nr}"
  end

  def parse_message(<<0x02, 0x00, 0x06>>) do
    "I do not play any game."
  end

  def parse_message(<<0x02, 0x00, 0x09>>) do
    "I play game: solo 2"
  end

  def parse_message(<<0x02, 0x00, game_nr::size(8)>>) do
    "I play game: #{game_nr}"
  end

  def parse_message(
        <<0x00, 0x01, 0x17, 0x00, 0x00, 0x00E1, clubs::integer-size(8), hearts::integer-size(8),
          spades::integer-size(8), diamonds::integer-size(8), tarocks1::integer-size(8),
          tarocks2::integer-size(8), tarocks3::integer-size(8), 0x00>>
      ) do
    clubs =
      parse_hand_color(clubs, :black) |> Enum.map(fn card -> "♣" <> card end) |> Enum.join(" ")

    spades =
      parse_hand_color(spades, :black) |> Enum.map(fn card -> "♠" <> card end) |> Enum.join(" ")

    hearts =
      parse_hand_color(hearts, :red) |> Enum.map(fn card -> "♥" <> card end) |> Enum.join(" ")

    diamonds =
      parse_hand_color(diamonds, :red) |> Enum.map(fn card -> "♦" <> card end) |> Enum.join(" ")

    tarocks1 =
      parse_hand_tarock(tarocks1) |> Enum.map(fn card -> @cards[card + 31] end) |> Enum.join(" ")

    tarocks2 =
      parse_hand_tarock(tarocks2) |> Enum.map(fn card -> @cards[card + 39] end) |> Enum.join(" ")

    tarocks3 =
      parse_hand_tarock(tarocks3) |> Enum.map(fn card -> @cards[card + 47] end) |> Enum.join(" ")

    "Got hand: #{clubs} #{hearts} #{spades} #{diamonds} #{tarocks1} #{tarocks2} #{tarocks3}"
  end

  def parse_message(<<0x05, 0x00, 0x02>>) do
    "I do not make any bets."
  end

  def parse_message(
        <<0x00, 0x02, 0x19, 0x00, time?::binary-size(2), unknown::binary-size(1), 0x13, 0x00,
          0x00, card::size(8), player::size(8), round_end::size(8)>>
      ) do
    # Time is not in miliseconds.
    if round_end == 0 do
      "Player ##{player} plays " <>
        @cards[card] <> ", [time?: #{Base.encode16(time?)}, #{Base.encode16(unknown)}]"
    else
      "Player ##{player} plays " <>
        @cards[card] <>
        ", end of round, [time?: #{Base.encode16(time?)}, #{Base.encode16(unknown)}]"
    end
  end

  def parse_message(
        <<0x00, 0x02, 0x19, 0x00, _time?::size(16), player?::size(8), 0x1C, 0x00, 0x00, 0x06,
          0x00, card1::size(8), 0x00, card2::size(8), 0x00, card3::size(8), 0x00, card4::size(8),
          0x00, card5::size(8), 0x00, card6::size(8), group_size::size(8), selected::size(8)>>
      ) do
    talon =
      [card1, card2, card3, card4, card5, card6]
      |> Enum.chunk_every(group_size)

    selected_chunk =
      talon
      |> Enum.at(selected)
      |> Enum.map(fn card_id -> @cards[card_id] end)
      |> Enum.join(" ")

    left_chunks =
      talon
      |> List.delete_at(selected)
      |> List.flatten()
      |> Enum.map(fn card_id -> @cards[card_id] end)
      |> Enum.join(" ")

    "Player ##{player?} (?) selected: " <> selected_chunk <> ", left: " <> left_chunks
  end

  def parse_message(msg) do
    Base.encode16(msg) |> split_every_4()
  end

  defp split_every_4(""), do: ""

  defp split_every_4(str) do
    {part, rest} = String.split_at(str, 4)
    part <> " " <> split_every_4(rest)
  end

  defp parse_hand_color(hand, color) do
    @color_hand_bits[color]
    |> Enum.map(fn {bits, card} -> {bits &&& hand, card} end)
    |> Enum.filter(fn {present, _card} -> present > 0 end)
    |> Enum.map(fn {_, card} -> card end)
  end

  defp parse_hand_tarock(hand) do
    @tarock_hand_bits
    |> Enum.map(fn {bits, card} -> {bits &&& hand, card} end)
    |> Enum.filter(fn {present, _card} -> present > 0 end)
    |> Enum.map(fn {_, card} -> card end)
  end
end
