defmodule PlannerWeb.TaskLive.TaskComponent do
  use Phoenix.LiveComponent
  alias PlannerWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~L"""
    <div>
      <div class="is-pulled-left">
        <button type="button" role="checkbox" class="doit"></button>
      </div>
      <div class="ml-5-5">
        <div class="value" phx-click="task-details" phx-value-id="<%= @task.id %>">
          <%= @task.value %>
        </div>
        <%= if not is_nil(@task.due_at) do %>
          <div class="tags mb-0">
            <span class="tag">
              due: <%= @task.due_at %>
            </span>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
