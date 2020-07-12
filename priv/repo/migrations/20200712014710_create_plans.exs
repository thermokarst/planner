defmodule Planner.Repo.Migrations.CreatePlans do
  use Ecto.Migration

  def change do
    create table(:plans, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string)
      add(:start, :naive_datetime)
      add(:end, :naive_datetime)
      add(:done, :boolean, default: false, null: false)
      add(:description, :string)

      timestamps()
    end

    create table("tasks_in_plans", primary_key: false) do
      add(:task_id, references(:tasks, type: :uuid))
      add(:plan_id, references(:plans, type: :uuid))
      add(:sort, :integer, null: true)

      timestamps()
    end
  end
end
