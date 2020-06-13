defmodule Planner.Repo do
  use Ecto.Repo,
    otp_app: :planner,
    adapter: Ecto.Adapters.Postgres
end
