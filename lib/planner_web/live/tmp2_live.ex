defmodule PlannerWeb.Tmp2Live do
  use Phoenix.LiveView, layout: {PlannerWeb.LayoutView, "live.html"}
  use Phoenix.HTML

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:messages, load_last_5_messages())

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div id="chat-messages">
      <%= for message <- @messages do %>
        <%= live_component @socket, Tmp2Component, id: message.id, message: message %>
      <% end %>
    </div>
    """
  end

  defp load_last_5_messages() do
    [
      %{:id => 0, :username => "a", :text => "aaa"},
      %{:id => 1, :username => "b", :text => "bbb"},
      %{:id => 2, :username => "c", :text => "ccc"},
      %{:id => 3, :username => "d", :text => "ddd"},
      %{:id => 4, :username => "e", :text => "eee"}
    ]
  end
end

defmodule Tmp2Component do
  use Phoenix.LiveComponent

  import PlannerWeb.Util

  def mount(socket) do
    socket =
      socket
      |> assign(:highlighted, false)

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
      <%= if @highlighted do %>
        <p phx-click="toggle-highlight" phx-target="<%= @myself %>" class="has-text-info">
          <span><%= @message[:username] %>:</span> <%= @message[:text] %>
        </p>
      <% else %>
        <p id="<%= @myself %>" phx-click="toggle-highlight" phx-target="<%= @myself %>">
          <span><%= @message[:username] %>:</span> <%= @message[:text] %>
        </p>
      <% end %>
    """
  end

  def handle_event("toggle-highlight", _params, socket) do
    socket =
      socket
      |> assign(:highlighted, !socket.assigns.highlighted)

    {:noreply, socket}
  end
end
