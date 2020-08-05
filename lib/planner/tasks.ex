defmodule Planner.Tasks do
  import Ecto.Query
  alias Ecto.UUID
  alias Planner.Repo
  alias Planner.Tasks.Task
  alias Planner.Plans.PlanDetail
  alias Ecto.Multi

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
    |> Repo.preload(:plans)
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

    task_changeset = Task.changeset(task, attrs)

    pd_attrs = Enum.map(attrs["plans"], &(%{"task_id" => attrs["id"], "plan_id" => &1, "sort" => 0}))
    plan_changesets = Enum.map(pd_attrs, &(PlanDetail.changeset(%PlanDetail{}, &1)))
    multi = Enum.reduce(plan_changesets, Multi.new() |> Multi.update(:task, task_changeset),
      fn(changeset, new_multi) ->
      Multi.insert(
        new_multi,
        changeset.params["plan_id"],
        changeset,
        on_conflict: :nothing,
      )
    end)

    {:ok, results} = Repo.transaction(multi)
    {:ok, results[:task]}
  end

  def get_task!(id), do: Repo.get!(Task, id)

  def exists?(id), do: Repo.exists?(from(t in Task, where: t.id == ^id))

  def delete_task_by_id!(id) do
    get_task!(id)
    |> Repo.delete()
  end

  def finish_task_by_id!(id) do
    get_task!(id)
    |> Task.finish_task()
    |> Repo.update()
  end

  def verify_task_id_from_url(task_id) do
    task_id =
      case UUID.dump(task_id) do
        # don't actually want the dumped UUID, so discard
        {:ok, _} -> task_id
        :error -> :error
      end

    case task_id do
      :error -> :error
      _ -> exists?(task_id)
    end
  end
end
