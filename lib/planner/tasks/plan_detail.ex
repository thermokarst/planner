defmodule Planner.Tasks.PlanDetail do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "plan_details" do
    field :sort, :integer
    field :task_id, :binary_id
    field :plan_id, :binary_id

    timestamps()
  end

  def changeset(plan_detail, attrs) do
    plan_detail
    |> cast(attrs, [:sort, :task_id, :plan_id])
  end
end
