defmodule Planner.Tasks do
  import Ecto.Query

  alias Ecto.Multi
  alias Ecto.UUID
  alias Planner.Repo
  alias Planner.Tasks.Task
  alias Planner.Tasks.Plan
  alias Planner.Tasks.PlanDetail

  def list_unfiled_tasks("true") do
    filed_ids = from(pd in PlanDetail, select: pd.task_id)

    from(
      t in Task,
      where: t.id not in subquery(filed_ids),
      order_by: [desc: t.updated_at]
    )
    |> Repo.all()
    |> Repo.preload(:plans)
  end

  def list_unfiled_tasks(_done) do
    filed_ids = from(pd in PlanDetail, select: pd.task_id)

    from(
      t in Task,
      where: is_nil(t.finished_at) and t.id not in subquery(filed_ids),
      order_by: [desc: t.updated_at]
    )
    |> Repo.all()
    |> Repo.preload(:plans)
  end

  def list_unfinished_tasks("true") do
    from(
      t in Task,
      order_by: [desc: t.updated_at]
    )
    |> Repo.all()
    |> Repo.preload(:plans)
  end

  def list_unfinished_tasks(_done) do
    from(
      t in Task,
      where: is_nil(t.finished_at),
      order_by: [desc: t.updated_at]
    )
    |> Repo.all()
    |> Repo.preload(:plans)
  end

  def list_tasks_by_plan_id("true", plan_id, task_id) do
    q =
      Ecto.Query.from(
        t in Task,
        join: pd in PlanDetail,
        on: t.id == pd.task_id,
        where: (pd.plan_id == ^plan_id)
                or
               (pd.plan_id == ^plan_id and t.id == ^task_id),
        order_by: [desc: t.updated_at]
      )

    Repo.all(q)
    |> Repo.preload(:plans)
  end

  def list_tasks_by_plan_id(_done, plan_id, task_id) do
    q =
      Ecto.Query.from(
        t in Task,
        join: pd in PlanDetail,
        on: t.id == pd.task_id,
        where: (pd.plan_id == ^plan_id and is_nil(t.finished_at))
                or
               (pd.plan_id == ^plan_id and t.id == ^task_id),
        order_by: [desc: t.updated_at]
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
    |> Repo.preload(:plans)
  end

  def get_task!(id), do: Repo.get!(Task, id)

  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def create_task_and_add_to_plan(task_attrs, plan) do
    Multi.new()
    |> Multi.insert(:task, Task.changeset(%Task{}, task_attrs))
    |> Multi.run(:plan_detail, fn _repo, %{task: task} ->
      create_plan_detail(%{"task_id" => task.id, "plan_id" => plan.id})
    end)
    |> Repo.transaction()
  end

  def update_task(%Task{} = task, attrs) do
    plans = Map.get(attrs, "plans", [])

    new_plan_details_changesets = Enum.map(plans, fn(plan_id) ->
      PlanDetail.changeset(%PlanDetail{}, %{"task_id" => task.id, "plan_id" => plan_id})
    end)

    deleted_plan_details =
      Ecto.Query.from(
        pd in PlanDetail,
        where: pd.task_id == ^task.id and pd.plan_id not in ^plans
      )

    multi =
      Enum.reduce(
       new_plan_details_changesets,
        Multi.new()
        |> Multi.update(:task, Task.changeset(task, attrs))
        |> Multi.delete_all(:deleted_plan_details, deleted_plan_details),
        fn(changeset, new_multi) ->
          Multi.insert(
            new_multi,
            changeset.params["plan_id"],
            changeset,
            on_conflict: :nothing
          )
        end
      )

    Repo.transaction(multi)
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

  def unfinish_task_by_id!(id) do
    get_task!(id)
    |> Task.unfinish_task()
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
      where: is_nil(p.finished_at),
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

  def finish_plan_by_id!(id) do
    get_plan!(id)
    |> Plan.finish_plan()
    |> Repo.update()
  end

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
