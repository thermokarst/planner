defmodule Planner.Repo.Migrations.CreatePlans do
  use Ecto.Migration

  def change do
    create table(:plans) do
      add :id, :binary
      add :name, :string
      add :start, :naive_datetime
      add :end, :naive_datetime
      add :done, :boolean, default: false, null: false
      add :description, :string

      timestamps()
    end

  end
end
