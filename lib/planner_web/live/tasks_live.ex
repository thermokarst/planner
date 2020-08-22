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
      _ -> {:noreply, push_patch(socket, to: Routes.tasks_path(socket, :index))}
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
            <%= live_patch("all unfinished", to: Routes.tasks_path(@socket, :index), class: "panel-block") %>
            <%= for plan <- @plans do %>
              <%= live_patch(
                plan.name,
                to: Routes.tasks_path(@socket, :show_plan, plan.id),
                class: "panel-block",
                phx_hook: "Dropper",
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
    case Tasks.create_task(task_params) do
      {:ok, task} ->
        socket =
          socket
          |> refresh_tasks_and_flash_msg("task \"#{task.value}\" created")

        {:noreply, push_patch(socket, to: Routes.tasks_path(socket, :show, task.id))}

      {:error, %Ecto.Changeset{} = changeset} ->
        send_update(TasksComponent, id: :all_unfinished_tasks, changeset: changeset)
        {:noreply, socket}
    end
  end

  def handle_event("add-task-to-plan", %{"task-id" => task_id, "plan-id" => plan_id}, socket) do
    {_, plan_detail} = Tasks.create_plan_detail(%{"task_id" => task_id, "plan_id" => plan_id})
    {:noreply, socket}
  end

  defp refresh_tasks_and_flash_msg(socket, msg) do
    socket
    |> assign(:tasks, Tasks.list_unfinished_tasks())
    |> put_flash(:info, msg)
  end
end
