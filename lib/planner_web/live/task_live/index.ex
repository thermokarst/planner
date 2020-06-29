defmodule PlannerWeb.TaskLive.Index do
  use Phoenix.LiveView, layout: {PlannerWeb.LayoutView, "live.html"}

  alias PlannerWeb.Router.Helpers, as: Routes
  alias Planner.Tasks
  alias PlannerWeb.TaskLive.TaskComponent

  def mount(_params, _session, socket) do
    tasks = Tasks.list_unfinished_tasks()

    socket =
      socket
      |> assign(:tasks, tasks)

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <a href="<%= Routes.task_path(@socket, :new) %>" class="button is-dark">new</a>

    <div class="content">
      <ul class="tasks">
        <%= for task <- @tasks do %>
          <li>
            <%= live_component(@socket, TaskComponent, task: task) %>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  def handle_event("task-details", %{"id" => id}, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, PlannerWeb.TaskLive.Show, id))}
  end
end
