defmodule Tarok.SocketTest do
  use ExUnit.Case
  import Tarok.Socket

  # TODO this is a duplicate. Optimize
  @cards %{
    0x00 => "♣7",
    0x01 => "♣8",
    0x02 => "♣9",
    0x03 => "♣10",
    0x04 => "♣J",
    0x05 => "♣C",
    0x06 => "♣Q",
    0x07 => "♣K",
    0x08 => "♥4",
    0x09 => "♥3",
    0x0A => "♥2",
    0x0B => "♥1",
    0x0C => "♥J",
    0x0D => "♥C",
    0x0E => "♥Q",
    0x0F => "♥K",
    0x10 => "♠7",
    0x11 => "♠8",
    0x12 => "♠9",
    0x13 => "♠10",
    0x14 => "♠J",
    0x15 => "♠C",
    0x16 => "♠Q",
    0x17 => "♠K",
    0x18 => "♦4",
    0x19 => "♦3",
    0x1A => "♦2",
    0x1B => "♦1",
    0x1C => "♦J",
    0x1D => "♦C",
    0x1E => "♦Q",
    0x1F => "♦K",
    0x20 => "I",
    0x21 => "II",
    0x22 => "III",
    0x23 => "IIII",
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
    0x35 => "Fool"
  }

  @initial_hands [
    {"0001170000E16220250341580C00",
     "Got hand: ♣8 ♣C ♣Q ♥C ♠7 ♠9 ♠C ♦4 ♦3 I VII XII XIII XV XIX XX"},
    {"0001170000E11240081396520500",
     "Got hand: ♣8 ♣J ♥Q ♠10 ♦4 ♦3 ♦J II III V VIII X XIII XV XVII XIX"},
    {"0001170000E11240081396562500",
     "Got hand: ♣8 ♣J ♥Q ♠10 ♦4 ♦3 ♦J II III V VIII X XI XIII XV XVII XIX Fool"}
  ]

  @someone_played [
    {"00021900882201130000200100", "Player #1 plays I, [time?: 8822, 01]"},
    {"00021900852302130000350200", "Player #2 plays Fool, [time?: 8523, 02]"},
    {"000219008329031300001F0301", "Player #3 plays ♦K, end of round, [time?: 8329, 03]"}
  ]

  @someone_selected_talon [
    {"000219008855011C0000060035002F001800130001000A0200",
     "Player #1 (?) selected: Fool XVI, left: ♦4 ♠10 ♣8 ♥2"},
    {"000219008855011C0000060035002F001800130001000A0301",
     "Player #1 (?) selected: ♠10 ♣8 ♥2, left: Fool XVI ♦4"},
    {"000219008855011C0000060035002F001800130001000A0104",
     "Player #1 (?) selected: ♣8, left: Fool XVI ♦4 ♠10 ♥2"}
  ]

  @game_starts [
    {
      "0005020002000E0003A07530A07530A073AF020C0001080101170000E111030A882E1409000D000000C0463B410006A0C350020A000300A07B450B4A616E657A205572657663A0BD46810E01A51A6C0000040C5465BE056B6920506F6C64656BA11F6D3801000000050A5465BE056B69204C756A7AA1183D390100000002000000",
      "Game started. Got hand: ♣7 ♣J ♥4 ♥3 ♠8 ♠10 ♦1 ♦K II III IIII VI XI XIII XVII XX. [03A07530A07530A073AF020C0001080101170000E1, 0D000000C0463B410006A0C350020A000300A07B450B4A616E657A205572657663A0BD46810E01A51A6C0000040C5465BE056B6920506F6C64656BA11F6D3801000000050A5465BE056B69204C756A7AA1183D390100000002000000]"
    }
  ]

  @game_ended [
    {
      "00040900050C0F1A000300070102010000020002050000010200E1700000B2C28C0D00011500AF46B301130000100101",
      "Game ended. Player won the following cards: ♣J ♣C ♣Q ♦3 ♦J ♦C ♦K II VII VIII XI XII XVI XVII XIX XX. [050C0F1A0003000701020100000200020500000102, 011500AF46B301130000100101]"
    },
    {
      "00040900040C0F1A000400000002000100E1409E000421000000011500C064EEAB01130000300001",
      "Game ended. Player won the following cards: ♣Q ♥3 ♥2 ♥1 ♥J ♥K ♦2 I VI. [040C0F1A0004000000020001, 011500C064EEAB01130000300001]"
    },
    {
      ## Rezultat Klopa
      "00040900030C0F1A0002000300E16800A80040003D0000E180B710D70202020000E117484728BDFD00001500C0205D73011300001D0101",
      "Game ended. Player won the following cards: ♣10 ♣C ♣Q ♠10 ♠C ♠K VII XVII XIX XX XXI Fool. [030C0F1A00020003, 00E180B710D70202020000E117484728BDFD00001500C0205D73011300001D0101]"
    },
    {
      # Sucked badly... Won at the end C5D2 8500 0000 0000
      # Was playing solo 3, bet on trull
      # Won: ♣7 ♣10 ♣Q ♣K ♥3 ♥J ♥Q ♥K ♠7 ♠9 ♠K
      # Is 00C0 a delimiter?
      "00040900020C0F1A000300090103010000010005000001000500000000C085D2C5011500C066EDF301130000300101",
      "Game ended. Unknown message: 020C0F1A000300090103010000010005000001000500000000C085D2C5011500C066EDF301130000300101"
    },
    {
      "00030900010C0F1A0002000300E136EC3C104344390000E1C800822C9CA3020000E1000041C1001804001300000A0200",
      "Game ended. Player lost \"klop\": ♣8 ♣9 ♣J ♣C ♥2 ♥1 ♥C ♥Q ♥K ♠9 ♠10 ♠J ♠C ♦J I II VII XI XV XVII XX XXI Fool. [010C0F1A00020003, 00E1C800822C9CA3020000E1000041C1001804001300000A0200]"
    },
    {
      # Sucked badly... Won at the end 4007 C543 0000 0000
      # Won: ♣Q ♥4 ♥3 ♥2 ♠7 ♠9 ♠Q ♠K ♦4 ♦3 ♦Q
      # Is 00E0 a delimiter?
      "00050700030D0D0D0900000C0F1A00030009010401000001000500000003000001000400010000E04007C543011500C03B06AB01130000210101",
      "Game ended. Want to play more? Unknown message: 030D0D0D0900000C0F1A00030009010401000001000500000003000001000400010000E04007C543011500C03B06AB01130000210101"
    }
  ]

  @games [
    {"020001", "I play game: Beggar?"},
    {"020003", "I play game: Klop"},
    {"020004", "I play game: 4"},
    {"020005", "I play game: 5"},
    {"020006", "I play game: Pass"},
    {"020007", "I play game: Solo 1"},
    {"020008", "I play game: Solo 3"},
    {"020009", "I play game: Solo 2"},
    {"02000A", "I play game: Solo w/o"}
  ]

  @my_game_options [
    {"0001010005060907010A0106",
     "I am allowed to play games: Pass, Solo 2, Solo 1, Beggar?, Solo w/o. [rest: 0106]"},
    {"0001010005060907010A020609",
     "I am allowed to play games: Pass, Solo 2, Solo 1, Beggar?, Solo w/o. [rest: 020609]"},
    {"00010100040607010A0106",
      "I am allowed to play games: Pass, Solo 1, Beggar?, Solo w/o. [rest: 0106]"},
    {"000101000603080907010A020308",
      "I am allowed to play games: Klop, Solo 3, Solo 2, Solo 1, Beggar?, Solo w/o. [rest: 020308]"},
    {"000101000603080907010A0103",
      "I am allowed to play games: Klop, Solo 3, Solo 2, Solo 1, Beggar?, Solo w/o. [rest: 0103]"},
    {"000101000603080907010A020809",
      "I am allowed to play games: Klop, Solo 3, Solo 2, Solo 1, Beggar?, Solo w/o. [rest: 020809]"},
    {"000101000603080907010A0108",
      "I am allowed to play games: Klop, Solo 3, Solo 2, Solo 1, Beggar?, Solo w/o. [rest: 0108]"}
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
    Enum.each(
      @games,
      fn {message, expected} ->
        assert parse_message(Base.decode16!(message)) == expected
      end
    )
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

  test "parse_message game started" do
    Enum.each(
      @game_starts,
      fn {message, expected} ->
        assert parse_message(Base.decode16!(message)) == expected
      end
    )
  end

  test "parse_message game ended" do
    Enum.each(
      @game_ended,
      fn {message, expected} ->
        assert parse_message(Base.decode16!(message)) == expected
      end
    )
  end

  test "parse_message my possible games" do
    Enum.each(
      @my_game_options,
      fn {message, expected} ->
        assert parse_message(Base.decode16!(message)) == expected
      end
    )
  end
end
