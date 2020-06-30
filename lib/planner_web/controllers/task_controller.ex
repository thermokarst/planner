defmodule PlannerWeb.TaskController do
  use PlannerWeb, :controller

  alias Planner.Tasks
  alias Planner.Tasks.Task

  def index(conn, _params) do
    tasks = Tasks.list_unfinished_tasks()

    conn
    |> assign(:tasks, tasks)
    |> render("index.html")
  end

  def new(conn, _params) do
    task = %Task{}
    changeset = Tasks.change_task(%Task{})

    conn
    |> assign(:task, task)
    |> assign(:changeset, changeset)
    |> render("new.html")
  end

  def create(conn, %{"task" => task_params}) do
    case Tasks.add_task(task_params) do
      {:ok, _task} ->
        conn
        |> put_flash(:info, "task created")
        |> redirect(to: Routes.task_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> assign(:task, %Task{})
        |> assign(:changeset, changeset)
        |> render("new.html")
    end
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

  # this is a little bit of a hack, but it'll do for now:
  # pattern match on the empty case, we will assume this
  # is a "task finished" action
  def update(conn, %{"id" => id}) do
    {_, task} = Tasks.finish_task_by_id!(id)

    conn
    |> put_flash(:info, "task '#{task.value}' finished")
    |> redirect(to: Routes.task_path(conn, :index))
  end

  def delete(conn, %{"id" => id}) do
    {:ok, _task} = Tasks.delete_task_by_id!(id)

    conn
    |> put_flash(:info, "task deleted")
    |> redirect(to: Routes.task_path(conn, :index))
  end
end
