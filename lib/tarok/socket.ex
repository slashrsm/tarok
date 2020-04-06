defmodule Tarok.Socket do
  @behaviour Phoenix.Socket.Transport
  require Logger

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
    {:ok, state}
  end

  def handle_in({<<0x00, msg::binary>>, _opts}, state) do
    Logger.info("Tx: #{parse_message(msg)}")
    {:ok, state}
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  defp parse_message(msg) do
    Base.encode16(msg)
  end

end
