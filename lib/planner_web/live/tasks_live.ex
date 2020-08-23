defmodule PlannerWeb.TasksLive do
  use PlannerWeb, :live_view

  alias Planner.Tasks

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:plans, Tasks.list_unfinished_plans())

    {:ok, socket}
  end

  # plan: yes, task: yes
  def handle_params(%{"plan_id" => plan_id, "task_id" => task_id}, _, socket) do
    IO.inspect("plan: yes, task: yes")

    case Tasks.verify_plan_id_from_url(plan_id) do
      true ->
        case Tasks.verify_task_id_from_url(task_id) do
          true ->
            socket =
              socket
              |> assign(:active_task, task_id)
              |> assign(:active_plan, Tasks.get_plan!(plan_id))
              |> assign(:tasks, Tasks.list_unfinished_tasks_by_plan_id(plan_id))
              |> assign(:route_show_task, &Routes.tasks_path(&1, :show_task, plan_id, &2))
              |> assign(:route_edit_task, &Routes.tasks_path(&1, :edit_task, plan_id, &2))
              |> assign(:route_index_tasks, &Routes.tasks_path(&1, :show_plan, plan_id))

            {:noreply, socket}

          _ ->
            {:noreply, push_patch(socket, to: Routes.tasks_path(socket, :index))}
        end

      _ ->
        {:noreply, push_patch(socket, to: Routes.tasks_path(socket, :index))}
    end
  end

  # plan: no, task: yes
  def handle_params(%{"task_id" => task_id}, _, socket) do
    IO.inspect("plan: no, task: yes")

    case Tasks.verify_task_id_from_url(task_id) do
      true ->
        socket =
          socket
          |> assign(:active_task, task_id)
          |> assign(:active_plan, nil)
          |> assign(:tasks, Tasks.list_unfinished_tasks())
          |> assign(:route_show_task, &Routes.tasks_path(&1, :show_task, &2))
          |> assign(:route_edit_task, &Routes.tasks_path(&1, :edit_task, &2))
          |> assign(:route_index_tasks, &Routes.tasks_path(&1, :index))

        {:noreply, assign(socket, :active_task, task_id)}

      _ ->
        {:noreply, push_patch(socket, to: Routes.tasks_path(socket, :index))}
    end
  end

  # plan: yes, task: no
  def handle_params(%{"plan_id" => plan_id}, _, socket) do
    IO.inspect("plan: yes, task: no")

    case Tasks.verify_plan_id_from_url(plan_id) do
      true ->
        socket =
          socket
          |> assign(:active_task, nil)
          |> assign(:active_plan, Tasks.get_plan!(plan_id))
          |> assign(:tasks, Tasks.list_unfinished_tasks_by_plan_id(plan_id))
          |> assign(:route_show_task, &Routes.tasks_path(&1, :show_task, plan_id, &2))
          |> assign(:route_edit_task, &Routes.tasks_path(&1, :edit_task, plan_id, &2))
          |> assign(:route_index_tasks, &Routes.tasks_path(&1, :show_plan, plan_id))

        {:noreply, socket}

      _ ->
        {:noreply, push_patch(socket, to: Routes.tasks_path(socket, :index))}
    end
  end

  # plan: no, task: no
  def handle_params(_, _, socket) do
    IO.inspect("plan: no, task: no")

    socket =
      socket
      |> assign(:active_task, nil)
      |> assign(:active_plan, nil)
      |> assign(:tasks, Tasks.list_unfinished_tasks())
      |> assign(:route_show_task, &Routes.tasks_path(&1, :show_task, &2))
      |> assign(:route_edit_task, &Routes.tasks_path(&1, :edit_task, &2))
      |> assign(:route_index_tasks, &Routes.tasks_path(&1, :index))

    {:noreply, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="columns">
      <div class="column is-one-quarter">
        <h4 class="title is-4">plans</h4>
          <nav class="panel">
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
      <div class="column" phx-window-keydown="keydown" phx-key="Escape">
        <%= case @active_plan do %>
          <%= nil -> %>
            <h4 class="title is-4">all unfinished</h4>
         <% _ -> %>
            <h4 class="title is-4">
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

  def handle_event("keydown", _params, socket) do
    case socket.assigns.live_action do
      :index -> {:noreply, socket}
      _ -> {:noreply, push_patch(socket, to: Routes.tasks_path(socket, :index))}
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

        {:noreply, push_patch(socket, to: Routes.tasks_path(socket, :show, task.id))}

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
    {:noreply, refresh_tasks_and_flash_msg(socket, "task \"#{task.value}\" deleted")}
  end

  def handle_event("new-task", %{"task" => task_params}, socket) do
    add_new_task(task_params, socket.assigns.active_plan, socket)
  end

  def handle_event("add-task-to-plan", %{"task-id" => task_id, "plan-id" => plan_id}, socket) do
    {_, plan_detail} = Tasks.create_plan_detail(%{"task_id" => task_id, "plan_id" => plan_id})
    # TODO
    IO.inspect(plan_detail)
    {:noreply, socket}
  end

  def handle_event("delete-task-from-plan", %{"task-id" => task_id, "plan-id" => plan_id}, socket) do
    plan_detail = Tasks.get_plan_detail_by!(task_id: task_id, plan_id: plan_id)
    {_, plan_detail} = Tasks.delete_plan_detail(plan_detail)
    # TODO
    {:noreply, socket}
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
end
