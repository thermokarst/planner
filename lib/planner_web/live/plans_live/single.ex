defmodule PlannerWeb.PlansLive.Single do
  use PlannerWeb, :live_view

  alias Planner.Plans
  alias Planner.Tasks

  alias Phoenix.LiveView.Socket

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"plan_id" => plan_id, "id" => task_id}, _, socket) do
    socket =
      case Plans.verify_plan_id_from_url(plan_id) do
        true -> assign(socket, :plan_id, plan_id) |> fetch_plan()
        false -> socket
      end

    case Tasks.verify_task_id_from_url(task_id) do
      true -> {:noreply, assign(socket, :active_task, task_id)}
    end
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
          action: %{show_task: :show, edit_task: :edit}[@live_action],
          tasks: @tasks,
          active_task: @active_task,
          route_show_task: &(Routes.plans_single_path(&1, :show_task, @plan, &2)),
          route_edit_task: &(Routes.plans_single_path(&1, :edit_task, @plan, &2)),
          route_index_tasks: &(Routes.plans_single_path(&1, :show, @plan))
        )%>
      </div>

    </div>
    """
  end

  def handle_event("keydown", _params, socket) do
    case socket.assigns.live_action do
      :index ->
        {:noreply, socket}

      _ ->
        {:noreply,
         push_patch(socket, to: Routes.plans_single_path(socket, :show, socket.assigns.plan))}
    end
  end
end
