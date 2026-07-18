defmodule AuthBackend.Players do
  alias AuthBackend.Repo
  alias AuthBackend.Players.Player
  import Ecto.{Query, Changeset}

  def login(mc_username, ds_username) do
    mc_username = String.downcase(mc_username)
    ds_username = String.downcase(ds_username)
    try do
      if Repo.exists?(
           from(p in Player,
             where: p.ds_username == ^ds_username and p.mc_username == ^mc_username
           )
         ) do
        {:ok, true}
      else
        {:ok, false}
      end
    rescue
      _ -> {:error, "An error occurred"}
    end
  end

  def exist(mc_username, ds_username) do
    mc_username = String.downcase(mc_username)
    ds_username = String.downcase(ds_username)
    try do
      if Repo.exists?(
           from(p in Player,
             where: p.ds_username == ^ds_username or p.mc_username == ^mc_username
           )
         ) do
        {:ok, true}
      else
        {:ok, false}
      end
    rescue
      _ -> {:error, "An error occurred"}
    end
  end

  def ip_already_used(ip) do
    try do
      if Repo.exists?(from(p in Player, where: p.ip == ^ip)) do
        {:ok, true}
      else
        {:ok, false}
      end
    rescue
      _ -> {:error, "An error occurred"}
    end
  end

  def update_ip(mc_username, ip) do
    mc_username = String.downcase(mc_username)
    try do
      player = Repo.get_by(Player, mc_username: mc_username)
      Ecto.Changeset.change(player, ip: ip) |> Repo.update()
    rescue
      _ -> {:error, "An error occurred"}
    end
  end

  def create(mc_username, ds_username, ip) do
    mc_username = String.downcase(mc_username)
    ds_username = String.downcase(ds_username)
    try do
      case exist(mc_username, ds_username) do
        {:ok, true} ->
          {:e409, "Account already exist"}

        {:ok, false} ->
          player =
            Player.changeset(%Player{}, %{
              mc_username: mc_username,
              ds_username: ds_username,
              ip: ip
            })

          case Repo.insert(player) do
            {:ok, _} ->
              {:ok, "Account creation successful"}

            {:error, _} ->
              {:e500, "An error occurred"}
          end

        {:error, error} ->
          {:e500, error}
      end
    rescue
      _ -> {:e500, "An error occurred"}
    end
  end

  def get_info(:mc, username) do
    try do
      player = Repo.get_by(Player, mc_username: username)

      if player == nil do
        {:e404, "No players matching this Minecraft username found"}
      else
        {
          :ok,
          %{
            mc_username: player.mc_username,
            ds_username: player.ds_username,
            first_connection: player.inserted_at,
            last_change: player.updated_at
          }
        }
      end
    rescue
      _ -> {:e500, "Database error"}
    end
  end

  def get_info(:ds, username) do
    try do
      player = Repo.get_by(Player, ds_username: username)

      if player == nil do
        {:e404, "No players matching this Discord username found"}
      else
        {
          :ok,
          %{
            mc_username: player.mc_username,
            ds_username: player.ds_username,
            first_connection: player.inserted_at,
            last_change: player.updated_at
          }
        }
      end
    rescue
      _ -> {:e500, "Database error"}
    end
  end

  def edit(:mc, mc_username, ds_username) do
    mc_username = String.downcase(mc_username)
    ds_username = String.downcase(ds_username)
    try do
      player = Repo.get_by(Player, mc_username: mc_username)

      if player == nil do
        {:e404, "No players matching this Minecraft username found"}
      else
        case Ecto.Changeset.change(player, ds_username: ds_username) |> Repo.update() do
          {:ok, _} -> {:ok, "Discord username of #{player.mc_username} updated"}
          {:error, _} -> {:e500, "Database error"}
        end
      end
    rescue
      _ -> {:e500, "Database error"}
    end
  end

  def edit(:ds, ds_username, mc_username) do
    mc_username = String.downcase(mc_username)
    ds_username = String.downcase(ds_username)
    try do
      player = Repo.get_by(Player, ds_username: ds_username)

      if player == nil do
        {:e404, "No players matching this Discord username found"}
      else
        case Ecto.Changeset.change(player, mc_username: mc_username) |> Repo.update() do
          {:ok, _} -> {:ok, "Minecraft username of #{player.ds_username} updated"}
          {:error, _} -> {:e500, "Database error"}
        end
      end
    rescue
      _ -> {:e500, "Database error"}
    end
  end

  def reset_ip(:mc, mc_username) do
    mc_username = String.downcase(mc_username)
    try do
      player = Repo.get_by(Player, mc_username: mc_username)

      if player == nil do
        {:e404, "No players matching this Minecraft username found"}
      else
        case change(player, ip: nil) |> Repo.update() do
          {:ok, _} -> {:ok, "IP of #{player.mc_username} is reset"}
          {:e500, _} -> {:error, "Database error"}
        end
      end
    rescue
      _ -> {:e500, "Database error"}
    end
  end

  def reset_ip(:ds, ds_username) do
    ds_username = String.downcase(ds_username)
    try do
      player = Repo.get_by(Player, ds_username: ds_username)

      if player == nil do
        {:e404, "No players matching this Discord username found"}
      else
        case change(player, ip: nil) |> Repo.update() do
          {:ok, _} -> {:ok, "IP of #{player.ds_username} is reset"}
          {:e500, _} -> {:error, "Database error"}
        end
      end
    rescue
      _ -> {:e500, "Database error"}
    end
  end

  def delete(:mc, mc_username) do
    mc_username = String.downcase(mc_username)
    try do
      player = Repo.get_by(Player, mc_username: mc_username)

      if player == nil do
        {:e404, "No players matching this Minecraft username found"}
      else
        case Repo.delete(player) do
          {:ok, _} -> {:ok, "User #{player.mc_username} deleted"}
          {:e500, _} -> {:error, "Database error"}
        end
      end
    rescue
      _ -> {:e500, "Database error"}
    end
  end

  def delete(:ds, ds_username) do
    ds_username = String.downcase(ds_username)
    try do
      player = Repo.get_by(Player, ds_username: ds_username)

      if player == nil do
        {:e404, "No players matching this Discord username found"}
      else
        case Repo.delete(player) do
          {:ok, _} -> {:ok, "User #{player.ds_username} deleted"}
          {:e500, _} -> {:error, "Database error"}
        end
      end
    rescue
      _ -> {:e500, "Database error"}
    end
  end
end
