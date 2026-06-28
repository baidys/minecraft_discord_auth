defmodule AuthBackendWeb.MinecraftController do
  use AuthBackendWeb, :controller

  def request(conn, %{"mc_username" => mc_username}) do
    conn |> put_session(:mc_username, mc_username) |> redirect(to: ~p"/auth/discord")
  end

  def request(conn, _params) do
    conn |> put_status(403) |> text("Cette action doit provenir du SMP")
  end

  def islogged(%Plug.Conn{req_headers: headers} = conn, %{"user" => mc_username}) do
    secret = Application.get_env(:auth_backend, :smp_secret)

    Enum.each(headers, fn x ->
      {key, provided_secret} = x 
        if key == "secret" do
        if :crypto.hash_equals(
              :crypto.hash(:sha256, secret),
              :crypto.hash(:sha256, provided_secret)
          ) do           
            json(conn, %{logged: AuthBackend.LoggedPlayers.mem(String.downcase(mc_username))}) end
            end
      end)
          conn |> put_status(400) |> json(%{error: "some values are missing"})
  end

  def islogged(conn, _params) do
    conn |> put_status(400) |> json(%{error: "some values are missing"})
  end
end
