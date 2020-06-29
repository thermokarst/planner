defmodule PlannerWeb.TaskLive.Show do
  use Phoenix.LiveView, layout: {PlannerWeb.LayoutView, "live.html"}

  alias Planner.Tasks
  alias PlannerWeb.TaskLive.TaskComponent
  alias PlannerWeb.Router.Helpers, as: Routes

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    task = Tasks.get_task!(id)

    socket =
      socket
      |> assign(:task, task)

    {:noreply, socket}
  end

  def render(assigns) do
    ~L"""
    <%= live_component(@socket, TaskComponent, task: @task) %>
    """
  end

  def handle_event("task-details", %{"id" => id}, socket) do
    # TODO: redirect to editor
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, PlannerWeb.TaskLive.Show, id))}
  end
end
