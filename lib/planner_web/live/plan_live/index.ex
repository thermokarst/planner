defmodule PlannerWeb.PlanLive.Index do
  use PlannerWeb, :live_view

  alias Planner.Plans
  alias Planner.Plans.Plan

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :plans, list_plans())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Plan")
    |> assign(:plan, Plans.get_plan!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Plan")
    |> assign(:plan, %Plan{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Plans")
    |> assign(:plan, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    plan = Plans.get_plan!(id)
    {:ok, _} = Plans.delete_plan(plan)

    {:noreply, assign(socket, :plans, list_plans())}
  end

  defp list_plans do
    Plans.list_plans()
  end
end
