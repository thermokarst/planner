defmodule Planner.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tasks" do
    field(:value, :string)
    field(:finished_at, :naive_datetime)
    field(:due_at, :naive_datetime)

    many_to_many(:plans, Planner.Tasks.Plan, join_through: "plan_details", on_delete: :delete_all)

    timestamps()
  end

  def changeset(task, attrs) do
    task
    |> cast(attrs, [:value, :finished_at, :due_at])
    |> validate_required([:value])
    |> update_change(:value, &String.trim/1)
  end

  def finish_task(task) do
    # TODO, this should check if `finished_at` is not nil, first
    change(task, finished_at: now())
  end

  def unfinish_task(task) do
    change(task, finished_at: nil)
  end

  def preview(task) do
    hd(String.split(task.value, "\n"))
  end

  defp now(), do: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
end
