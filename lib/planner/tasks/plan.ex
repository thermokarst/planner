defmodule Planner.Tasks.Plan do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "plans" do
    field :description, :string
    field :finished_at, :naive_datetime
    field :end, :naive_datetime
    field :name, :string
    field :start, :naive_datetime

    timestamps()
  end

  def changeset(plan, attrs) do
    plan
    |> cast(attrs, [:description, :finished_at, :start, :end, :name])
    |> validate_required([:name])
  end

  def finish_plan(plan) do
    # TODO, this should check if `finished_at` is not nil, first
    change(plan, finished_at: now())
  end

  defp now(), do: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
end
