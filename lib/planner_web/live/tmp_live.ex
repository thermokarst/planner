defmodule PlannerWeb.TmpLive do
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

defmodule TasksComponent do
  use Phoenix.LiveComponent

  import PlannerWeb.Util

  def render(assigns) do
    ~L"""
    <div class="content">
      <ul class="tasks">
        <%= for task <- @tasks do %>
          <%= live_component @socket, TaskComponent, id: task.id, task: task %>
        <% end %>
      </ul>
    </div>
    """
  end
end

defmodule TaskComponent do
  use Phoenix.LiveComponent

  import PlannerWeb.Util

  alias PlannerWeb.Router.Helpers, as: Routes

  def mount(socket) do
    socket =
      socket
      |> assign(:is_active, nil)

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <li>
      <div>
        <div class="is-pulled-left">
          <button type="button" role="checkbox" class="doit"></button>
        </div>
        <div class="ml-5-5">
          <%= if(@is_active) do %>
            <div class="box">
              <button class="delete is-pulled-right" phx-click="hide-task-details" phx-target="<%= @myself %>"></button>
              <%= if not is_nil(@task.due_at) or is_nil(@task.filed_at) do %>
                <div class="tags">
                  <%= if not is_nil(@task.due_at) do %><span class="tag is-warning">due: <%= @task.due_at %></span><% end %>
                  <%= if is_nil(@task.filed_at) do %><span class="tag is-danger">unfiled</span><% end %>
                </div>
              <% end %>

              <div class="mb-5">
                <%= md_to_html @task.value %>
              </div>

              <div class="tags">
                <span class="tag is-light">updated: <%= @task.updated_at %></span>
                <span class="tag is-light">created: <%= @task.inserted_at %></span>
              </div>
            </div>
          <% else %>
            <a style="display: block;" phx-click="show-task-details" phx-value-task-id="<%= @task.id %>" phx-target="<%= @myself %>">
              <div class="value ">
                <%= md_to_html(@task.value) %>
              </div>
            </a>
            <%= if not is_nil(@task.due_at) do %>
              <div class="tags mb-0">
                <span class="tag">
                  due: <%= @task.due_at %>
                </span>
              </div>
            <% end %>
          <% end %>
        </div>
      </div>
    </li>
    """
  end

  def handle_event("show-task-details", %{"task-id" => task_id}, socket) do
    socket =
      socket
      |> assign(:is_active, true)
      |> push_patch(to: Routes.tmp_path(socket, :show, task_id))

    {:noreply, socket}
  end

  def handle_event("hide-task-details", _, socket) do
    socket =
      socket
      |> assign(:is_active, false)
      |> push_patch(to: Routes.tmp_path(socket, :index))

    {:noreply, socket}
  end
end
