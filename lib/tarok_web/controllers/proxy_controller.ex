defmodule TarokWeb.ProxyController do
  use TarokWeb, :controller

  def proxy(conn, _params) do
    {:ok, %HTTPoison.Response{status_code: status, body: body, headers: headers}} =
      HTTPoison.get(
        URI.to_string(%URI{
          host: "valat.si",
          path: conn.request_path,
          query: conn.query_string,
          scheme: "https"
        }),
        massage_headers(conn.req_headers)
      )

    conn
    |> add_response_header(headers)
    |> resp(status, body)
    |> send_resp()
  end

  defp add_response_header(conn, []), do: conn

  defp add_response_header(conn, [{"Content-Security-Policy", _} | rest]),
    do: add_response_header(conn, rest)

  defp add_response_header(conn, [{"Strict-Transport-Security", _} | rest]),
    do: add_response_header(conn, rest)

  defp add_response_header(conn, [{header_key, header_value} | rest]) do
    put_resp_header(conn, header_key, header_value)
    |> add_response_header(rest)
  end

  defp massage_headers([]), do: []
  defp massage_headers([{"host", _} | rest]), do: [{"host", "valat.si"}] ++ massage_headers(rest)

  defp massage_headers([{"referer", referer} | rest]) do
    referer =
      referer
      |> String.replace("localhost", "valat.si")

    # |> String.replace("http", "https")

    [{"referer", referer}] ++ massage_headers(rest)
  end

  defp massage_headers([head | rest]), do: [head] ++ massage_headers(rest)
end
