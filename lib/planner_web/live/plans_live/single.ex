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
  end

  def render(assigns) do
    ~L"""
    <div class="content">
      <%= @plan.name %>
    </div>
    """
  end
end
