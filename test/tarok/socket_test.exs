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
    {"00031900833A021300001904001300000E0201",
     "Player #2 plays ♥Q, talon contributes ♦3, end of round, [time?: 833A, collecting player?: 2, 00]"},
    {"0003190082C8011300000704001300001F0101",
     "Player #1 plays ♦K, talon contributes ♣K, end of round, [time?: 82C8, collecting player?: 1, 00]"},
    {"000319008224021300000D0400130000150001",
     "Player #0 plays ♠C, talon contributes ♥C, end of round, [time?: 8224, collecting player?: 2, 00]"},
    {"0003190082DA02130000350400130000330101",
     "Player #1 plays XX, talon contributes Fool, end of round, [time?: 82DA, collecting player?: 2, 00]"},
    {"0003190082FD001300002B04001300001C0101",
     "Player #1 plays ♦J, talon contributes XII, end of round, [time?: 82FD, collecting player?: 0, 00]"},
    {"0003190083A000130000040400130000090201",
     "Player #2 plays ♥3, talon contributes ♣J, end of round, [time?: 83A0, collecting player?: 0, 00]"},
    {"00031900825C01130000250400130000010201",
     "Player #2 plays ♣8, talon contributes VI, end of round, [time?: 825C, collecting player?: 1, 00]"},
    {"00031900820E00130000020400130000200001",
     "Player #0 plays I, talon contributes ♣9, end of round, [time?: 820E, collecting player?: 0, 00]"},
    {"000319008294021300002D0400130000320201",
     "Player #2 plays XIX, talon contributes XIV, end of round, [time?: 8294, collecting player?: 2, 00]"},
    {"00031900824B01130000300400130000160101",
     "Player #1 plays ♠Q, talon contributes XVII, end of round, [time?: 824B, collecting player?: 1, 00]"},
    {"000319008235001300002704001300001E0001",
     "Player #0 plays ♦Q, talon contributes VIII, end of round, [time?: 8235, collecting player?: 0, 00]"},
    {"000319008309021300000A04001300002F0201",
     "Player #2 plays XVI, talon contributes ♥2, end of round, [time?: 8309, collecting player?: 2, 00]"},
    {"000319008278011300002B04001300002F0001",
     "Player #0 plays XVI, talon contributes XII, end of round, [time?: 8278, collecting player?: 1, 00]"},
    {"00031900828A00130000340400130000290001",
     "Player #0 plays X, talon contributes XXI, end of round, [time?: 828A, collecting player?: 0, 00]"},
    {"0003190082D102130000090400130000130201",
     "Player #2 plays ♠10, talon contributes ♥3, end of round, [time?: 82D1, collecting player?: 2, 00]"},
    {"00031900828A001300002C0400130000140101",
     "Player #1 plays ♠J, talon contributes XIII, end of round, [time?: 828A, collecting player?: 0, 00]"},
    {"000319008325021300002A0400130000310201",
     "Player #2 plays XVIII, talon contributes XI, end of round, [time?: 8325, collecting player?: 2, 00]"},
    {"0003190082C7001300001C04001300000D0101",
     "Player #1 plays ♥C, talon contributes ♦J, end of round, [time?: 82C7, collecting player?: 0, 00]"},
    {"0003190082C501130000240400130000330101",
     "Player #1 plays XX, talon contributes V, end of round, [time?: 82C5, collecting player?: 1, 00]"},
    {"000319008228001300003204001300000F0001",
     "Player #0 plays ♥K, talon contributes XIX, end of round, [time?: 8228, collecting player?: 0, 00]"},
    {"0003190082F301130000220400130000130201",
     "Player #2 plays ♠10, talon contributes III, end of round, [time?: 82F3, collecting player?: 1, 00]"},
    {"00031900824F021300003404001300001C0001",
     "Player #0 plays ♦J, talon contributes XXI, end of round, [time?: 824F, collecting player?: 2, 00]"},
    {"00031900831D011300002604001300001F0101",
     "Player #1 plays ♦K, talon contributes VII, end of round, [time?: 831D, collecting player?: 1, 00]"},
    {"00031900829900130000350400130000060001",
     "Player #0 plays ♣Q, talon contributes Fool, end of round, [time?: 8299, collecting player?: 0, 00]"},
    {"0003190082A601130000290400130000090201",
     "Player #2 plays ♥3, talon contributes X, end of round, [time?: 82A6, collecting player?: 1, 00]"},
    {"00031900822A02130000320400130000150001",
     "Player #0 plays ♠C, talon contributes XIX, end of round, [time?: 822A, collecting player?: 2, 00]"},
    {"0003190082FD02130000030400130000330101",
     "Player #1 plays XX, talon contributes ♣10, end of round, [time?: 82FD, collecting player?: 2, 00]"},
    {"00031900832101130000350400130000060101",
     "Player #1 plays ♣Q, talon contributes Fool, end of round, [time?: 8321, collecting player?: 1, 00]"},
    {"000319008293021300001F0400130000010001",
     "Player #0 plays ♣8, talon contributes ♦K, end of round, [time?: 8293, collecting player?: 2, 00]"},
    {"000319008370001300002C0400130000180101",
     "Player #1 plays ♦4, talon contributes XIII, end of round, [time?: 8370, collecting player?: 0, 00]"},
    {"00031900826E001300002A0400130000310101",
     "Player #1 plays XVIII, talon contributes XI, end of round, [time?: 826E, collecting player?: 0, 00]"},
    {"0003190082BD00130000220400130000100201",
     "Player #2 plays ♠7, talon contributes III, end of round, [time?: 82BD, collecting player?: 0, 00]"},
    {"0003190082E102130000200400130000330201",
     "Player #2 plays XX, talon contributes I, end of round, [time?: 82E1, collecting player?: 2, 00]"},
    {"0003190082D8011300002C0400130000030101",
     "Player #1 plays ♣10, talon contributes XIII, end of round, [time?: 82D8, collecting player?: 1, 00]"},
    {"00031900823B00130000270400130000320001",
     "Player #0 plays XIX, talon contributes VIII, end of round, [time?: 823B, collecting player?: 0, 00]"},
    {"000319008350021300000E04001300002E0201",
     "Player #2 plays XV, talon contributes ♥Q, end of round, [time?: 8350, collecting player?: 2, 00]"}
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
      "Game started, Got hand: ♣7 ♣J ♥4 ♥3 ♠8 ♠10 ♦1 ♦K II III IIII VI XI XIII XVII XX, player #2 negotiates first, player #1 has solo 3, [gibberish: 7530A07530A073AF, 0D000000C0463B410006A0C350020A000300A07B450B4A616E657A205572657663A0BD46810E01A51A6C0000040C5465BE056B6920506F6C64656BA11F6D3801000000050A5465BE056B69204C756A7AA1183D390100000002000000]"
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

  @klop_game_started [
    {"0004190082090012020001030306060C0000030101",
     "Klop started by player #0. [time?: 8209, next player: 1]"},
    {"0004190081CA0012020001030306060C0000030101",
     "Klop started by player #0. [time?: 81CA, next player: 1]"},
    {"0004190082450112020002030306060C0001030101",
     "Klop started by player #1. [time?: 8245, next player: 2]"},
    {"0004190082970212020000030306060C0002030101",
     "Klop started by player #2. [time?: 8297, next player: 0]"},
    {"00041900822F0012020001030306060C0000030101",
     "Klop started by player #0. [time?: 822F, next player: 1]"},
    {"0004190082790212020000030306060C0002030101",
     "Klop started by player #2. [time?: 8279, next player: 0]"}
  ]

  @game_negotiation_begins [
    {"0003020000000E0003A0CC49A0D8D8A0C399000C0002080101",
     "Game negotiation, player #0 negotiates first, player #2 has solo 3, [CC49A0D8D8A0C399]"},
    {"0003020001000E0003A0D538A0F5CBA1077E010C0000080101",
     "Game negotiation, player #1 negotiates first, player #0 has solo 3, [D538A0F5CBA1077E]"},
    {"0003020002000E0003A0CE08A10C45A116A3020C0001080101",
     "Game negotiation, player #2 negotiates first, player #1 has solo 3, [CE08A10C45A116A3]"},
    {"0003020000000E0003A0D0DEA1199FA10A23000C0002080101",
     "Game negotiation, player #0 negotiates first, player #2 has solo 3, [D0DEA1199FA10A23]"},
    {"0003020001000E0003A0DEE5A114C9A127DD010C0000080101",
     "Game negotiation, player #1 negotiates first, player #0 has solo 3, [DEE5A114C9A127DD]"},
    {"0003020002000E0003A0E298A0F9E3A10FB7020C0001080101",
     "Game negotiation, player #2 negotiates first, player #1 has solo 3, [E298A0F9E3A10FB7]"},
    {"0003020000000E0003A0BF13A0D856A0F4D6000C0002080101",
     "Game negotiation, player #0 negotiates first, player #2 has solo 3, [BF13A0D856A0F4D6]"},
    {"0003020001000E0003A0D48CA0EF7EA0EA97010C0000080101",
     "Game negotiation, player #1 negotiates first, player #0 has solo 3, [D48CA0EF7EA0EA97]"},
    {"0003020002000E0003A0F16AA0F280A10ABA020C0001080101",
     "Game negotiation, player #2 negotiates first, player #1 has solo 3, [F16AA0F280A10ABA]"},
    {"0003020000000E0003A0E851A0F1D9A0F6A8000C0002080101",
     "Game negotiation, player #0 negotiates first, player #2 has solo 3, [E851A0F1D9A0F6A8]"},
    {"0003020001000E0003A0D469A10143A0F328010C0000080101",
     "Game negotiation, player #1 negotiates first, player #0 has solo 3, [D469A10143A0F328]"},
    {"0003020002000E0003A0C6EBA0FAB0A0FA96020C0001080101",
     "Game negotiation, player #2 negotiates first, player #1 has solo 3, [C6EBA0FAB0A0FA96]"},
    {"0003020000000E0003A0E164A0F27DA0F195000C0002080101",
     "Game negotiation, player #0 negotiates first, player #2 has solo 3, [E164A0F27DA0F195]"},
    {"0003020001000E0003A0F1E0A0E0A6A115A8010C0000080101",
     "Game negotiation, player #1 negotiates first, player #0 has solo 3, [F1E0A0E0A6A115A8]"},
    {"0003020002000E0003A0F917A0E2FEA12484020C0001080101",
     "Game negotiation, player #2 negotiates first, player #1 has solo 3, [F917A0E2FEA12484]"},
    {"0003020000000E0003A0D0BCA0FDB4A104FB000C0002080101",
     "Game negotiation, player #0 negotiates first, player #2 has solo 3, [D0BCA0FDB4A104FB]"},
    {"0003020001000E0003A0F5B7A0FDBEA102FA010C0000080101",
     "Game negotiation, player #1 negotiates first, player #0 has solo 3, [F5B7A0FDBEA102FA]"},
    {"0003020002000E0003A0DFDAA0FF5AA10EC6020C0001080101",
     "Game negotiation, player #2 negotiates first, player #1 has solo 3, [DFDAA0FF5AA10EC6]"},
    {"0003020000000E0003A0E928A10BF3A0FBF0000C0002080101",
     "Game negotiation, player #0 negotiates first, player #2 has solo 3, [E928A10BF3A0FBF0]"},
    {"0003020001000E0003A0E641A0FE95A0EE3D010C0000080101",
     "Game negotiation, player #1 negotiates first, player #0 has solo 3, [E641A0FE95A0EE3D]"},
    {"0003020002000E0003A0FED6A0FC99A1101E020C0001080101",
     "Game negotiation, player #2 negotiates first, player #1 has solo 3, [FED6A0FC99A1101E]"},
    {"0003020001000E0003A0F1FDA0EF02A11314010C0000080101",
     "Game negotiation, player #1 negotiates first, player #0 has solo 3, [F1FDA0EF02A11314]"},
    {"0003020002000E0003A0D2AAA0FDC7A103F5020C0001080101",
     "Game negotiation, player #2 negotiates first, player #1 has solo 3, [D2AAA0FDC7A103F5]"},
    {"0003020000000E0003A0E1CEA105F0A0F502000C0002080101",
     "Game negotiation, player #0 negotiates first, player #2 has solo 3, [E1CEA105F0A0F502]"},
    {"0003020001000E0003A0CF27A0E8AEA0EA87010C0000080101",
     "Game negotiation, player #1 negotiates first, player #0 has solo 3, [CF27A0E8AEA0EA87]"},
    {"0003020002000E0003A0DFA1A0F6F4A108D8020C0001080101",
     "Game negotiation, player #2 negotiates first, player #1 has solo 3, [DFA1A0F6F4A108D8]"},
    {"0003020000000E0003A0F281A10B1DA10AED000C0002080101",
     "Game negotiation, player #0 negotiates first, player #2 has solo 3, [F281A10B1DA10AED]"},
    {"0003020001000E0003A0EB48A10B58A113D1010C0000080101",
     "Game negotiation, player #1 negotiates first, player #0 has solo 3, [EB48A10B58A113D1]"},
    {"0003020002000E0003A0E6AEA113BAA10085020C0001080101",
     "Game negotiation, player #2 negotiates first, player #1 has solo 3, [E6AEA113BAA10085]"},
    {"0003020000000E0003A0F166A10218A10B77000C0002080101",
     "Game negotiation, player #0 negotiates first, player #2 has solo 3, [F166A10218A10B77]"},
    {"0003020001000E0003A0DF49A0FFC6A10B29010C0000080101",
     "Game negotiation, player #1 negotiates first, player #0 has solo 3, [DF49A0FFC6A10B29]"},
    {"0003020002000E0003A0E914A10B47A11524020C0001080101",
     "Game negotiation, player #2 negotiates first, player #1 has solo 3, [E914A10B47A11524]"},
    {"0003020002000E0003A0EEA2A11059A11A3D020C0001080101",
     "Game negotiation, player #2 negotiates first, player #1 has solo 3, [EEA2A11059A11A3D]"},
    {"0003020000000E0003A0F8A9A10A0EA11FC4000C0002080101",
     "Game negotiation, player #0 negotiates first, player #2 has solo 3, [F8A9A10A0EA11FC4]"}
  ]

  @game_negotiation_round [
    {"0002190080A6000200020106",
     "Game negotiation, next to negotiate is player 0, first to negotiate was player #2, current bets: Pass, [time?: 80A6]"},
    {"00021900812301020002020606",
     "Game negotiation, next to negotiate is player 1, first to negotiate was player #2, current bets: Pass-Pass, [time?: 8123]"},
    {"0003190081CF0102000001090C0000090101",
     "Game negotiation, next to negotiate is player 1, first to negotiate was player #0, current bets: Solo 2, current game is Solo 2 by player #0, [time?: 81CF]"},
    {"00021900823E02020000020609",
     "Game negotiation, next to negotiate is player 2, first to negotiate was player #0, current bets: Pass-Solo 2, [time?: 823E]"},
    {"00031900820300020000030906090C0002090101",
     "Game negotiation, next to negotiate is player 0, first to negotiate was player #0, current bets: Solo 2-Pass-Solo 2, current game is Solo 2 by player #2, [time?: 8203]"},
    {"000219008269020200010106",
     "Game negotiation, next to negotiate is player 2, first to negotiate was player #1, current bets: Pass, [time?: 8269]"},
    {"0002190082AA00020001020606",
     "Game negotiation, next to negotiate is player 0, first to negotiate was player #1, current bets: Pass-Pass, [time?: 82AA]"},
    {"0003190082C70002000201090C0002090101",
     "Game negotiation, next to negotiate is player 0, first to negotiate was player #2, current bets: Solo 2, current game is Solo 2 by player #2, [time?: 82C7]"},
    {"0002190081E001020002020609",
     "Game negotiation, next to negotiate is player 1, first to negotiate was player #2, current bets: Pass-Solo 2, [time?: 81E0]"},
    {"0002190081DD010200000106",
     "Game negotiation, next to negotiate is player 1, first to negotiate was player #0, current bets: Pass, [time?: 81DD]"},
    {"0002190082A702020000020606",
     "Game negotiation, next to negotiate is player 2, first to negotiate was player #0, current bets: Pass-Pass, [time?: 82A7]"},
    {"00031900821A010200020209060C0000090101",
     "Game negotiation, next to negotiate is player 1, first to negotiate was player #2, current bets: Solo 2-Pass, current game is Solo 2 by player #0, [time?: 821A]"},
    {"0003190081D2020200000209060C0001090101",
     "Game negotiation, next to negotiate is player 2, first to negotiate was player #0, current bets: Solo 2-Pass, current game is Solo 2 by player #1, [time?: 81D2]"},
    {"0003190082230202000101090C0001090101",
     "Game negotiation, next to negotiate is player 2, first to negotiate was player #1, current bets: Solo 2, current game is Solo 2 by player #1, [time?: 8223]"},
    {"0002190082ED00020001020609",
     "Game negotiation, next to negotiate is player 0, first to negotiate was player #1, current bets: Pass-Solo 2, [time?: 82ED]"},
    {"000319008281000200010209060C0002090101",
     "Game negotiation, next to negotiate is player 0, first to negotiate was player #1, current bets: Solo 2-Pass, current game is Solo 2 by player #2, [time?: 8281]"},
    {"0003190082AB01020001030906090C0000090101",
     "Game negotiation, next to negotiate is player 1, first to negotiate was player #1, current bets: Solo 2-Pass-Solo 2, current game is Solo 2 by player #0, [time?: 82AB]"},
    {"0003190082EB0102000004060909060C0002090101",
     "Game negotiation, next to negotiate is player 1, first to negotiate was player #0, current bets: Pass-Solo 2-Solo 2-Pass, current game is Solo 2 by player #2, [time?: 82EB]"}
  ]

  @talon_open [
    {"000319008140011C0000060007000200290017000B000103900102000203080606", "Talon revealed, player #1 is selecting, ♣K ♣9 X-♠K ♥1 ♣8, [time?: 8140, game info: 0203 0806 06]"},
    {"000319008197021C0000060030002900180001001D00220290010200000406090609", "Talon revealed, player #2 is selecting, XVII X-♦4 ♣8-♦C III, [time?: 8197, game info: 0004 0609 0609]"},
    {"000319008210001C00000600260010001D0005000F001E03900102000103080606", "Talon revealed, player #0 is selecting, VII ♠7 ♦C-♣C ♥K ♦Q, [time?: 8210, game info: 0103 0806 06]"},
    {"0003190082C7021C00000600090022000100160021000602900102000203060609", "Talon revealed, player #2 is selecting, ♥3 III-♣8 ♠Q-II ♣Q, [time?: 82C7, game info: 0203 0606 09]"},
    {"0003190082C4021C0000060007002B003300220012001903900102000003080606", "Talon revealed, player #2 is selecting, ♣K XII XX-III ♠9 ♦3, [time?: 82C4, game info: 0003 0806 06]"},
    {"00031900823F001C000006000C002C000300100032000B02900102000203060906", "Talon revealed, player #0 is selecting, ♥J XIII-♣10 ♠7-XIX ♥1, [time?: 823F, game info: 0203 0609 06]"},
    {"000319008123021C000006002400200006000C002A002603900102000003080606", "Talon revealed, player #2 is selecting, V I ♣Q-♥J XI VII, [time?: 8123, game info: 0003 0806 06]"},
    {"000319008264001C0000060015001F0014001E0021000A02900102000003060609", "Talon revealed, player #0 is selecting, ♠C ♦K-♠J ♦Q-II ♥2, [time?: 8264, game info: 0003 0606 09]"},
    {"00031900822F001C000006002E0007001C002D0005001703900102000103080606", "Talon revealed, player #0 is selecting, XV ♣K ♦J-XIV ♣C ♠K, [time?: 822F, game info: 0103 0806 06]"},
    {"00031900827E021C000006000E001B000C00040018000602900102000203060609", "Talon revealed, player #2 is selecting, ♥Q ♦1-♥J ♣J-♦4 ♣Q, [time?: 827E, game info: 0203 0606 09]"},
    {"00031900827C011C000006000900350000000B0008003102900102000003060906", "Talon revealed, player #1 is selecting, ♥3 Fool-♣7 ♥1-♥4 XVIII, [time?: 827C, game info: 0003 0609 06]"},
    {"00031900828F011C0000060008000F0007001E0002002A02900102000103060609", "Talon revealed, player #1 is selecting, ♥4 ♥K-♣K ♦Q-♣9 XI, [time?: 828F, game info: 0103 0606 09]"},
    {"000319008252001C000006000B001F0027001A0007002502900102000203060906", "Talon revealed, player #0 is selecting, ♥1 ♦K-VIII ♦2-♣K VI, [time?: 8252, game info: 0203 0609 06]"},
    {"0003190082BD011C0000060027002E0003000D0014001C02900102000003060906", "Talon revealed, player #1 is selecting, VIII XV-♣10 ♥C-♠J ♦J, [time?: 82BD, game info: 0003 0609 06]"},
    {"00031900825D001C000006001F000700040014000D002603900102000103080606", "Talon revealed, player #0 is selecting, ♦K ♣K ♣J-♠J ♥C VII, [time?: 825D, game info: 0103 0806 06]"},
    {"000319008290021C0000060006001C000B00040027001202900102000203060609", "Talon revealed, player #2 is selecting, ♣Q ♦J-♥1 ♣J-VIII ♠9, [time?: 8290, game info: 0203 0606 09]"},
    {"0003190082AB001C00000600310027002000220029002B02900102000003060609", "Talon revealed, player #0 is selecting, XVIII VIII-I III-X XII, [time?: 82AB, game info: 0003 0606 09]"},
    {"000319008261021C00000600120014001E00230035001702900102000103060906", "Talon revealed, player #2 is selecting, ♠9 ♠J-♦Q IIII-Fool ♠K, [time?: 8261, game info: 0103 0609 06]"},
    {"000319008243021C000006000200250017002D000C002C02900102000203060609", "Talon revealed, player #2 is selecting, ♣9 VI-♠K XIV-♥J XIII, [time?: 8243, game info: 0203 0606 09]"},
    {"0003190082B0011C00000600000031001900300004001E02900102000003060906", "Talon revealed, player #1 is selecting, ♣7 XVIII-♦3 XVII-♣J ♦Q, [time?: 82B0, game info: 0003 0609 06]"},
    {"0003190082C3021C00000600340032000C00010031001B02900102000103060906", "Talon revealed, player #2 is selecting, XXI XIX-♥J ♣8-XVIII ♦1, [time?: 82C3, game info: 0103 0609 06]"},
    {"00031900824D021C00000600080023000D000A0031001702900102000203060609", "Talon revealed, player #2 is selecting, ♥4 IIII-♥C ♥2-XVIII ♠K, [time?: 824D, game info: 0203 0606 09]"},
    {"0003190082E3011C00000600170031003000130027001802900102000003060906", "Talon revealed, player #1 is selecting, ♠K XVIII-XVII ♠10-VIII ♦4, [time?: 82E3, game info: 0003 0609 06]"},
    {"000319008262001C00000600350007002B0031000D000503900102000103080606", "Talon revealed, player #0 is selecting, Fool ♣K XII-XVIII ♥C ♣C, [time?: 8262, game info: 0103 0806 06]"},
    {"000319008293021C00000600040030001B00230005001602900102000203060609", "Talon revealed, player #2 is selecting, ♣J XVII-♦1 IIII-♣C ♠Q, [time?: 8293, game info: 0203 0606 09]"},
    {"000319008294001C00000600110000000800160019001A02900102000003060609", "Talon revealed, player #0 is selecting, ♠8 ♣7-♥4 ♠Q-♦3 ♦2, [time?: 8294, game info: 0003 0606 09]"},
    {"000319008235011C00000600220008001B001F0004002E02900102000103060609", "Talon revealed, player #1 is selecting, III ♥4-♦1 ♦K-♣J XV, [time?: 8235, game info: 0103 0606 09]"},
    {"000319008294021C0000060032001F002600290008001E02900102000203060609", "Talon revealed, player #2 is selecting, XIX ♦K-VII X-♥4 ♦Q, [time?: 8294, game info: 0203 0606 09]"},
    {"00031900827B021C00000600230012001E002B0009000302900102000203060609", "Talon revealed, player #2 is selecting, IIII ♠9-♦Q XII-♥3 ♣10, [time?: 827B, game info: 0203 0606 09]"},
    {"00031900825F011C000006001E0034000E000B0005000602900102000103060609", "Talon revealed, player #1 is selecting, ♦Q XXI-♥Q ♥1-♣C ♣Q, [time?: 825F, game info: 0103 0606 09]"},
    {"00031900823C021C000006002F001D000F00100011001302900102000203060609", "Talon revealed, player #2 is selecting, XVI ♦C-♥K ♠7-♠8 ♠10, [time?: 823C, game info: 0203 0606 09]"},
    {"00031900825D021C00000600120023001E000B0015001303900102000003080606", "Talon revealed, player #2 is selecting, ♠9 IIII ♦Q-♥1 ♠C ♠10, [time?: 825D, game info: 0003 0806 06]"},
    {"0003190082C1001C000006001B001C00220032001200010290010200010406090609", "Talon revealed, player #0 is selecting, ♦1 ♦J-III XIX-♠9 ♣8, [time?: 82C1, game info: 0104 0609 0609]"},
    {"0003190082C4021C0000060003000C00070021002D000402900102000203060609", "Talon revealed, player #2 is selecting, ♣10 ♥J-♣K II-XIV ♣J, [time?: 82C4, game info: 0203 0606 09]"},
    {"000319008262021C000006002700320000002F00340010029001020000050606090906", "Talon revealed, player #2 is selecting, VIII XIX-♣7 XVI-XXI ♠7, [time?: 8262, game info: 0005 0606 0909 06]"}
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

  test "parse_message klop game started" do
    Enum.each(
      @klop_game_started,
      fn {message, expected} ->
        assert parse_message(Base.decode16!(message)) == expected
      end
    )
  end

  test "parse_message game negotation begins" do
    Enum.each(
      @game_negotiation_begins,
      fn {message, expected} ->
        assert parse_message(Base.decode16!(message)) == expected
      end
    )
  end

  test "parse_message game negotation round" do
    Enum.each(
      @game_negotiation_round,
      fn {message, expected} ->
        assert parse_message(Base.decode16!(message)) == expected
      end
    )
  end

  test "parse_message talon open" do
    Enum.each(
      @talon_open,
      fn {message, expected} ->
        assert parse_message(Base.decode16!(message)) == expected
      end
    )
  end
end
