defmodule Planner.Repo.Migrations.CreatePlans do
  use Ecto.Migration

  def change do
    create table(:plans, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :start, :naive_datetime, null: true
      add :end, :naive_datetime, null: true
      add :done, :boolean, default: false, null: false
      add :description, :string

      timestamps()
    end
  end
end
