defmodule TasksComponent do
  use PlannerWeb, :live_component

  alias Planner.Tasks
  alias Planner.Tasks.Task

  def update(%{:changeset => changeset, :id => _id}, socket) do
    {:ok, assign(socket, :changeset, changeset)}
  end

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:changeset, Tasks.change_task(%Task{}))

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="content">
      <%= f = form_for(@changeset, "#", [phx_submit: "new-task"]) %>
        <div id="adder" class="field">
          <div class="control">
            <%= text_input(f,
              :value,
              placeholder: "add new task",
              class: "input", autocomplete: "off"
            )%>
          </div>
          <%= error_tag(f, :value) %>
        </div>
      </form>

      <%= if(!is_nil(@active_plan)) do %>
        <div
          id="deleter"
          phx-hook="DeleteDropper"
          data-drop="<%= @active_plan.id %>"
          class="has-background-danger"
          style="height: 38px; width: 100%"
          hidden=true
        ></div>
      <% end %>

      <ul class="tasks">
        <%= for task <- @tasks do %>
          <%= live_component(@socket,
            TaskComponent,
            id: "task:#{task.id}",
            task: task,
            plans: @plans,
            live_action: @live_action,
            is_active: @active_task == task.id,
            route_show_task: @route_show_task,
            route_edit_task: @route_edit_task,
            route_index_tasks: @route_index_tasks
          )%>
        <% end %>
      </ul>
    </div>
    """
  end
end

defmodule TaskComponent do
  use Phoenix.LiveComponent

  alias Planner.Tasks.Task

  import PlannerWeb.Util

  def render(assigns) do
    ~L"""
    <li>
      <div>
        <div class="is-pulled-left">
          <%= case @task.finished_at do %>
            <% nil -> %>
              <button
                type="button"
                role="checkbox"
                class="doit"
                phx-click="finish-task"
                phx-value-task-id="<%= @task.id %>">
              </button>
            <% _ -> %>
              <span
                class="pointer"
                phx-click="unfinish-task" phx-value-task-id="<%= @task.id %>">
                !
              </span>
            <% end %>
        </div>
        <div class="ml-5-5">
          <%= if(@is_active) do %>
            <%= case @live_action do %>
              <% :show_task -> %>
                <%= live_component(@socket,
                  TaskDetailsComponent,
                  id: "task_details:#{@task.id}",
                  task: @task,
                  route_index_tasks: @route_index_tasks,
                  route_edit_task: @route_edit_task
                )%>
              <% :edit_task -> %>
                 <%= live_component(@socket,
                  TaskEditComponent,
                  id: "task_edit:#{@task.id}",
                  task: @task,
                  plans: @plans
                )%>
              <% end %>
          <% else %>
            <%= live_patch(to: @route_show_task.(@socket, @task.id),
              style: "display: block;"
            ) do %>
              <div class="value">
                <%= md_to_html(Task.preview(@task)) %>
              </div>
            <% end %>
            <%= if(not is_nil(@task.due_at)) do %>
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
  use PlannerWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="box" id="task-details-<%= @task.id %>" draggable="true" phx-hook="Dragger" data-task-id="<%= @task.id %>">
      <%= live_patch("",
        to: @route_index_tasks.(@socket),
        class: "delete is-pulled-right"
      ) %>
      <%= if(not is_nil(@task.due_at) or not is_nil(@task.finished_at) or length(@task.plans) == 0) do %>
        <div class="tags">
          <%= if(not is_nil(@task.due_at)) do %>
            <span class="tag is-warning">
              due: <%= @task.due_at %>
            </span><% end %>
          <%= if(not is_nil(@task.finished_at)) do %>
            <span class="tag is-success">
              completed
            </span><% end %>
          <%= if(length(@task.plans) == 0) do %>
            <span class="tag is-danger">
              unfiled
            </span>
          <% end %>
        </div>
      <% end %>

      <div class="mb-5">
        <%= md_to_html(@task.value) %>
      </div>

      <div class="tags">
        <span class="tag is-light">updated: <%= @task.updated_at %></span>
        <span class="tag is-light">created: <%= @task.inserted_at %></span>
      </div>

      <div class="buttons has-addons">
        <%= live_patch("edit",
          to: @route_edit_task.(@socket, @task.id),
          class: "button is-dark is-small"
        ) %>
      </div>
    </div>
    """
  end
end

defmodule TaskEditComponent do
  use PlannerWeb, :live_component

  alias Planner.Tasks

  def update(%{:changeset => changeset, :id => _id}, socket) do
    {:ok, assign(socket, :changeset, changeset)}
  end

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:changeset, Tasks.change_task(assigns.task))

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="box">
      <%= f = form_for(@changeset, "#", [phx_submit: "save-task"]) %>
       <%= hidden_input(f, :id) %>

        <div class="field">
          <div class="control">
            <%= textarea(f,
              :value,
              required: true,
              class: "textarea",
              placeholder: "task",
              autocomplete: "off"
            ) %>
          </div>
          <%= error_tag(f, :value) %>
        </div>

        <div class="field">
          <%= label(f, :due_at, class: "label") do %>
            due (YYYY-MM-DD HH:MM)
          <% end %>
          <div class="control">
            <%= text_input(f,
              :due_at,
              class: "input",
              placeholder: "YYYY-MM-DD HH:MM",
              autocomplete: "off"
            ) %>
          </div>
          <%= error_tag(f, :due_at) %>
        </div>

        <div class="field">
          <label class="label">plans</label>
          <div class="control">
            <div class="select is-multiple is-dark">
            <%= multiple_select(f,
              :plans,
              Enum.map(@plans, &({&1.name, &1.id})),
              selected: Enum.map(@task.plans, &(&1.id))
            ) %>
            </div>
          </div>
        </div>

        <div class="field">
          <div class="control">
            <%= submit("save", class: "button is-dark is-small") %>
          </div>
        </div>
      </form>
    </div>
    """
  end
end
