defmodule TarokWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :tarok

  socket "/sockets/game", Tarok.Socket,
    websocket: [path: "/:id", serializer: []]

  socket "/sockets", Tarok.Socket,
    websocket: [path: "/:type", serializer: []]

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  #@session_options [
  #  store: :cookie,
  #  key: "_tarok_key",
  #  signing_salt: "nO9s0PA5"
  #]

  #plug Plug.RequestId
  #plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  #plug Plug.Parsers,
  #  parsers: [:urlencoded, :multipart, :json],
  #  pass: ["*/*"],
  #  json_decoder: Phoenix.json_library()

  #plug Plug.MethodOverride
  #plug Plug.Head
  #plug Plug.Session, @session_options
  plug TarokWeb.Router
end
