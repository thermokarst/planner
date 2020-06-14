defmodule Planning.LandingLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    socket = assign(socket, :points, [])
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>LiveView is awesome!</h1>
    <svg phx-mousedown="clicked" width="500" height="500" style="border: 1px solid blue">
      <%= for {x, y} <- @points do %>
        <circle cx="<%= x %>" cy="<%= y %>" r="3" fill="purple" />
      <% end %>
    </svg>
    """
  end

  def handle_event("clicked", %{"offsetX" => x, "offsetY" => y} = _data, socket) do
    socket = update(socket, :points, fn points -> [{x, y} | points] end)
    {:noreply, socket}
  end
end
