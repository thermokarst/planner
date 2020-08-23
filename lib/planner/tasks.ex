defmodule Planner.Tasks do
  import Ecto.Query

  alias Ecto.UUID
  alias Planner.Repo
  alias Planner.Tasks.Task
  alias Planner.Tasks.Plan
  alias Planner.Tasks.PlanDetail

  def list_all_tasks, do: Repo.all(Task)

  def list_unfinished_tasks do
    from(
      t in Task,
      where: is_nil(t.finished_at),
      order_by: [desc: t.updated_at]
    )
    |> Repo.all()
  end

  def list_unfinished_tasks_by_plan_id(plan_id) do
    q =
      Ecto.Query.from(
        t in Task,
        join: pd in PlanDetail,
        on: t.id == pd.task_id,
        where: pd.plan_id == ^plan_id
      )

    Repo.all(q)
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

  def get_task!(id), do: Repo.get!(Task, id)

  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  def delete_task_by_id!(id) do
    get_task!(id)
    |> Repo.delete()
  end

  def change_task(%Task{} = task) do
    task
    |> Task.changeset(%{})
  end

  def task_exists?(id), do: Repo.exists?(from(t in Task, where: t.id == ^id))

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
      _ -> task_exists?(task_id)
    end
  end

  def list_plans do
    Repo.all(Plan)
  end

  def list_unfinished_plans do
    from(
      p in Plan,
      where: p.done == false,
      order_by: [desc: p.updated_at]
    )
    |> Repo.all()
  end

  def get_plan!(id), do: Repo.get!(Plan, id)

  def create_plan(attrs \\ %{}) do
    %Plan{}
    |> Plan.changeset(attrs)
    |> Repo.insert()
  end

  def update_plan(%Plan{} = plan, attrs) do
    plan
    |> Plan.changeset(attrs)
    |> Repo.update()
  end

  def delete_plan(%Plan{} = plan) do
    Repo.delete(plan)
  end

  def change_plan(%Plan{} = plan, attrs \\ %{}) do
    Plan.changeset(plan, attrs)
  end

  def plan_exists?(id), do: Repo.exists?(from(p in Plan, where: p.id == ^id))

  def verify_plan_id_from_url(plan_id) do
    plan_id =
      case UUID.dump(plan_id) do
        # don't actually want the dumped UUID, so discard
        {:ok, _} -> plan_id
        :error -> :error
      end

    case plan_id do
      :error -> :error
      _ -> plan_exists?(plan_id)
    end
  end

  def list_plan_details do
    Repo.all(PlanDetail)
  end

  def get_plan_detail!(id), do: Repo.get!(PlanDetail, id)

  def get_plan_detail_by!(clauses), do: Repo.get_by!(PlanDetail, clauses)

  def create_plan_detail(attrs \\ %{}, on_conflict \\ :nothing) do
    %PlanDetail{}
    |> PlanDetail.changeset(attrs)
    |> Repo.insert(on_conflict: on_conflict)
  end

  def update_plan_detail(%PlanDetail{} = plan_detail, attrs) do
    plan_detail
    |> PlanDetail.changeset(attrs)
    |> Repo.update()
  end

  def delete_plan_detail(%PlanDetail{} = plan_detail) do
    Repo.delete(plan_detail)
  end

  def change_plan_detail(%PlanDetail{} = plan_detail, attrs \\ %{}) do
    PlanDetail.changeset(plan_detail, attrs)
  end
end
