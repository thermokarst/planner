defmodule Planner.Plans do
  @moduledoc """
  The Plans context.
  """

  import Ecto.Query, warn: false
  alias Planner.Repo

  alias Planner.Plans.Plan

  @doc """
  Returns the list of plans.

  ## Examples

      iex> list_plans()
      [%Plan{}, ...]

  """
  def list_plans do
    Repo.all(Plan)
  end

  @doc """
  Gets a single plan.

  Raises `Ecto.NoResultsError` if the Plan does not exist.

  ## Examples

      iex> get_plan!(123)
      %Plan{}

      iex> get_plan!(456)
      ** (Ecto.NoResultsError)

  """
  def get_plan!(id), do: Repo.get!(Plan, id)

  @doc """
  Creates a plan.

  ## Examples

      iex> create_plan(%{field: value})
      {:ok, %Plan{}}

      iex> create_plan(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_plan(attrs \\ %{}) do
    %Plan{}
    |> Plan.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a plan.

  ## Examples

      iex> update_plan(plan, %{field: new_value})
      {:ok, %Plan{}}

      iex> update_plan(plan, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_plan(%Plan{} = plan, attrs) do
    plan
    |> Plan.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a plan.

  ## Examples

      iex> delete_plan(plan)
      {:ok, %Plan{}}

      iex> delete_plan(plan)
      {:error, %Ecto.Changeset{}}

  """
  def delete_plan(%Plan{} = plan) do
    Repo.delete(plan)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking plan changes.

  ## Examples

      iex> change_plan(plan)
      %Ecto.Changeset{data: %Plan{}}

  """
  def change_plan(%Plan{} = plan, attrs \\ %{}) do
    Plan.changeset(plan, attrs)
  end

  alias Planner.Plans.PlanDetail

  @doc """
  Returns the list of plan_details.

  ## Examples

      iex> list_plan_details()
      [%PlanDetail{}, ...]

  """
  def list_plan_details do
    Repo.all(PlanDetail)
  end

  @doc """
  Gets a single plan_detail.

  Raises `Ecto.NoResultsError` if the Plan detail does not exist.

  ## Examples

      iex> get_plan_detail!(123)
      %PlanDetail{}

      iex> get_plan_detail!(456)
      ** (Ecto.NoResultsError)

  """
  def get_plan_detail!(id), do: Repo.get!(PlanDetail, id)

  @doc """
  Creates a plan_detail.

  ## Examples

      iex> create_plan_detail(%{field: value})
      {:ok, %PlanDetail{}}

      iex> create_plan_detail(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_plan_detail(attrs \\ %{}) do
    %PlanDetail{}
    |> PlanDetail.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a plan_detail.

  ## Examples

      iex> update_plan_detail(plan_detail, %{field: new_value})
      {:ok, %PlanDetail{}}

      iex> update_plan_detail(plan_detail, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_plan_detail(%PlanDetail{} = plan_detail, attrs) do
    plan_detail
    |> PlanDetail.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a plan_detail.

  ## Examples

      iex> delete_plan_detail(plan_detail)
      {:ok, %PlanDetail{}}

      iex> delete_plan_detail(plan_detail)
      {:error, %Ecto.Changeset{}}

  """
  def delete_plan_detail(%PlanDetail{} = plan_detail) do
    Repo.delete(plan_detail)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking plan_detail changes.

  ## Examples

      iex> change_plan_detail(plan_detail)
      %Ecto.Changeset{data: %PlanDetail{}}

  """
  def change_plan_detail(%PlanDetail{} = plan_detail, attrs \\ %{}) do
    PlanDetail.changeset(plan_detail, attrs)
  end
end
