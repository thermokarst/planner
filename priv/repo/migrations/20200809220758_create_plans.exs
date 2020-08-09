defmodule Planner.Repo.Migrations.CreatePlans do
  use Ecto.Migration

  def change do
    create table(:plans, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :string
      add :done, :boolean, default: false, null: false
      add :start, :naive_datetime
      add :end, :naive_datetime
      add :name, :string

      timestamps()
    end
  end
end
