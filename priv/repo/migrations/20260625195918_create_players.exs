defmodule AuthBackend.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :ds_username, :string
      add :mc_username, :string
      add :ip, :string

      timestamps(type: :utc_datetime)
    end
  end
end
