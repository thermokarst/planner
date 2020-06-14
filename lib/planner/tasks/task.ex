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
    |> cast(attrs, [:value, :filed_at, :finished_at, :due_at])
    |> validate_required([:value])
    |> validate_length(:value, min: 3)
  end

  @doc false
  def finish_task(task) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    # TODO, this should check if `finished_at` is not nil, first
    change(task, finished_at: now)
  end
end
