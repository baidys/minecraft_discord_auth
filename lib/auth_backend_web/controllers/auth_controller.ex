defmodule AuthBackendWeb.AuthController do
  use AuthBackendWeb, :controller
  alias AuthBackend.{Players, LoggedPlayers, ErrorHTML}
  plug(Ueberauth)

  def login(conn, %{"mc_username" => mc_username}) do
    conn |> put_session(:mc_username, mc_username) |> redirect(to: ~p"/auth/discord")
  end

  def login(conn, _params) do
    conn |> put_status(404) |> put_view(ErrorHTML) |> render("404.html", status: 404)
  end

  def request(conn, _params), do: conn

  def callback(%{assigns: %{ueberauth_failure: %Ueberauth.Failure{}}} = conn, _params) do
    conn |> put_status(401) |> render(:error, error: "Discord authentication failed")
  end

  def callback(%{assigns: %{ueberauth_auth: %Ueberauth.Auth{} = auth}} = conn, _params) do
    ds_username = auth.info.nickname
    mc_username = get_session(conn, "mc_username")
    ip = conn.remote_ip |> :inet.ntoa() |> to_string()
    hashed_ip = :crypto.hash(:sha256, ip) |> Base.encode16()
    guild_id = Application.get_env(:auth_backend, :guild_id)

    member_of_guild? =
      auth.extra.raw_info.guilds |> Enum.any?(fn guild -> guild["id"] == guild_id end)

    if not member_of_guild? do
      Task.async(fn -> LoggedPlayers.add(mc_username, "failed") end)

      conn
      |> put_status(400)
      |> render(:error, error: "An error occurred")
    else
      case Players.login(mc_username, ds_username) do
        {:ok, true} ->
          Players.update_ip(mc_username, hashed_ip)
          Task.async(fn -> LoggedPlayers.add(mc_username, true) end)

          render(
            conn,
            :success,
            message: "Login successful"
          )

        {:ok, false} ->
          case Players.ip_already_used(hashed_ip) do
            {:ok, true} ->
              Task.async(fn -> LoggedPlayers.add(mc_username, "failed") end)
              conn |> put_status(400) |> render(:error, error: "An error occurred")

            {:ok, false} ->
              case Players.create(mc_username, ds_username, hashed_ip) do
                {:ok, message} ->
                  render(
                    conn,
                    :success,
                    message: message
                  )

                {:e409, error} ->
                  Task.async(fn -> LoggedPlayers.add(mc_username, "failed") end)
                  conn |> put_status(409) |> render(:error, error: error)

                _ ->
                  Task.async(fn -> LoggedPlayers.add(mc_username, "failed") end)
                  conn |> put_status(500) |> render(:error, error: "An error occurred")
              end

            {:error, error} ->
              conn |> put_status(500) |> render(:error, error: error)
          end

        {:error, error} ->
          conn |> put_status(500) |> render(:error, error: error)
      end
    end
  end

  def callback(conn, _params) do
    conn |> put_status(500) |> render(:error, error: "An error occurred")
  end
end
