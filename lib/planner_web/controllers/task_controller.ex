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

  def edit(conn, %{"id" => id}) do
    task = Tasks.get_task!(id)
    changeset = Tasks.change_task(task)

    conn
    |> assign(:task, task)
    |> assign(:changeset, changeset)
    |> render("edit.html")
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    task = Tasks.get_task!(id)

    case Tasks.update_task(task, task_params) do
      {:ok, _task} ->
        conn
        |> put_flash(:info, "task updated")
        |> redirect(to: Routes.task_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> assign(:task, task)
        |> assign(:changeset, changeset)
        |> render("edit.html")
    end
  end
end
