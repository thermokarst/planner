defmodule PlannerWeb.TasksLive do
  use PlannerWeb, :live_view

  alias Planner.Tasks

  def mount(_params, _session, socket) do
    socket =
      socket
      |> clear_flash(:info)
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
        live_action: @live_action,
        tasks: @tasks,
        active_task: @active_task,
        route_func_2: &Routes.tasks_path/2,
        route_func_3: &Routes.tasks_path/3
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
        socket = assign(socket, :tasks, Tasks.list_unfinished_tasks())
        {:noreply, push_patch(socket, to: Routes.tasks_path(socket, :show, task.id))}

      {:error, changeset} ->
        send_update(TaskEditComponent, id: "task_edit:#{task.id}", changeset: changeset)
        {:noreply, socket}
    end
  end

  def handle_event("finish-task", %{"task-id" => task_id}, socket) do
    {_, task} = Tasks.finish_task_by_id!(task_id)

    socket =
      socket
      |> assign(:tasks, Tasks.list_unfinished_tasks())
      |> put_flash(:info, "task \"#{task.value}\" completed")

    {:noreply, socket}
  end
end
