defmodule TasksComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="content">
      <ul class="tasks">
        <%= for task <- @tasks do %>
          <%= live_component(@socket,
            TaskComponent,
            id: task.id,
            task: task,
            show_details: @active_task == task.id,
            route_func_2: @route_func_2,
            route_func_3: @route_func_3
          )%>
        <% end %>
      </ul>
    </div>
    """
  end
end

defmodule TaskComponent do
  use Phoenix.LiveComponent

  import PlannerWeb.Util

  def render(assigns) do
    ~L"""
    <li>
      <div>
        <div class="is-pulled-left">
          <button type="button" role="checkbox" class="doit"></button>
        </div>
        <div class="ml-5-5">
          <%= if(@show_details) do %>
            <%= live_component(@socket,
              TaskDetailsComponent,
              task: @task,
              route_func_2: @route_func_2
            )%>
          <% else %>
            <%= live_patch(to: @route_func_3.(@socket, :show, @task.id), style: "display: block;") do %>
              <div class="value ">
                <%= md_to_html(@task.value) %>
              </div>
            <% end %>
            <%= if not is_nil(@task.due_at) do %>
              <div class="tags mb-0">
                <span class="tag">
                  due: <%= @task.due_at %>
                </span>
              </div>
            <% end %>
          <% end %>
        </div>
      </div>
    </li>
    """
  end
end

defmodule TaskDetailsComponent do
  use Phoenix.LiveComponent

  import PlannerWeb.Util

  def render(assigns) do
    ~L"""
    <div class="box">
      <%= live_patch("", to: @route_func_2.(@socket, :index), class: "delete is-pulled-right") %>
      <%= if not is_nil(@task.due_at) or is_nil(@task.filed_at) do %>
        <div class="tags">
          <%= if not is_nil(@task.due_at) do %><span class="tag is-warning">due: <%= @task.due_at %></span><% end %>
          <%= if is_nil(@task.filed_at) do %><span class="tag is-danger">unfiled</span><% end %>
        </div>
      <% end %>

      <div class="mb-5">
        <%= md_to_html @task.value %>
      </div>

      <div class="tags">
        <span class="tag is-light">updated: <%= @task.updated_at %></span>
        <span class="tag is-light">created: <%= @task.inserted_at %></span>
      </div>
    </div>
    """
  end
end
