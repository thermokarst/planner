defmodule PlannerWeb.TmpLive do
  use Phoenix.LiveView, layout: {PlannerWeb.LayoutView, "live.html"}
  use Phoenix.HTML

  alias Ecto.UUID

  import PlannerWeb.ErrorHelpers

  alias PlannerWeb.Router.Helpers, as: Routes

  alias Planner.Tasks
  alias Planner.Tasks.Task

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
          true ->
            socket =
              socket
              |> assign(:active_task, task_id)

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
      <%= live_component @socket, TasksComponent, tasks: @tasks, active_task: @active_task %>
    </div>
    """
  end

  def handle_event("show-task-details", %{"task-id" => task_id}, socket) do
    socket =
      socket
      |> assign(:active_task, task_id)
      |> push_patch(to: Routes.tmp_path(socket, :show, task_id))

    {:noreply, socket}
  end

  def handle_event("hide-task-details", _, socket) do
    socket =
      socket
      |> assign(:active_task, nil)
      |> push_patch(to: Routes.tmp_path(socket, :index))

    {:noreply, socket}
  end

  def handle_event("keydown", %{"key" => key}, socket) do
    case socket.assigns.active_task do
      nil ->
        {:noreply, socket}

      _ ->
        socket =
          socket
          |> assign(:active_task, nil)
          |> push_patch(to: Routes.tmp_path(socket, :index))

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
          <li>
            <div>
              <div class="is-pulled-left">
                <button type="button" role="checkbox" class="doit"></button>
              </div>
              <div class="ml-5-5">
                <%= if(task.id == @active_task) do %>
                  <div class="box">
                    <button class="delete is-pulled-right" phx-click="hide-task-details"></button>
                    <%= if not is_nil(task.due_at) or is_nil(task.filed_at) do %>
                      <div class="tags">
                        <%= if not is_nil(task.due_at) do %><span class="tag is-warning">due: <%= task.due_at %></span><% end %>
                        <%= if is_nil(task.filed_at) do %><span class="tag is-danger">unfiled</span><% end %>
                      </div>
                    <% end %>

                    <div class="mb-5">
                      <%= md_to_html task.value %>
                    </div>

                    <div class="tags">
                      <span class="tag is-light">updated: <%= task.updated_at %></span>
                      <span class="tag is-light">created: <%= task.inserted_at %></span>
                    </div>
                  </div>
                <% else %>
                  <a style="display: block;" phx-click="show-task-details" phx-value-task-id="<%= task.id %>">
                    <div class="value ">
                      <%= md_to_html(task.value) %>
                    </div>
                  </a>
                  <%= if not is_nil(task.due_at) do %>
                    <div class="tags mb-0">
                      <span class="tag">
                        due: <%= task.due_at %>
                      </span>
                    </div>
                  <% end %>
                <% end %>
              </div>
            </div>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
