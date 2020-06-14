defmodule Planner.Tasks do
  import Ecto.Query
  alias Planner.Repo
  alias Planner.Tasks.Task

  def add_task(attrs) do
    %Task{}
    |> Task.changeset()
    |> Repo.insert()
  end

  def list_tasks, do: Repo.all(Task)
end
