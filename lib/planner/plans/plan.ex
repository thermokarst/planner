defmodule Planner.Plans.Plan do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "plans" do
    field :description, :string
    field :done, :boolean, default: false
    field :start, :naive_datetime
    field :end, :naive_datetime
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(plan, attrs) do
    plan
    |> cast(attrs, [:name, :start, :end, :done, :description])
    |> validate_required([:name])
  end
end
