defmodule PlannerWeb.PlansLive do
  use PlannerWeb, :live_view

  alias Planner.Plans

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:plans, Plans.list_plans())

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <ul>
      <%= for plan <- @plans do %>
        <li><%= plan.id %></li>
      <% end %>
    </ul>
    """
  end
end
