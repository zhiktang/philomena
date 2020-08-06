defmodule PhilomenaWeb.ContentSecurityPolicyPlug do
  alias Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    cdn_uri = cdn_uri()
    camo_uri = camo_uri()

    csp_value =
      "default-src 'self' #{cdn_uri}; object-src 'none'; " <>
        "frame-ancestors 'none'; frame-src 'none'; form-action 'self'; " <>
        "manifest-src 'self'; img-src https://static.sample.tld 'self' data: #{cdn_uri} #{camo_uri}; media-src 'self' https://static.sample.tld; " <>
        "block-all-mixed-content"

    conn = if Application.get_env(:philomena, :app_env) == "prod" do
      Conn.put_resp_header(conn, "content-security-policy", csp_value)
    else
      Conn.put_resp_header(conn, "content-security-policy-report-only", csp_value)
    end
    conn
  end

  defp cdn_uri, do: Application.get_env(:philomena, :cdn_host) |> to_uri()
  defp camo_uri, do: Application.get_env(:philomena, :camo_host) |> to_uri()

  defp to_uri(host) when host in [nil, ""], do: ""
  defp to_uri(host), do: URI.to_string(%URI{scheme: "https", host: host})
end
