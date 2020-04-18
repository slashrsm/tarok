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

  @someone_played_talon_added [
    {"00031900833A021300001904001300000E0201", "Player #2 plays ♥Q, talon contributes ♦3, end of round, [time?: 833A, collecting player?: 2, 00]"},
    {"0003190082C8011300000704001300001F0101", "Player #1 plays ♦K, talon contributes ♣K, end of round, [time?: 82C8, collecting player?: 1, 00]"},
    {"000319008224021300000D0400130000150001", "Player #0 plays ♠C, talon contributes ♥C, end of round, [time?: 8224, collecting player?: 2, 00]"},
    {"0003190082DA02130000350400130000330101", "Player #1 plays XX, talon contributes Fool, end of round, [time?: 82DA, collecting player?: 2, 00]"},
    {"0003190082FD001300002B04001300001C0101", "Player #1 plays ♦J, talon contributes XII, end of round, [time?: 82FD, collecting player?: 0, 00]"},
    {"0003190083A000130000040400130000090201", "Player #2 plays ♥3, talon contributes ♣J, end of round, [time?: 83A0, collecting player?: 0, 00]"},
    {"00031900825C01130000250400130000010201", "Player #2 plays ♣8, talon contributes VI, end of round, [time?: 825C, collecting player?: 1, 00]"},
    {"00031900820E00130000020400130000200001", "Player #0 plays I, talon contributes ♣9, end of round, [time?: 820E, collecting player?: 0, 00]"},
    {"000319008294021300002D0400130000320201", "Player #2 plays XIX, talon contributes XIV, end of round, [time?: 8294, collecting player?: 2, 00]"},
    {"00031900824B01130000300400130000160101", "Player #1 plays ♠Q, talon contributes XVII, end of round, [time?: 824B, collecting player?: 1, 00]"},
    {"000319008235001300002704001300001E0001", "Player #0 plays ♦Q, talon contributes VIII, end of round, [time?: 8235, collecting player?: 0, 00]"},
    {"000319008309021300000A04001300002F0201", "Player #2 plays XVI, talon contributes ♥2, end of round, [time?: 8309, collecting player?: 2, 00]"},
    {"000319008278011300002B04001300002F0001", "Player #0 plays XVI, talon contributes XII, end of round, [time?: 8278, collecting player?: 1, 00]"},
    {"00031900828A00130000340400130000290001", "Player #0 plays X, talon contributes XXI, end of round, [time?: 828A, collecting player?: 0, 00]"},
    {"0003190082D102130000090400130000130201", "Player #2 plays ♠10, talon contributes ♥3, end of round, [time?: 82D1, collecting player?: 2, 00]"},
    {"00031900828A001300002C0400130000140101", "Player #1 plays ♠J, talon contributes XIII, end of round, [time?: 828A, collecting player?: 0, 00]"},
    {"000319008325021300002A0400130000310201", "Player #2 plays XVIII, talon contributes XI, end of round, [time?: 8325, collecting player?: 2, 00]"},
    {"0003190082C7001300001C04001300000D0101", "Player #1 plays ♥C, talon contributes ♦J, end of round, [time?: 82C7, collecting player?: 0, 00]"},
    {"0003190082C501130000240400130000330101", "Player #1 plays XX, talon contributes V, end of round, [time?: 82C5, collecting player?: 1, 00]"},
    {"000319008228001300003204001300000F0001", "Player #0 plays ♥K, talon contributes XIX, end of round, [time?: 8228, collecting player?: 0, 00]"},
    {"0003190082F301130000220400130000130201", "Player #2 plays ♠10, talon contributes III, end of round, [time?: 82F3, collecting player?: 1, 00]"},
    {"00031900824F021300003404001300001C0001", "Player #0 plays ♦J, talon contributes XXI, end of round, [time?: 824F, collecting player?: 2, 00]"},
    {"00031900831D011300002604001300001F0101", "Player #1 plays ♦K, talon contributes VII, end of round, [time?: 831D, collecting player?: 1, 00]"},
    {"00031900829900130000350400130000060001", "Player #0 plays ♣Q, talon contributes Fool, end of round, [time?: 8299, collecting player?: 0, 00]"},
    {"0003190082A601130000290400130000090201", "Player #2 plays ♥3, talon contributes X, end of round, [time?: 82A6, collecting player?: 1, 00]"},
    {"00031900822A02130000320400130000150001", "Player #0 plays ♠C, talon contributes XIX, end of round, [time?: 822A, collecting player?: 2, 00]"},
    {"0003190082FD02130000030400130000330101", "Player #1 plays XX, talon contributes ♣10, end of round, [time?: 82FD, collecting player?: 2, 00]"},
    {"00031900832101130000350400130000060101", "Player #1 plays ♣Q, talon contributes Fool, end of round, [time?: 8321, collecting player?: 1, 00]"},
    {"000319008293021300001F0400130000010001", "Player #0 plays ♣8, talon contributes ♦K, end of round, [time?: 8293, collecting player?: 2, 00]"},
    {"000319008370001300002C0400130000180101", "Player #1 plays ♦4, talon contributes XIII, end of round, [time?: 8370, collecting player?: 0, 00]"},
    {"00031900826E001300002A0400130000310101", "Player #1 plays XVIII, talon contributes XI, end of round, [time?: 826E, collecting player?: 0, 00]"},
    {"0003190082BD00130000220400130000100201", "Player #2 plays ♠7, talon contributes III, end of round, [time?: 82BD, collecting player?: 0, 00]"},
    {"0003190082E102130000200400130000330201", "Player #2 plays XX, talon contributes I, end of round, [time?: 82E1, collecting player?: 2, 00]"},
    {"0003190082D8011300002C0400130000030101", "Player #1 plays ♣10, talon contributes XIII, end of round, [time?: 82D8, collecting player?: 1, 00]"},
    {"00031900823B00130000270400130000320001", "Player #0 plays XIX, talon contributes VIII, end of round, [time?: 823B, collecting player?: 0, 00]"},
    {"000319008350021300000E04001300002E0201", "Player #2 plays XV, talon contributes ♥Q, end of round, [time?: 8350, collecting player?: 2, 00]"}
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

  @messages [
    {"00010B000208646F62726F206A65", "Chat message from player #2: dobro je"},
    {"00010B000106526573206A65", "Chat message from player #1: Res je"},
    {"00010B0001085768617474747474", "Chat message from player #1: Whattttt"},
    {"00010B0001064D6F6A616161", "Chat message from player #1: Mojaaa"},
    {"00010B00010944656A206E6568616A", "Chat message from player #1: Dej nehaj"},
    {"00010B0002023A29", "Chat message from player #2: :)"},
    {"00010B0002066A65626F6761", "Chat message from player #2: jeboga"},
    {"00010B0000056861206861", "Chat message from player #0: ha ha"},
    {"00010B000007776F6F686F6F6F", "Chat message from player #0: woohooo"},
    {"00010B00020970697A64612076616D", "Chat message from player #2: pizda vam"},
    {"00010B0001074E656565656565", "Chat message from player #1: Neeeeee"},
    {"00010B000214756E20A1056B6973206D65206A65207A6A6562616C",
     "Chat message from player #2: un \xA1\x05kis me je zjebal"},
    {"00010B0002096A6F6A20766F6E676F", "Chat message from player #2: joj vongo"},
    {"00010B000003756621", "Chat message from player #0: uf!"},
    {"00010B0000077A61206D616C6F", "Chat message from player #0: za malo"},
    {"00010B0002117673616A20656E6F206269207072696D75",
     "Chat message from player #2: vsaj eno bi primu"},
    {"00010B0001064B616A6A6A6A", "Chat message from player #1: Kajjjj"},
    {"00010B00010D53656D206D656C203620737263", "Chat message from player #1: Sem mel 6 src"},
    {"00010B00001473656D20696D656C20736C616265206B61727465",
     "Chat message from player #0: sem imel slabe karte"},
    {"00010B0000146D6120707265646F627265207A61206B6C6F7061",
     "Chat message from player #0: ma predobre za klopa"},
    {"00010B00022B656E65207461726F6B65207369206D6F6775207072696D697420646120626920726573752070616C636B6F",
     "Chat message from player #2: ene taroke si mogu primit da bi resu palcko"},
    {"00010B0002023A29", "Chat message from player #2: :)"},
    {"00010B00000E696E206B616A206E616A2070696C", "Chat message from player #0: in kaj naj pil"},
    {"00010B000003706F6C", "Chat message from player #0: pol"},
    {"00010B000109546F206A6520726573", "Chat message from player #1: To je res"},
    {"00010B00001A6B6F6C6B20736920696D656C207461726F6B6F762070697A6461",
     "Chat message from player #0: kolk si imel tarokov pizda"},
    {"00010B0001044974616B", "Chat message from player #1: Itak"},
    {"00010B0002023A29", "Chat message from player #2: :)"},
    {"00010B00011E53656D20706F6E657372658D04696C2070727469736E6974206E617072656A",
     "Chat message from player #1: Sem ponesre\x8D\x04il prtisnit naprej"},
    {"00010B00000475666661", "Chat message from player #0: uffa"},
    {"00010B0000086A65627465207365", "Chat message from player #0: jebte se"},
    {"00010B0002023A29", "Chat message from player #2: :)"},
    {"00010B000211627261766F20766F6E676F203A29292929",
     "Chat message from player #2: bravo vongo :))))"},
    {"00010B00021E7A64656A2070612070726964652070657069206E6120767273746F212121",
     "Chat message from player #2: zdej pa pride pepi na vrsto!!!"}
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

  test "parse_message someone played and talon added" do
    Enum.each(
      @someone_played_talon_added,
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

  test "parse_message new message" do
    Enum.each(
      @messages,
      fn {message, expected} ->
        assert parse_message(Base.decode16!(message)) == expected
      end
    )
  end
end
