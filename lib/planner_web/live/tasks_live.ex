defmodule PlannerWeb.TasksLive do
  use PlannerWeb, :live_view

  alias Planner.Tasks

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:tasks, Tasks.list_unfinished_tasks())
      |> assign(:active_task, nil)

    {:ok, socket}
  end

  def handle_params(%{"id" => task_id}, _, socket) do
    case Tasks.verify_task_id_from_url(task_id) do
      true -> {:noreply, assign(socket, :active_task, task_id)}
      _ -> {:noreply, push_patch(socket, to: Routes.tasks_path(socket, :index))}
    end
  end

  def handle_params(_, _, socket) do
    {:noreply, assign(socket, :active_task, nil)}
  end

  def render(assigns) do
    ~L"""
    <div phx-window-keydown="keydown" phx-key="Escape">
      <%= live_component(@socket,
        TasksComponent,
        id: :all_unfinished_tasks,
        action: @live_action,
        tasks: @tasks,
        active_task: @active_task,
        route_show_task: &(Routes.tasks_path(&1, :show, &2)),
        route_edit_task: &(Routes.tasks_path(&1, :edit, &2)),
        route_index_tasks: &(Routes.tasks_path(&1, :index))
      )%>
    </div>
    """
  end

  def handle_event("keydown", _params, socket) do
    case socket.assigns.live_action do
      :index -> {:noreply, socket}
      _ -> {:noreply, push_patch(socket, to: Routes.tasks_path(socket, :index))}
    end
  end

  def handle_event("save-task", %{"task" => task_params}, socket) do
    task = Tasks.get_task!(task_params["id"])

    case Tasks.update_task(task, task_params) do
      {:ok, task} ->
        # I suspect splicing in the updated task isn't much faster than just refreshing the whole list
        socket =
          socket
          |> refresh_tasks_and_flash_msg("task \"#{task.value}\" updated")

        {:noreply, push_patch(socket, to: Routes.tasks_path(socket, :show, task.id))}

      {:error, changeset} ->
        send_update(TaskEditComponent, id: "task_edit:#{task.id}", changeset: changeset)
        {:noreply, socket}
    end
  end

  def handle_event("finish-task", %{"task-id" => task_id}, socket) do
    {_, task} = Tasks.finish_task_by_id!(task_id)
    {:noreply, refresh_tasks_and_flash_msg(socket, "task \"#{task.value}\" completed")}
  end

  def handle_event("delete-task", %{"task-id" => task_id}, socket) do
    {_, task} = Tasks.delete_task_by_id!(task_id)
    {:noreply, refresh_tasks_and_flash_msg(socket, "task \"#{task.value}\" deleted")}
  end

  def handle_event("new-task", %{"task" => task_params}, socket) do
    case Tasks.add_task(task_params) do
      {:ok, task} ->
        socket =
          socket
          |> refresh_tasks_and_flash_msg("task \"#{task.value}\" created")

        {:noreply, push_patch(socket, to: Routes.tasks_path(socket, :show, task.id))}

      {:error, %Ecto.Changeset{} = changeset} ->
        send_update(TasksComponent, id: :all_unfinished_tasks, changeset: changeset)
        {:noreply, socket}
    end
  end

  defp refresh_tasks_and_flash_msg(socket, msg) do
    socket
    |> assign(:tasks, Tasks.list_unfinished_tasks())
    |> put_flash(:info, msg)
  end
end
