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
    if(!is_nil(socket.assigns.active_task),
      do: send_update(TaskComponent, id: socket.assigns.active_task, is_active: false)
    )

    case UUID.dump(task_id) do
      {:ok, _} ->
        case Tasks.exists?(task_id) do
          true ->
            socket =
              socket
              |> assign(:active_task, task_id)

            send_update(TaskComponent, id: task_id, is_active: true)
            {:noreply, socket}

          _ ->
            {:noreply, push_patch(socket, to: Routes.tmp_path(socket, :index))}
        end

      _ ->
        {:noreply, push_patch(socket, to: Routes.tmp_path(socket, :index))}
    end
  end

  def handle_params(_, _, socket) do
    socket =
      socket
      |> assign(:active_task, nil)

    {:noreply, socket}
  end

  def render(assigns) do
    ~L"""
    <div phx-window-keydown="keydown" phx-key="Escape">
      <%= live_component @socket, TasksComponent, tasks: @tasks %>
    </div>
    """
  end

  def handle_event("keydown", _params, socket) do
    case socket.assigns.live_action do
      :index ->
        {:noreply, socket}

      _ ->
        socket =
          socket
          |> push_patch(to: Routes.tmp_path(socket, :index))

        send_update(TaskComponent, id: socket.assigns.active_task, is_active: false)

        {:noreply, socket}
    end
  end
end
