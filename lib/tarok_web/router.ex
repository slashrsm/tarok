defmodule TarokWeb.Router do
  use TarokWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    # plug :fetch_session
    # plug :fetch_flash
    # plug :protect_from_forgery
    # plug :put_secure_browser_headers
  end

  scope "/", TarokWeb do
    pipe_through :browser

    get "/*path", ProxyController, :proxy
  end
end
