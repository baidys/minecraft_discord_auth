defmodule AuthBackendWeb.ApiController do
  use AuthBackendWeb, :controller
  alias AuthBackend.Players
  alias AuthBackend.LoggedPlayers

  def create(conn, %{"mc_username" => mc_username, "ds_username" => ds_username}) do
    if checkKey?(get_req_header(conn, "secret")) do
      case Players.create(mc_username, ds_username, nil) do
        {:e500, error} -> conn |> put_status(500) |> json(%{error: error})
        {:e409, error} -> conn |> put_status(409) |> json(%{error: error})
        {:ok, message} -> json(conn, %{ok: message})
      end
    else
      conn |> put_status(403) |> json(%{error: "Some values are missing"})
    end
  end

  def create(conn, _params) do
    conn |> put_status(422) |> json(%{error: "Some values are missing"})
  end

  def logged(conn, %{"mc_username" => mc_username}) do
    if checkKey?(get_req_header(conn, "secret")) do
      json(conn, %{logged: LoggedPlayers.mem(mc_username)})
    else
      conn |> put_status(403) |> json(%{error: "Some values are missing"})
    end
  end

  def logged(conn, _params) do
    conn |> put_status(422) |> json(%{error: "Some values are missing"})
  end

  def templog(conn, %{"mc_username" => mc_username}) do
    if checkKey?(get_req_header(conn, "secret")) do
      Task.async(fn -> LoggedPlayers.add(mc_username, true) end)
      json(conn, %{ok: "player #{mc_username}'s state is now : 'logged' "})
    else
      conn |> put_status(403) |> json(%{error: "Some values are missing"})
    end
  end

  def templog(conn, _params) do
    conn |> put_status(422) |> json(%{error: "Some values are missing"})
  end

  def show(conn, %{"mc_username" => mc_username}) do
    if checkKey?(get_req_header(conn, "secret")) do
      case Players.get_info(:mc, mc_username) do
        {:ok, data} -> json(conn, data)
        {:e404, error} -> conn |> put_status(404) |> json(%{error: error})
        {:e500, error} -> conn |> put_status(500) |> json(%{error: error})
      end
    else
      conn |> put_status(403) |> json(%{error: "Some values are missing"})
    end
  end

  def show(conn, %{"ds_username" => ds_username}) do
    if checkKey?(get_req_header(conn, "secret")) do
      case Players.get_info(:ds, ds_username) do
        {:ok, data} -> json(conn, data)
        {:e404, error} -> conn |> put_status(404) |> json(%{error: error})
        {:e500, error} -> conn |> put_status(500) |> json(%{error: error})
      end
    else
      conn |> put_status(403) |> json(%{error: "Some values are missing"})
    end
  end

  def show(conn, _params) do
    conn |> put_status(422) |> json(%{error: "Some values are missing"})
  end

  def edit(conn, %{"mc_username" => mc_username, "new_ds_username" => ds_username}) do
    if checkKey?(get_req_header(conn, "secret")) do
      case(Players.edit(:mc, mc_username, ds_username)) do
        {:ok, message} -> json(conn, %{ok: message})
        {:e404, error} -> conn |> put_status(404) |> json(%{error: error})
        {:e500, error} -> conn |> put_status(500) |> json(%{error: error})
      end
    else
      conn |> put_status(403) |> json(%{error: "Some values are missing"})
    end
  end

  def edit(conn, %{"ds_username" => ds_username, "new_mc_username" => mc_username}) do
    if checkKey?(get_req_header(conn, "secret")) do
      case(Players.edit(:ds, ds_username, mc_username)) do
        {:ok, message} -> json(conn, %{ok: message})
        {:e404, error} -> conn |> put_status(404) |> json(%{error: error})
        {:e500, error} -> conn |> put_status(500) |> json(%{error: error})
      end
    else
      conn |> put_status(403) |> json(%{error: "Some values are missing"})
    end
  end

  def edit(conn, _params) do
    conn |> put_status(422) |> json(%{error: "Some values are missing"})
  end

  def reset_ip(conn, %{"mc_username" => mc_username}) do
    if checkKey?(get_req_header(conn, "secret")) do
      case(Players.reset_ip(:mc, mc_username)) do
        {:ok, message} -> json(conn, %{ok: message})
        {:e404, error} -> conn |> put_status(404) |> json(%{error: error})
        {:e500, error} -> conn |> put_status(500) |> json(%{error: error})
      end
    else
      conn |> put_status(403) |> json(%{error: "Some values are missing"})
    end
  end

  def reset_ip(conn, %{"ds_username" => ds_username}) do
    if checkKey?(get_req_header(conn, "secret")) do
      case(Players.reset_ip(:ds, ds_username)) do
        {:ok, message} -> json(conn, %{ok: message})
        {:e404, error} -> conn |> put_status(404) |> json(%{error: error})
        {:e500, error} -> conn |> put_status(500) |> json(%{error: error})
      end
    else
      conn |> put_status(403) |> json(%{error: "Some values are missing"})
    end
  end

  def reset_ip(conn, _params) do
    conn |> put_status(422) |> json(%{error: "Some values are missing"})
  end

  def delete(conn, %{"mc_username" => mc_username}) do
    if checkKey?(get_req_header(conn, "secret")) do
      case(Players.delete(:mc, mc_username)) do
        {:ok, message} -> json(conn, %{ok: message})
        {:e404, error} -> conn |> put_status(404) |> json(%{error: error})
        {:e500, error} -> conn |> put_status(500) |> json(%{error: error})
      end
    else
      conn |> put_status(403) |> json(%{error: "Some values are missing"})
    end
  end

  def delete(conn, %{"ds_username" => ds_username}) do
    if checkKey?(get_req_header(conn, "secret")) do
      case(Players.delete(:ds, ds_username)) do
        {:ok, message} -> json(conn, %{ok: message})
        {:e404, error} -> conn |> put_status(404) |> json(%{error: error})
        {:e500, error} -> conn |> put_status(500) |> json(%{error: error})
      end
    else
      conn |> put_status(403) |> json(%{error: "Some values are missing"})
    end
  end

  def delete(conn, _params) do
    conn |> put_status(422) |> json(%{error: "Some values are missing"})
  end

  defp checkKey?([]), do: false

  defp checkKey?([provided_secret]) do
    secret = Application.get_env(:auth_backend, :smp_secret)

    if :crypto.hash_equals(
         :crypto.hash(:sha256, secret),
         :crypto.hash(:sha256, provided_secret)
       ) do
      true
    else
      false
    end
  end

  defp checkKey?(_), do: false
end
