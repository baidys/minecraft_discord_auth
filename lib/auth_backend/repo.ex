defmodule AuthBackend.Repo do
  use Ecto.Repo,
    otp_app: :auth_backend,
    adapter: Ecto.Adapters.SQLite3
end
