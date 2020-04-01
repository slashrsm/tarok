defmodule Tarok.SocketClient do
  use WebSockex
  require Logger

  def start_link(opts \\ []) do
    type = Keyword.get(opts, :type)
    hash = Keyword.get(opts, :hash)
    caller = Keyword.get(opts, :caller)
    if type == "lobby" do
      WebSockex.start_link("wss://valat.si/sockets/#{type}?hash=#{hash}", __MODULE__, %{caller: caller}, opts)
    else
      id = Keyword.get(opts, :id)
      WebSockex.start_link("wss://valat.si/sockets/#{type}/#{id}?hash=#{hash}", __MODULE__, %{caller: caller}, opts)
    end
  end

  def send(client, message) do
    WebSockex.send_frame(client, {:binary, message})
  end

  def handle_connect(_conn, state) do
    {:ok, state}
  end

  def handle_frame({:binary, msg}, state) do
    Process.send(state.caller, {:new_message, msg}, [])
    {:ok, state}
  end

end
