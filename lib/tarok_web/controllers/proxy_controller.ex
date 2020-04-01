defmodule TarokWeb.ProxyController do
  use TarokWeb, :controller

  def proxy(conn, _params) do
    {:ok, %HTTPoison.Response{status_code: status, body: body, headers: headers}} = HTTPoison.get(
      URI.to_string(%URI{
        host: "valat.si",
        path: conn.request_path,
        query: conn.query_string,
        scheme: "https",
      }),
      conn.req_headers
    )

    conn
    |> add_response_header(headers)
    |> resp(status, body)
    |> send_resp()
  end

  defp add_response_header(conn, []), do: conn
  defp add_response_header(conn, [{header_key, header_value} | rest]) do
    put_resp_header(conn, header_key, header_value)
    |> add_response_header(rest)
  end
end
