defmodule PlannerWeb.LandingLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    socket = assign(socket, :points, [])
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
     <h1>Planner</h1>
    """
  end

  # def handle_event("clicked", %{"offsetX" => x, "offsetY" => y} = _data, socket) do
  #   socket = update(socket, :points, fn points -> [{x, y} | points] end)
  #   {:noreply, socket}
  # end
end
