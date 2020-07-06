defmodule PlannerWeb.TasksLive do
  use Phoenix.LiveView, layout: {PlannerWeb.LayoutView, "live.html"}
  use Phoenix.HTML

  alias Ecto.UUID
  alias PlannerWeb.Router.Helpers, as: Routes
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
    case UUID.dump(task_id) do
      {:ok, _} ->
        case Tasks.exists?(task_id) do
          true -> {:noreply, assign(socket, :active_task, task_id)}
          _ -> {:noreply, push_patch(socket, to: Routes.tasks_path(socket, :index))}
        end

      _ ->
        {:noreply, push_patch(socket, to: Routes.tasks_path(socket, :index))}
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
end
