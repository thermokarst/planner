defmodule Planner.Repo.Migrations.RemoveUnusedFieldsFromPlans do
  use Ecto.Migration

  def change do
    alter table(:plans) do
      remove(:start)
      remove(:end)
      remove(:description)
    end
  end
end
