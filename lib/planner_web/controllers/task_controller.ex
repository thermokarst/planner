defmodule PlannerWeb.TaskController do
  use PlannerWeb, :controller

  alias Planner.Tasks

  def index(conn, _params) do
    tasks = Tasks.list_unfinished_tasks()

    conn
    |> assign(:tasks, tasks)
    |> render("index.html")
  end

  def show(conn, %{"id" => id}) do
    task = Tasks.get_task!(id)

    conn
    |> assign(:task, task)
    |> render("show.html")
  end
end
