defmodule AuthBackend.LoggedPlayers do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def addPlayer(mc_username, logged) do
    user = String.to_atom(mc_username)
    Agent.update(__MODULE__, fn state -> Map.put_new(state, user, logged) end)
  end

  def mem(mc_username) do
    user = String.to_atom(mc_username)

    aux = fn state ->
      tmp = Map.get(state, user)

      if tmp == nil do
        false
      else
        tmp
      end
    end

    Agent.get(__MODULE__, aux)
  end

  def removePlayer(mc_username) do
    user = String.to_atom(mc_username)
    Agent.update(__MODULE__, fn state -> Map.delete(state, user) end)
  end

  def debug do
    Agent.get(__MODULE__, fn state -> state end)
  end
end
