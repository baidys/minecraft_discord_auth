defmodule AuthBackendWeb.AuthController do
  use AuthBackendWeb, :controller
  alias AuthBackend.{Repo, Player}
  plug Ueberauth

  def request(conn, _params), do: conn

  def callback(%{assigns: %{ueberauth_failure: %Ueberauth.Failure{}}} = conn, _params) do
    text(conn, "Authentification échouée")
  end

  def callback(
        %{
          assigns: %{ueberauth_auth: %Ueberauth.Auth{} = auth},
          private: %{:plug_session => %{"mc_username" => mc_username}}
        } = conn,
        _params
      ) do
    ds_username = String.downcase(auth.info.nickname)
    mc_username = String.downcase(mc_username)
    guilds = auth.extra.raw_info.guilds
    iip = conn.remote_ip |> Tuple.to_list() |> List.to_string()
    ip = :crypto.hash(:sha256, iip) |> Base.encode16(case: :lower)

    try do
      Enum.each(guilds, fn x ->
        if x["id"] == "1514308766609313842" do
          raise "found"
        end
      end)

      text(conn, "nil")
    rescue
      _ in RuntimeError ->
        if auth?(ds_username, mc_username) do
          Task.async(fn -> insertIntoFile(mc_username, true) end)
          text(conn, "OK : connexion réussie")
        else
          if createUser?(ds_username, mc_username, ip) do
            Task.async(fn -> insertIntoFile(mc_username, true) end)
            text(conn, "OK : création de compte && connexion réussie")
          else
            Task.async(fn -> insertIntoFile(mc_username, "echec de l'Authentification") end)
            text(conn, "Authentification échouée")
          end
        end
    end
  end

  def callback(conn, _params) do
    text(conn, "Authentication failed")
  end

  defp auth?(ds_user, mc_user) do
    try do
      Enum.map(AuthBackend.Repo.all(Player), fn x ->
        if x.ds_username == ds_user do
          if x.mc_username == mc_user do
            raise "user is correct"
          end
        end
      end)

      false
    rescue
      _ in RuntimeError -> true
    end
  end

  defp createUser?(ds_user, mc_user, ip_user) do
    case userAlredyExist?(mc_user, ds_user) do
      true ->
        false

      false ->
        player =
          Player.changeset(%Player{}, %{
            ds_username: ds_user,
            mc_username: mc_user,
            ip: ip_user
          })

        case Repo.insert(player) do
          {:error, _} -> false
          {:ok, _} -> true
        end
    end
  end

  defp userAlredyExist?(mc_user, ds_user) do
    try do
      Enum.map(AuthBackend.Repo.all(Player), fn x ->
        if x.ds_username == ds_user do
          raise "found"
        end

        if x.mc_username == mc_user do
          raise "found"
        end
      end)

      false
    rescue
      _ in RuntimeError -> true
    end
  end


  defp insertIntoFile(username, status) do
    AuthBackend.LoggedPlayers.removePlayer(username)
    AuthBackend.LoggedPlayers.addPlayer(username, status)

    Task.start(fn ->
      Process.sleep(30_000)
      AuthBackend.LoggedPlayers.removePlayer(username)
    end)
  end
end
