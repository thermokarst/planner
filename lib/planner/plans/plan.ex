defmodule Planner.Plans.Plan do
  use Ecto.Schema
  import Ecto.Changeset

  schema "plans" do
    field :description, :string
    field :done, :boolean, default: false
    field :end, :naive_datetime
    field :id, :binary
    field :name, :string
    field :start, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(plan, attrs) do
    plan
    |> cast(attrs, [:id, :name, :start, :end, :done, :description])
    |> validate_required([:id, :name, :start, :end, :done, :description])
  end
end
