defmodule Tarok.SocketTest do
  use ExUnit.Case
  import Tarok.Socket

  # TODO this is a duplicate. Optimize
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

  @initial_hands [
    {"0001170000E16220250341580C00",
     "Got hand: ♣8 ♣C ♣D ♥C ♠7 ♠9 ♠C ♦4 ♦3 I VII XII XIII XV XIX XX"},
    {"0001170000E11240081396520500",
     "Got hand: ♣8 ♣B ♥D ♠10 ♦4 ♦3 ♦B II III V VIII X XIII XV XVII XIX"},
    {"0001170000E11240081396562500",
     "Got hand: ♣8 ♣B ♥D ♠10 ♦4 ♦3 ♦B II III V VIII X XI XIII XV XVII XIX Škis"}
  ]

  @someone_played [
    {"00021900882201130000200100", "Player #1 plays I, [time?: 8822, 01]"},
    {"00021900852302130000350200", "Player #2 plays Škis, [time?: 8523, 02]"},
    {"000219008329031300001F0301", "Player #3 plays ♦K, end of round, [time?: 8329, 03]"}
  ]

  @someone_selected_talon [
    {"000219008855011C0000060035002F001800130001000A0200",
     "Player #1 (?) selected: Škis XVI, left: ♦4 ♠10 ♣8 ♥2"},
    {"000219008855011C0000060035002F001800130001000A0301",
     "Player #1 (?) selected: ♠10 ♣8 ♥2, left: Škis XVI ♦4"},
    {"000219008855011C0000060035002F001800130001000A0104",
     "Player #1 (?) selected: ♣8, left: Škis XVI ♦4 ♠10 ♥2"}
  ]

  test "parse_message with initial hand of cards" do
    Enum.each(
      @initial_hands,
      fn {message, expected} ->
        assert parse_message(Base.decode16!(message)) == expected
      end
    )
  end

  test "parse_message me playing a card" do
    Enum.each(
      @cards,
      fn {code, card} ->
        assert parse_message(<<0x09, 0x00, 0x00, code::size(8)>>) == "I play card: #{card}"
      end
    )
  end

  test "parse_message me taking a set from talon" do
    assert parse_message(<<0x08, 0x00, 1::size(8)>>) == "From talon I take set #1"
    assert parse_message(<<0x08, 0x00, 2::size(8)>>) == "From talon I take set #2"
    assert parse_message(<<0x08, 0x00, 3::size(8)>>) == "From talon I take set #3"
    assert parse_message(<<0x08, 0x00, 4::size(8)>>) == "From talon I take set #4"
    assert parse_message(<<0x08, 0x00, 5::size(8)>>) == "From talon I take set #5"
    assert parse_message(<<0x08, 0x00, 6::size(8)>>) == "From talon I take set #6"
  end

  test "parse_message I play a game (or not)" do
    assert parse_message(<<0x02, 0x00, 0x06>>) == "I do not play any game."
    assert parse_message(<<0x02, 0x00, 0x09>>) == "I play game: solo 2"
  end

  test "parse_message I bet (or not)" do
    assert parse_message(<<0x05, 0x00, 0x02>>) == "I do not make any bets."
  end

  test "parse_message someone played" do
    Enum.each(
      @someone_played,
      fn {message, expected} ->
        assert parse_message(Base.decode16!(message)) == expected
      end
    )
  end

  test "parse_message someone selected a chunk from talon" do
    Enum.each(
      @someone_selected_talon,
      fn {message, expected} ->
        assert parse_message(Base.decode16!(message)) == expected
      end
    )
  end
end
