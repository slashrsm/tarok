defmodule Tarok.Socket do
  @behaviour Phoenix.Socket.Transport
  require Logger
  use Bitwise
  alias Tarok.Card
  alias Tarok.GameStats

  @games %{
    0x03 => "Klop",
    0x06 => "Pass",
    0x07 => "Solo 1",
    0x09 => "Solo 2",
    0x08 => "Solo 3",
    0x0A => "Solo w/o",
    0x01 => "Beggar?"
  }

  @color_hand_bits %{
    black: %{
      0x01 => "7",
      0x02 => "8",
      0x04 => "9",
      0x08 => "10",
      0x10 => "J",
      0x20 => "C",
      0x40 => "Q",
      0x80 => "K"
    },
    red: %{
      0x01 => "4",
      0x02 => "3",
      0x04 => "2",
      0x08 => "1",
      0x10 => "J",
      0x20 => "C",
      0x40 => "Q",
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

  def handle_info(data, state) do
    {:push, {:text, Jason.encode!(data)}, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  def parse_message(
        <<0x00, 0x01, 0x0B, 0x00, player::size(8), _bytes_num::size(8), message::binary>>
      ) do
    "Chat message from player ##{player}: #{message}"
  end

  def parse_message(<<0x09, 0x00, 0x00, card::size(8)>>) do
    card = Card.get_card_from_code(card)
    GameStats.i_play_card(card)
    "I play card: " <> Card.get_human_name(card)
  end

  def parse_message(<<0x08, 0x00, set_nr::size(8)>>) do
    "From talon I take set ##{set_nr}"
  end

  def parse_message(<<0x02, 0x00, game_nr::size(8)>>) do
    if Map.has_key?(@games, game_nr) do
      "I play game: #{@games[game_nr]}"
    else
      "I play game: #{game_nr}"
    end
  end

  def parse_message(
        <<0x00, 0x02, 0x19, 0x00, time?::binary-size(2), next_player::size(8), 0x02, 0x00,
          first_negotiator::size(8), count::size(8), bets::binary-size(count)>>
      ) do
    bets =
      bets
      |> :binary.bin_to_list()
      |> Enum.map(fn game_id -> @games[game_id] end)
      |> Enum.join("-")

    "Game negotiation, next to negotiate is player #{next_player}, first to negotiate was player ##{
      first_negotiator
    }, current bets: #{bets}, [time?: #{Base.encode16(time?)}]"
  end

  def parse_message(
        <<0x00, 0x03, 0x19, 0x00, time?::binary-size(2), next_player::size(8), 0x02, 0x00,
          first_negotiator::size(8), count::size(8), bets::binary-size(count), 0x0C, 0x00,
          player_with_game::size(8), current_game::size(8), 0x01, 0x01>>
      ) do
    bets =
      bets
      |> :binary.bin_to_list()
      |> Enum.map(fn game_id -> @games[game_id] end)
      |> Enum.join("-")

    "Game negotiation, next to negotiate is player #{next_player}, first to negotiate was player ##{
      first_negotiator
    }, current bets: #{bets}, current game is #{@games[current_game]} by player ##{
      player_with_game
    }, [time?: #{Base.encode16(time?)}]"
  end

  def parse_message(
        <<0x00, 0x03, 0x19, 0x00, time?::binary-size(2), next_player::size(8), 0x1C, 0x00, 0x00,
          0x06, card1::size(16), card2::size(16), card3::size(16), card4::size(16),
          card5::size(16), card6::size(16), chunk_size::size(8), 0x90, 0x01, 0x02, 0x00,
          game_info::binary>>
      ) do
    talon =
      [card1, card2, card3, card4, card5, card6]
      |> Enum.chunk_every(chunk_size)
      |> Enum.map(fn chunk ->
        chunk |> Enum.map(&Card.get_human_name_from_code(&1)) |> Enum.join(" ")
      end)
      |> Enum.join("-")

    GameStats.standard()

    if next_player == 0 do
      GameStats.my_game()
    else
      GameStats.their_game(next_player)
    end

    "Talon revealed, player ##{next_player} is selecting, #{talon}, [time?: #{
      Base.encode16(time?)
    }, game info: #{Base.encode16(game_info) |> split_every_4() |> String.trim()}]"
  end

  def parse_message(
        <<0x00, 0x04, 0x19, 0x00, time?::binary-size(2), player::size(8), 0x12, 0x02, 0x00,
          next_player::size(8), 0x03, 0x03, 0x06, 0x06, 0x0C, 0x00, player_again::size(8), 0x03,
          0x01, 0x01>>
      )
      when player == player_again and rem(player + 1, 3) == next_player do
    GameStats.klop()

    "Klop started by player ##{player}. [time?: #{Base.encode16(time?)}, next player: #{
      next_player
    }]"
  end

  def parse_message(
        <<0x00, 0x03, 0x02, 0x00, player::size(8), 0x00, 0x0E, 0x00, 0x03, 0xA0,
          gibberish::binary-size(8), player_again::size(8), 0x0C, 0x00,
          obligatory_player::size(8), 0x08, 0x01, 0x01>>
      )
      when player == player_again and rem(obligatory_player + 1, 3) == player do
    "Game negotiation, player ##{player} negotiates first, player ##{obligatory_player} has solo 3, [#{
      Base.encode16(gibberish)
    }]"
  end

  def parse_message(
        <<0x00, 0x01, 0x01, 0x00, count::size(8), games::binary-size(count), rest::binary>>
      ) do
    games =
      games
      |> :binary.bin_to_list()
      |> Enum.map(fn game_id -> @games[game_id] end)
      |> Enum.join(", ")

    "I am allowed to play games: #{games}. [rest: #{Base.encode16(rest)}]"
  end

  def parse_message(<<0x0, 0x01, 0x16, 0x00, limit::binary>>) do
    "My possible moves are: #{Base.encode16(limit)}"
  end

  def parse_message(
        <<0x00, 0x05, 0x02, 0x00, player::size(8), 0x00, 0x0E, 0x00, 0x03, 0xA0,
          gibberish::binary-size(8), player_again::size(8), 0x0C, 0x00,
          obligatory_player::size(8), 0x08, 0x01, 0x01, 0x17, 0x00, 0x00, 0xE1,
          hand::binary-size(8), second_unknown::binary>>
      )
      when player == player_again and rem(obligatory_player + 1, 3) == player do
    hand = get_hand(hand)
    GameStats.new_game(hand)

    "Game started, Got hand: #{hand |> Enum.map(&Card.get_human_name(&1)) |> Enum.join(" ")}, player ##{
      player
    } negotiates first, player ##{obligatory_player} has solo 3, [gibberish: #{
      Base.encode16(gibberish)
    }, #{Base.encode16(second_unknown)}]"
  end

  def parse_message(<<0x00, 0x04, 0x09, 0x00, full_message::binary>>) do
    case split_binary_at(<<0x00, 0xE1>>, full_message, <<>>) do
      {first_unknown, <<hand::binary-size(8), second_unknown::binary>>} ->
        won = get_hand(hand)

        "Game ended. Player won the following cards: #{
          won |> Enum.map(&Card.get_human_name(&1)) |> Enum.join(" ")
        }. [#{Base.encode16(first_unknown)}, #{Base.encode16(second_unknown)}]"

      :error ->
        "Game ended. Unknown message: #{Base.encode16(full_message)}"
    end
  end

  def parse_message(<<0x00, 0x03, 0x09, 0x00, full_message::binary>>) do
    case split_binary_at(<<0x00, 0xE1>>, full_message, <<>>) do
      {first_unknown, <<hand::binary-size(8), second_unknown::binary>>} ->
        won = get_hand(hand)

        "Game ended. Player lost \"klop\": #{
          won |> Enum.map(&Card.get_human_name(&1)) |> Enum.join(" ")
        }. [#{Base.encode16(first_unknown)}, #{Base.encode16(second_unknown)}]"

      :error ->
        "Game ended. Unknown message: #{Base.encode16(full_message)}"
    end
  end

  def parse_message(<<0x00, 0x05, 0x07, 0x00, full_message::binary>>) do
    case split_binary_at(<<0x00, 0xE1>>, full_message, <<>>) do
      {first_unknown, <<hand::binary-size(8), second_unknown::binary>>} ->
        won = get_hand(hand)

        "Game ended. Want to play more? Player won the following cards: #{
          won |> Enum.map(&Card.get_human_name(&1)) |> Enum.join(" ")
        }. [#{Base.encode16(first_unknown)}, #{Base.encode16(second_unknown)}]"

      :error ->
        "Game ended. Want to play more? Unknown message: #{Base.encode16(full_message)}"
    end
  end

  def parse_message(<<0x00, 0x01, 0x17, 0x00, 0x00, 0x00E1, hand::binary-size(8)>>) do
    hand = get_hand(hand)
    GameStats.new_game(hand)

    "Got hand: #{hand |> Enum.map(&Card.get_human_name(&1)) |> Enum.join(" ")}"
  end

  def parse_message(<<0x05, 0x00, 0x02>>) do
    "I do not make any bets."
  end

  def parse_message(
        <<0x00, 0x02, 0x19, 0x00, time?::binary-size(2), unknown::binary-size(1), 0x13, 0x00,
          0x00, card::size(8), player::size(8), round_end::size(8)>>
      ) do
    # Time is not in miliseconds.
    GameStats.card_on_the_table(Card.get_card_from_code(card), player)

    if round_end == 0 do
      "Player ##{player} plays " <>
        Card.get_human_name_from_code(card) <>
        ", [time?: #{Base.encode16(time?)}, #{Base.encode16(unknown)}]"
    else
      "Player ##{player} plays " <>
        Card.get_human_name_from_code(card) <>
        ", end of round, [time?: #{Base.encode16(time?)}, #{Base.encode16(unknown)}]"
    end
  end

  def parse_message(
        <<0x00, 0x03, 0x19, 0x00, time?::binary-size(2), collecting_player::size(8), 0x13, 0x00,
          0x00, talon_card::size(8), 0x04, unknown::binary-size(1), 0x13, 0x00, 0x00,
          card::size(8), player::size(8), round_end::size(8)>>
      ) do
    GameStats.card_on_the_table(
      Card.get_card_from_code(card),
      player,
      Card.get_card_from_code(talon_card)
    )

    if round_end == 0 do
      "Player ##{player} plays #{Card.get_human_name_from_code(card)}, talon contributes #{
        Card.get_human_name_from_code(talon_card)
      }, [time?: #{Base.encode16(time?)}, collecting player?: #{collecting_player}, #{
        Base.encode16(unknown)
      }]"
    else
      "Player ##{player} plays #{Card.get_human_name_from_code(card)}, talon contributes #{
        Card.get_human_name_from_code(talon_card)
      }, end of round, [time?: #{Base.encode16(time?)}, collecting player?: #{collecting_player}, #{
        Base.encode16(unknown)
      }]"
    end
  end

  def parse_message(
        <<0x00, 0x02, 0x19, 0x00, _time?::size(16), player::size(8), 0x1C, 0x00, 0x00, 0x06, 0x00,
          card1::size(8), 0x00, card2::size(8), 0x00, card3::size(8), 0x00, card4::size(8), 0x00,
          card5::size(8), 0x00, card6::size(8), group_size::size(8), selected::size(8)>>
      ) do
    talon =
      [card1, card2, card3, card4, card5, card6]
      |> Enum.chunk_every(group_size)

    selected_chunk =
      talon
      |> Enum.at(selected)
      |> Enum.map(&Card.get_card_from_code(&1))

    left_chunks =
      talon
      |> List.delete_at(selected)
      |> List.flatten()
      |> Enum.map(&Card.get_card_from_code(&1))

    if player == 0 do
      GameStats.i_took_talon(selected_chunk, left_chunks)
    else
      GameStats.they_left_talon(left_chunks)
    end

    "Player ##{player} selected: #{
      selected_chunk |> Enum.map(&Card.get_human_name(&1)) |> Enum.join(" ")
    }, left: #{left_chunks |> Enum.map(&Card.get_human_name(&1)) |> Enum.join(" ")}"
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

  defp get_hand(
         <<clubs::integer-size(8), hearts::integer-size(8), spades::integer-size(8),
           diamonds::integer-size(8), tarocks1::integer-size(8), tarocks2::integer-size(8),
           tarocks3::integer-size(8), 0x00>>
       ) do
    clubs =
      parse_hand_color(clubs, :black)
      |> Enum.map(fn card -> String.to_existing_atom("c" <> card) end)

    spades =
      parse_hand_color(spades, :black)
      |> Enum.map(fn card -> String.to_existing_atom("s" <> card) end)

    hearts =
      parse_hand_color(hearts, :red)
      |> Enum.map(fn card -> String.to_existing_atom("h" <> card) end)

    diamonds =
      parse_hand_color(diamonds, :red)
      |> Enum.map(fn card -> String.to_existing_atom("d" <> card) end)

    tarocks1 =
      parse_hand_tarock(tarocks1)
      |> Enum.map(&Card.get_card_from_code(&1 + 31))

    tarocks2 =
      parse_hand_tarock(tarocks2)
      |> Enum.map(&Card.get_card_from_code(&1 + 39))

    tarocks3 =
      parse_hand_tarock(tarocks3)
      |> Enum.map(&Card.get_card_from_code(&1 + 47))

    clubs ++ hearts ++ spades ++ diamonds ++ tarocks1 ++ tarocks2 ++ tarocks3
  end

  defp parse_hand_tarock(hand) do
    @tarock_hand_bits
    |> Enum.map(fn {bits, card} -> {bits &&& hand, card} end)
    |> Enum.filter(fn {present, _card} -> present > 0 end)
    |> Enum.map(fn {_, card} -> card end)
  end

  def split_binary_at(
        <<fist_splitter, second_splitter>> = splitter,
        <<next::binary-size(1), rest::binary>> = full_binary,
        before
      ) do
    case full_binary do
      <<^fist_splitter, ^second_splitter, rest::binary>> -> {before, rest}
      _ -> split_binary_at(splitter, rest, before <> next)
    end
  end

  def split_binary_at(_, <<>>, _) do
    :error
  end
end
