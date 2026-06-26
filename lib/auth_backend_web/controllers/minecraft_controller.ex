defmodule AuthBackendWeb.MinecraftController do
  use AuthBackendWeb, :controller
  plug Ueberauth

  def request(conn, %{"mc_username" => mc_username}) do
    conn |> put_session(:mc_username, mc_username) |> redirect(to: ~p"/auth/discord")
  end

  def request(conn, _params) do
    conn |> put_status(403) |> text("Cette action doit provenir du SMP")
  end

  def islogged(%Plug.Conn{req_headers: headers} = conn, %{"user" => mc_username}) do
    secret = Application.get_env(:auth_backend, :smp_secret)

    case secret do
      nil ->
        conn |> put_status(500) |> json(%{error: "serveur mal config"})

      _ ->
        try do
          Enum.each(headers, fn x ->
            if x == {"secret", secret} do
              raise "found"
            end
          end)
        rescue
          _ -> json(conn, %{logged: AuthBackend.LoggedPlayers.mem(String.downcase(mc_username))})
        end
    end

    conn |> put_status(400) |> json(%{error: "some values are missing"})
  end

  def islogged(conn, _params) do
    conn |> put_status(400) |> json(%{error: "some values are missing"})
  end
end
