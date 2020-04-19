defmodule Tarok.Card do
  def get_all() do
    [
      :c7,
      :c8,
      :c9,
      :c10,
      :cJ,
      :cC,
      :cQ,
      :cK,
      :h4,
      :h3,
      :h2,
      :h1,
      :hJ,
      :hC,
      :hQ,
      :hK,
      :s7,
      :s8,
      :s9,
      :s10,
      :sJ,
      :sC,
      :sQ,
      :sK,
      :d4,
      :d3,
      :d2,
      :d1,
      :dJ,
      :dC,
      :dQ,
      :dK,
      :i,
      :ii,
      :iii,
      :iiii,
      :v,
      :vi,
      :vii,
      :viii,
      :ix,
      :x,
      :xi,
      :xii,
      :xiii,
      :xiv,
      :xv,
      :xvi,
      :xvii,
      :xviii,
      :xix,
      :xx,
      :xxi,
      :fool
    ]
  end

  def get_strength() do
    %{
      :c7 => 1,
      :c8 => 2,
      :c9 => 3,
      :c10 => 4,
      :cJ => 5,
      :cC => 6,
      :cQ => 7,
      :cK => 8,
      :h4 => 1,
      :h3 => 2,
      :h2 => 3,
      :h1 => 4,
      :hJ => 5,
      :hC => 6,
      :hQ => 7,
      :hK => 8,
      :s7 => 1,
      :s8 => 2,
      :s9 => 3,
      :s10 => 4,
      :sJ => 5,
      :sC => 6,
      :sQ => 7,
      :sK => 8,
      :d4 => 1,
      :d3 => 2,
      :d2 => 3,
      :d1 => 4,
      :dJ => 5,
      :dC => 6,
      :dQ => 7,
      :dK => 8,
      :i => 33,
      :ii => 34,
      :iii => 35,
      :iiii => 36,
      :v => 37,
      :vi => 38,
      :vii => 39,
      :viii => 40,
      :ix => 41,
      :x => 42,
      :xi => 43,
      :xii => 44,
      :xiii => 45,
      :xiv => 46,
      :xv => 47,
      :xvi => 48,
      :xvii => 49,
      :xviii => 50,
      :xix => 51,
      :xx => 52,
      :xxi => 53,
      :fool => 54
    }
  end

  def get_colors() do
    [
      :c7,
      :c8,
      :c9,
      :c10,
      :cJ,
      :cC,
      :cQ,
      :cK,
      :h4,
      :h3,
      :h2,
      :h1,
      :hJ,
      :hC,
      :hQ,
      :hK,
      :s7,
      :s8,
      :s9,
      :s10,
      :sJ,
      :sC,
      :sQ,
      :sK,
      :d4,
      :d3,
      :d2,
      :d1,
      :dJ,
      :dC,
      :dQ,
      :dK
    ]
  end

  def get_color_mapping() do
    %{
      :c7 => :club,
      :c8 => :club,
      :c9 => :club,
      :c10 => :club,
      :cJ => :club,
      :cC => :club,
      :cQ => :club,
      :cK => :club,
      :h4 => :heart,
      :h3 => :heart,
      :h2 => :heart,
      :h1 => :heart,
      :hJ => :heart,
      :hC => :heart,
      :hQ => :heart,
      :hK => :heart,
      :s7 => :spade,
      :s8 => :spade,
      :s9 => :spade,
      :s10 => :spade,
      :sJ => :spade,
      :sC => :spade,
      :sQ => :spade,
      :sK => :spade,
      :d4 => :diamond,
      :d3 => :diamond,
      :d2 => :diamond,
      :d1 => :diamond,
      :dJ => :diamond,
      :dC => :diamond,
      :dQ => :diamond,
      :dK => :diamond
    }
  end

  def get_tarocks() do
    [
      :i,
      :ii,
      :iii,
      :iiii,
      :v,
      :vi,
      :vii,
      :viii,
      :ix,
      :x,
      :xi,
      :xii,
      :xiii,
      :xiv,
      :xv,
      :xvi,
      :xvii,
      :xviii,
      :xix,
      :xx,
      :xxi,
      :fool
    ]
  end

  def get_codes() do
    %{
      0x00 => :c7,
      0x01 => :c8,
      0x02 => :c9,
      0x03 => :c10,
      0x04 => :cJ,
      0x05 => :cC,
      0x06 => :cQ,
      0x07 => :cK,
      0x08 => :h4,
      0x09 => :h3,
      0x0A => :h2,
      0x0B => :h1,
      0x0C => :hJ,
      0x0D => :hC,
      0x0E => :hQ,
      0x0F => :hK,
      0x10 => :s7,
      0x11 => :s8,
      0x12 => :s9,
      0x13 => :s10,
      0x14 => :sJ,
      0x15 => :sC,
      0x16 => :sQ,
      0x17 => :sK,
      0x18 => :d4,
      0x19 => :d3,
      0x1A => :d2,
      0x1B => :d1,
      0x1C => :dJ,
      0x1D => :dC,
      0x1E => :dQ,
      0x1F => :dK,
      0x20 => :i,
      0x21 => :ii,
      0x22 => :iii,
      0x23 => :iiii,
      0x24 => :v,
      0x25 => :vi,
      0x26 => :vii,
      0x27 => :viii,
      0x28 => :ix,
      0x29 => :x,
      0x2A => :xi,
      0x2B => :xii,
      0x2C => :xiii,
      0x2D => :xiv,
      0x2E => :xv,
      0x2F => :xvi,
      0x30 => :xvii,
      0x31 => :xviii,
      0x32 => :xix,
      0x33 => :xx,
      0x34 => :xxi,
      0x35 => :fool
    }
  end

  def get_human_names() do
    %{
      :c7 => "♣7",
      :c8 => "♣8",
      :c9 => "♣9",
      :c10 => "♣10",
      :cJ => "♣J",
      :cC => "♣C",
      :cQ => "♣Q",
      :cK => "♣K",
      :h4 => "♥4",
      :h3 => "♥3",
      :h2 => "♥2",
      :h1 => "♥1",
      :hJ => "♥J",
      :hC => "♥C",
      :hQ => "♥Q",
      :hK => "♥K",
      :s7 => "♠7",
      :s8 => "♠8",
      :s9 => "♠9",
      :s10 => "♠10",
      :sJ => "♠J",
      :sC => "♠C",
      :sQ => "♠Q",
      :sK => "♠K",
      :d4 => "♦4",
      :d3 => "♦3",
      :d2 => "♦2",
      :d1 => "♦1",
      :dJ => "♦J",
      :dC => "♦C",
      :dQ => "♦Q",
      :dK => "♦K",
      :i => "I",
      :ii => "II",
      :iii => "III",
      :iiii => "IIII",
      :v => "V",
      :vi => "VI",
      :vii => "VII",
      :viii => "VIII",
      :ix => "IX",
      :x => "X",
      :xi => "XI",
      :xii => "XII",
      :xiii => "XIII",
      :xiv => "XIV",
      :xv => "XV",
      :xvi => "XVI",
      :xvii => "XVII",
      :xviii => "XVIII",
      :xix => "XIX",
      :xx => "XX",
      :xxi => "XXI",
      :fool => "Fool"
    }
  end

  def get_human_name_from_code(code) do
    get_human_names()[get_card_from_code(code)]
  end

  def get_human_name(card) do
    get_human_names()[card]
  end

  def get_card_from_code(code) do
    get_codes()[code]
  end

  def includes_tarock(list_of_cards) do
    Enum.count(get_tarocks_from_list(list_of_cards)) > 0
  end

  def get_tarocks_from_list(list_of_cards) do
    list_of_cards -- get_colors()
  end

  def get_color(card) do
    Map.get(get_color_mapping(), card)
  end

  def get_color_from_list(list_of_cards, color) do
    Enum.filter(list_of_cards, &(get_color_mapping()[&1] == color))
  end
end
