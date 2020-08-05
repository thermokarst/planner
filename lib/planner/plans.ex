defmodule Planner.Plans do
  import Ecto.Query, warn: false

  alias Ecto.UUID
  alias Planner.Repo
  alias Planner.Plans.Plan
  alias Planner.Plans.PlanDetail
  alias Planner.Tasks.Task

  def list_plans do
    Repo.all(Plan)
  end

  def get_plan!(id), do: Repo.get!(Plan, id)

  def exists?(id), do: Repo.exists?(from(p in Plan, where: p.id == ^id))

  def get_tasks(id) do
    q =
      Ecto.Query.from(
        t in Task,
        join: pd in PlanDetail,
        on: t.id == pd.task_id,
        where: pd.plan_id == ^id
      )

    Repo.all(q)
    |> Repo.preload(:plans)
  end

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

  def verify_plan_id_from_url(plan_id) do
    plan_id =
      case UUID.dump(plan_id) do
        # don't actually want the dumped UUID, so discard
        {:ok, _} -> plan_id
        :error -> :error
      end

    case plan_id do
      :error -> :error
      _ -> exists?(plan_id)
    end
  end

  def list_plan_details do
    Repo.all(PlanDetail)
  end

  def get_plan_detail!(id), do: Repo.get!(PlanDetail, id)

  def create_plan_detail(attrs \\ %{}) do
    %PlanDetail{}
    |> PlanDetail.changeset(attrs)
    |> Repo.insert()
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
