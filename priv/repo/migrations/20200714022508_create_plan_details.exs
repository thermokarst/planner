defmodule Planner.Repo.Migrations.CreatePlanDetails do
  use Ecto.Migration

  def change do
    create table(:plan_details, primary_key: false) do
      add :sort, :integer
      add :task_id, references(:tasks, on_delete: :nothing, type: :binary_id)
      add :plan_id, references(:plans, on_delete: :nothing, type: :binary_id)
    end

    create index(:plan_details, [:task_id])
    create index(:plan_details, [:plan_id])
  end
end
