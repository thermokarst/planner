defmodule Planner.Repo.Migrations.InitialTasks do
  use Ecto.Migration

  def change do
    create table(:tasks, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:value, :text, null: false)
      add(:filed_at, :naive_datetime)
      add(:finished_at, :naive_datetime)
      add(:due_at, :naive_datetime)

      timestamps()
    end
  end
end
