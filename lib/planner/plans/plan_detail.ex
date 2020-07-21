defmodule Planner.Plans.PlanDetail do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "plan_details" do
    field :sort, :integer
    field :task_id, :binary_id
    field :plan_id, :binary_id
  end

  @doc false
  def changeset(plan_detail, attrs) do
    plan_detail
    |> cast(attrs, [:sort])
    |> validate_required([:sort])
  end
end
