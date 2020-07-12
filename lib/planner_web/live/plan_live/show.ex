defmodule PlannerWeb.PlanLive.Show do
  use PlannerWeb, :live_view

  alias Planner.Plans

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:plan, Plans.get_plan!(id))}
  end

  defp page_title(:show), do: "Show Plan"
  defp page_title(:edit), do: "Edit Plan"
end
