defmodule Planner.Tasks do
  import Ecto.Query
  alias Planner.Repo
  alias Planner.Tasks.Task

  def add_task(attrs) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def list_all_tasks, do: Repo.all(Task)

  def list_unfinished_tasks do
    from(
      t in Task,
      where: is_nil(t.finished_at)
    )
    |> Repo.all()
  end

  def change_task(%Task{} = task) do
    task
    |> Task.changeset(%{})
  end

  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  def get_task!(id), do: Repo.get!(Task, id)

  def delete_task_by_id!(id) do
    get_task!(id)
    |> Repo.delete()
  end
end
