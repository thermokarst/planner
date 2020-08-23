defmodule PlannerWeb.TasksLive do
  use PlannerWeb, :live_view

  alias Planner.Tasks
  alias Planner.Tasks.Plan

  def mount(_params, _session, socket) do
    socket =
    socket
    |> assign(:plans, Tasks.list_unfinished_plans())
    |> assign(:plan_changeset, Tasks.change_plan(%Plan{}))
   {:ok, socket}
  end

  # plan: yes, task: yes
  def handle_params(%{"plan_id" => plan_id, "task_id" => task_id}, _, socket) do
    case Tasks.verify_plan_id_from_url(plan_id) and Tasks.verify_task_id_from_url(task_id) do
      true ->
        socket =
          socket
          |> assign(:active_task, task_id)
          |> assign(:active_plan, Tasks.get_plan!(plan_id))
          |> assign(:tasks, Tasks.list_unfinished_tasks_by_plan_id(plan_id))
          |> add_plan_routes(plan_id)

        {:noreply, socket}

      _ ->
        {:noreply, push_patch(socket, to: Routes.tasks_path(socket, :index))}
    end
  end

  # plan: no, task: yes
  def handle_params(%{"task_id" => task_id}, _, socket) do
    case Tasks.verify_task_id_from_url(task_id) do
      true ->
        socket =
          socket
          |> assign(:active_task, task_id)
          |> assign(:active_plan, nil)
          |> assign(:tasks, Tasks.list_unfinished_tasks())
          |> add_task_routes()

        {:noreply, assign(socket, :active_task, task_id)}

      _ ->
        {:noreply, push_patch(socket, to: Routes.tasks_path(socket, :index))}
    end
  end

  # plan: yes, task: no
  def handle_params(%{"plan_id" => plan_id}, _, socket) do
    case Tasks.verify_plan_id_from_url(plan_id) do
      true ->
        socket =
          socket
          |> assign(:active_task, nil)
          |> assign(:active_plan, Tasks.get_plan!(plan_id))
          |> assign(:tasks, Tasks.list_unfinished_tasks_by_plan_id(plan_id))
          |> add_plan_routes(plan_id)

        {:noreply, socket}

      _ ->
        {:noreply, push_patch(socket, to: Routes.tasks_path(socket, :index))}
    end
  end

  # plan: no, task: no
  def handle_params(_, _, socket) do
    socket =
      socket
      |> assign(:active_task, nil)
      |> assign(:active_plan, nil)
      |> assign(:tasks, Tasks.list_unfinished_tasks())
      |> add_task_routes()

    {:noreply, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="columns" phx-window-keydown="keydown" phx-key="Escape">
      <div class="column is-one-quarter">
        <h4 class="title is-4">plans</h4>
          <nav class="panel">
            <%= f = form_for(@plan_changeset, "#", phx_submit: "new-plan", class: "panel-block") %>
              <div class="control">
                <%= text_input(f,
                  :name,
                  placeholder: "add new plan",
                  class: "input", autocomplete: "off"
                )%>
                <%= error_tag(f, :name) %>
              </div>
            </form>
            <%= live_patch("all unfinished tasks", to: Routes.tasks_path(@socket, :index), class: "panel-block") %>
            <%= for plan <- @plans do %>
              <%= live_patch(
                plan.name,
                to: Routes.tasks_path(@socket, :show_plan, plan.id),
                class: "panel-block",
                phx_hook: "AddDropper",
                data_plan_id: plan.id
              ) %>
            <% end %>
          </nav>
      </div>
      <div class="column">
        <%= case @active_plan do %>
          <%= nil -> %>
            <h4 class="title is-4">all unfinished tasks</h4>
         <% _ -> %>
            <h4 class="title is-4">
              <button
                type="button"
                role="checkbox"
                class="doit"
                phx-click="finish-plan"
                phx-value-plan-id="<%= @active_plan.id %>">
              </button>
              &nbsp;
              <%= @active_plan.name %>
            </h4>
          <% end %>
          <%= live_component(@socket,
            TasksComponent,
            id: :tasks,
            live_action: @live_action,
            tasks: @tasks,
            active_plan: @active_plan,
            active_task: @active_task,
            route_show_task: @route_show_task,
            route_edit_task: @route_edit_task,
            route_index_tasks: @route_index_tasks
          )%>
      </div>
    </div>
    """
  end

  def handle_event("new-plan", %{"plan" => plan_params}, socket) do
    case Tasks.create_plan(plan_params) do
      {:ok, _plan} ->
        {:noreply, assign(socket, plans: Tasks.list_unfinished_plans())}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, plan_changeset: changeset)}
    end
  end

  def handle_event("finish-plan", %{"plan-id" => plan_id}, socket) do
    {_, plan} = Tasks.finish_plan_by_id!(plan_id)
    socket = put_flash(socket, :info, "finished plan \"#{plan.name}\"")
    socket = assign(socket, plans: Tasks.list_unfinished_plans())
    {:noreply, push_patch(socket, to: Routes.tasks_path(socket, :index))}
  end

  def handle_event("keydown", _params, socket) do
    route = get_index_route(socket)

    case socket.assigns.live_action do
      :index -> {:noreply, socket}
      _ -> {:noreply, push_patch(socket, to: route)}
    end
  end

  def handle_event("save-task", %{"task" => task_params}, socket) do
    task = Tasks.get_task!(task_params["id"])

    case Tasks.update_task(task, task_params) do
      {:ok, task} ->
        # I suspect splicing in the updated task isn't much faster than just refreshing the whole list
        socket =
          socket
          |> refresh_tasks_and_flash_msg("task \"#{task.value}\" updated")

        route = get_index_route(socket)

        {:noreply, push_patch(socket, to: route)}

      {:error, changeset} ->
        send_update(TaskEditComponent, id: "task_edit:#{task.id}", changeset: changeset)
        {:noreply, socket}
    end
  end

  def handle_event("finish-task", %{"task-id" => task_id}, socket) do
    {_, task} = Tasks.finish_task_by_id!(task_id)
    {:noreply, refresh_tasks_and_flash_msg(socket, "task \"#{task.value}\" completed")}
  end

  def handle_event("delete-task", %{"task-id" => task_id}, socket) do
    {_, task} = Tasks.delete_task_by_id!(task_id)
    socket = refresh_tasks_and_flash_msg(socket, "task \"#{task.value}\" deleted")
    route = get_index_route(socket)

    {:noreply, push_patch(socket, to: route)}
  end

  def handle_event("new-task", %{"task" => task_params}, socket) do
    add_new_task(task_params, socket.assigns.active_plan, socket)
  end

  def handle_event("add-task-to-plan", plan_detail_params, socket) do
    {_, pd} = Tasks.create_plan_detail(plan_detail_params)

    {:noreply,
     refresh_tasks_and_flash_msg(socket, "task #{pd.task_id} added to plan #{pd.plan_id}")}
  end

  def handle_event("delete-task-from-plan", %{"task_id" => task_id, "plan_id" => plan_id}, socket) do
    plan_detail = Tasks.get_plan_detail_by!(task_id: task_id, plan_id: plan_id)
    {_, pd} = Tasks.delete_plan_detail(plan_detail)

    {:noreply,
     refresh_tasks_and_flash_msg(socket, "task #{pd.task_id} removed from plan #{pd.plan_id}")}
  end

  defp refresh_tasks_and_flash_msg(socket, msg) do
    tasks =
      case socket.assigns.active_plan do
        nil -> Tasks.list_unfinished_tasks()
        plan -> Tasks.list_unfinished_tasks_by_plan_id(plan.id)
      end

    socket
    |> assign(:tasks, tasks)
    |> put_flash(:info, msg)
  end

  defp add_new_task(task_params, active_plan = nil, socket) do
    case Tasks.create_task(task_params) do
      {:ok, task} ->
        {:noreply, refresh_tasks_and_flash_msg(socket, "task \"#{task.value}\" created")}

      {:error, %Ecto.Changeset{} = changeset} ->
        send_update(TasksComponent, id: :tasks, changeset: changeset)
        {:noreply, socket}
    end
  end

  defp add_new_task(task_params, active_plan, socket) do
    case Tasks.create_task_and_add_to_plan(task_params, active_plan) do
      {:ok, %{plan_detail: _, task: task}} ->
        {:noreply, refresh_tasks_and_flash_msg(socket, "task \"#{task.value}\" created")}

      {:error, :task, %Ecto.Changeset{} = changeset, _} ->
        send_update(TasksComponent, id: :tasks, changeset: changeset)
        {:noreply, socket}
    end
  end

  defp add_plan_routes(socket, plan_id) do
    socket
    |> assign(:route_show_task, &Routes.tasks_path(&1, :show_task, plan_id, &2))
    |> assign(:route_edit_task, &Routes.tasks_path(&1, :edit_task, plan_id, &2))
    |> assign(:route_index_tasks, &Routes.tasks_path(&1, :show_plan, plan_id))
  end

  defp add_task_routes(socket) do
    socket
    |> assign(:route_show_task, &Routes.tasks_path(&1, :show_task, &2))
    |> assign(:route_edit_task, &Routes.tasks_path(&1, :edit_task, &2))
    |> assign(:route_index_tasks, &Routes.tasks_path(&1, :index))
  end

  defp get_index_route(socket) do
    case socket.assigns.active_plan do
      nil -> Routes.tasks_path(socket, :index)
      plan -> Routes.tasks_path(socket, :show_plan, plan.id)
    end
  end
end
