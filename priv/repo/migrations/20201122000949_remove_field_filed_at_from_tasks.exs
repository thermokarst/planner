defmodule Planner.Repo.Migrations.RemoveFieldFiledAtFromTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      remove(:filed_at)
    end
  end
end
