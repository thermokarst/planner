defmodule Planner.Tasks do
  import Ecto.Query
  alias Planner.Repo
  alias Planner.Tasks.Task

  def add_task(attrs) do
    attrs =
      attrs
      |> cast_finished_at()

    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def list_all_tasks, do: Repo.all(Task)

  def list_unfinished_tasks do
    from(
      t in Task,
      where: is_nil(t.finished_at),
      order_by: [desc: t.updated_at]
    )
    |> Repo.all()
  end

  def list_finished_tasks do
    from(
      t in Task,
      where: not is_nil(t.finished_at),
      order_by: [desc: t.updated_at]
    )
    |> Repo.all()
  end

  def change_task(%Task{} = task) do
    task
    |> Task.changeset(%{})
  end

  def cast_finished_at(attrs) do
    attrs
    |> Map.update("finished_at", nil, fn
      "true" -> NaiveDateTime.utc_now()
      "false" -> nil
      val -> val
    end)
  end

  def update_task(%Task{} = task, attrs) do
    attrs =
      attrs
      |> cast_finished_at()

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
