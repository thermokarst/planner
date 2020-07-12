defmodule Planner.Plans.Plan do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "plans" do
    field(:description, :string)
    field(:done, :boolean, default: false)
    field(:end, :naive_datetime)
    field(:name, :string)
    field(:start, :naive_datetime)
    many_to_many(:tasks, Planner.Tasks.Task, join_through: "tasks_in_plans")

    timestamps()
  end

  @doc false
  def changeset(plan, attrs) do
    plan
    |> cast(attrs, [:id, :name, :start, :end, :done, :description])
    |> validate_required([:id, :name, :start, :end, :done, :description])
  end
end
