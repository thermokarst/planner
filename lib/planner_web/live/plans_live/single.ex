defmodule PlannerWeb.PlansLive.Single do
  use PlannerWeb, :live_view

  alias Planner.Plans

  alias Phoenix.LiveView.Socket

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"plan_id" => plan_id}, _, socket) do
    case Plans.verify_plan_id_from_url(plan_id) do
      true -> {:noreply, assign(socket, :plan_id, plan_id) |> fetch_plan()}
    end
  end

  defp fetch_plan(%Socket{assigns: %{plan_id: plan_id}} = socket) do
    socket
    |> assign(plan: Plans.get_plan!(plan_id))
    |> assign(tasks: Plans.get_tasks(plan_id))
    |> assign(active_task: nil)
  end

  def render(assigns) do
    ~L"""
    <div class="content">
      <%= @plan.name %>

      <br>
      <br>

      <div phx-window-keydown="keydown" phx-key="Escape">
        <%= live_component(@socket,
          TasksComponent,
          id: :all_unfinished_tasks,
          live_action: @live_action,
          tasks: @tasks,
          active_task: @active_task,
          route_func_2: &Routes.tasks_path/2,
          route_func_3: &Routes.tasks_path/3
        )%>
      </div>

    </div>
    """
  end
end
