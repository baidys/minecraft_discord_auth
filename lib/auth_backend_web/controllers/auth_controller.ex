defmodule AuthBackendWeb.AuthController do
  use AuthBackendWeb, :controller
  alias AuthBackend.{Repo, Player}
  import Ecto.Query
  plug Ueberauth

  def request(conn, _params), do: conn

  def callback(%{assigns: %{ueberauth_failure: %Ueberauth.Failure{}}} = conn, _params) do
    text(conn, "Authentification avec discord échouée")
  end

  def callback(
        %{
          assigns: %{ueberauth_auth: %Ueberauth.Auth{} = auth},
          private: %{:plug_session => %{"mc_username" => mc_username}}
        } = conn,
        _params
      ) do
    dbg()
    ds_username = String.downcase(auth.info.nickname)
    mc_username = String.downcase(mc_username)
    guild_id = Application.get_env(:auth_backend, :guild_id)
    guilds = auth.extra.raw_info.guilds
    member_of_guild? = Enum.any?(guilds, fn guild -> guild["id"] == guild_id end)

    if not member_of_guild? do
      Task.async(fn -> insertIntoFile(mc_username, "failed") end)
      text(conn, "Accès refusé : vous devez rejoindre le serveur Discord pour vous authentifier.")
    end

    if Repo.exists?(
         from p in Player, where: p.ds_username == ^ds_username and p.mc_username == ^mc_username
       ) do
      Task.async(fn -> insertIntoFile(mc_username, true) end)
      text(conn, "OK : connexion réussie, vous pouvez retourner sur le jeu")
    else
      if Repo.exists?(from p in Player, where: p.ds_username == ^ds_username) do
        Task.async(fn -> insertIntoFile(mc_username, "failed") end)
        text(conn, "Authentification échouée : compte discord déjà liée")
      else
        if Repo.exists?(from p in Player, where: p.mc_username == ^mc_username) do
          Task.async(fn -> insertIntoFile(mc_username, "failed") end)
          text(conn, "Authentification échouée : compte minecraft déjà liée")
        else
          player =
            Player.changeset(%Player{}, %{
              ds_username: ds_username,
              mc_username: mc_username
            })

          case Repo.insert(player) do
            {:error, _} ->
              Task.async(fn -> insertIntoFile(mc_username, "failed") end)
              text(conn, "Authentification échouée : contact avec la base de donnée")

            {:ok, _} ->
              Task.async(fn -> insertIntoFile(mc_username, true) end)

              text(
                conn,
                "OK : création du compte et connexion réussie, vous pouvez retourner sur le jeu"
              )
          end
        end
      end
    end
  end

  def callback(conn, _params) do
    text(conn, "Discord authentication failed")
  end

  defp insertIntoFile(username, status) do
    AuthBackend.LoggedPlayers.removePlayer(username)
    AuthBackend.LoggedPlayers.addPlayer(username, status)

    if status == "failed" do
      Task.start(fn ->
        Process.sleep(5_000)
        AuthBackend.LoggedPlayers.removePlayer(username)
      end)
    else
      Task.start(fn ->
        Process.sleep(30_000)
        AuthBackend.LoggedPlayers.removePlayer(username)
      end)
    end
  end
end
