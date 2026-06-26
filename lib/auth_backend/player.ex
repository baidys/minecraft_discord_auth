defmodule AuthBackend.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :ds_username, :string
    field :mc_username, :string
    field :ip, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:ds_username, :mc_username, :ip])
    |> validate_required([:ds_username, :mc_username, :ip])
  end
end
