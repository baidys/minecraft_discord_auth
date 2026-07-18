defmodule AuthBackend.Ratelimit do
  use Hammer, backend: :ets
end
