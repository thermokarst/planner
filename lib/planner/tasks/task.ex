defmodule Planner.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tasks" do
    field(:value, :string)
    field(:filed_at, :naive_datetime)
    field(:finished_at, :naive_datetime)
    field(:due_at, :naive_datetime)

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:value, :filed_at, :due_at])
    |> cast(attrs, [:finished_at])
    |> validate_required([:value])
    |> validate_length(:value, min: 3)
  end
end
