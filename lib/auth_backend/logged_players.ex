defmodule AuthBackend.LoggedPlayers do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def add(mc_username, status) do
    mc_username = String.downcase(mc_username)
    delete(mc_username)

    Task.start(fn ->
      Process.sleep(30_000)
      delete(mc_username)
    end)

    Agent.update(__MODULE__, fn state -> Map.put_new(state, mc_username, status) end)
  end

  def mem(mc_username) do
    mc_username = String.downcase(mc_username)
    aux = fn state ->
      tmp = Map.get(state, mc_username)

      if tmp == nil do
        false
      else
        tmp
      end
    end

    Agent.get(__MODULE__, aux)
  end

  def delete(mc_username) do
    mc_username = String.downcase(mc_username)
    Agent.update(__MODULE__, fn state -> Map.delete(state, mc_username) end)
  end

  def debug do
    Agent.get(__MODULE__, fn state -> state end)
  end
end
