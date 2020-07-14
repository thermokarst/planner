defmodule Planner.Plans do
  import Ecto.Query, warn: false
  alias Planner.Repo
  alias Planner.Plans.Plan
  alias Planner.Plans.PlanDetail

  def list_plans do
    Repo.all(Plan)
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
