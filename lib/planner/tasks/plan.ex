defmodule Planner.Tasks.Plan do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "plans" do
    field :description, :string
    field :done, :boolean, default: false
    field :end, :naive_datetime
    field :name, :string
    field :start, :naive_datetime

    timestamps()
  end

  def changeset(plan, attrs) do
    plan
    |> cast(attrs, [:description, :done, :start, :end, :name])
    |> validate_required([:name])
  end
end
