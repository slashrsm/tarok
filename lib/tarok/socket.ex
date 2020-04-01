defmodule Tarok.Socket do
  @behaviour Phoenix.Socket.Transport
  require Logger

  def child_spec(_opts) do
    %{id: Task, start: {Task, :start_link, [fn -> :ok end]}, restart: :transient}
  end

  def connect(map) do
    IO.inspect map.options
    if Keyword.get(map.options, :path) == "/:type" do
      {:ok, %{
        hash: map.params["hash"],
        type: map.params["type"]
      }}
    else
      {:ok, %{
        hash: map.params["hash"],
        type: "game",
        id: map.params["id"]
      }}
    end
  end

  def init(state) do
    {:ok, pid} = if state.type == "lobby" do
      Tarok.SocketClient.start_link([caller: self(), type: state.type, hash: state.hash])
    else
      Tarok.SocketClient.start_link([caller: self(), type: state.type, hash: state.hash, id: state.id])
    end

    {:ok, state |> Map.put(:connection_pid, pid)}
  end

  def handle_in({msg, _opts}, state) do
    Logger.info("Sent: #{parse_message(msg)}")
    Tarok.SocketClient.send(state.connection_pid, msg)
    {:ok, state}
  end

  def handle_info({:new_message, msg}, state) do
    Logger.info("Received: #{parse_message(msg)}")
    {:reply, :ok, {:binary, msg}, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  defp parse_message(msg) do
    Base.encode16(msg)
  end

end
