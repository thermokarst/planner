defmodule PlannerWeb.LandingLive do
  use Phoenix.LiveView, layout: {PlannerWeb.LayoutView, "live.html"}
  use Phoenix.HTML

  import PlannerWeb.ErrorHelpers

  alias Planner.Tasks
  alias Planner.Tasks.Task

  def mount(_params, _session, socket) do
    socket =
      socket
      # |> put_flash(:info, "hello world")
      |> assign(:new_task_changeset, Tasks.change_task(%Task{}))
      |> assign(:tasks, Tasks.list_unfinished_tasks())

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <%= f = form_for(@new_task_changeset, "#", [phx_submit: :save_new_task]) %>
      <%= label f, :value, "New Task" %>
      <%= text_input f, :value %>
      <%= error_tag f, :value %>

      <%= submit "Create" %>
    </form>

    <hr>

    <table>
      <thead>
        <tr>
          <th colspan="3">tasks</th>
        </tr>
      </thead>
      <tbody>
        <%= for task <- @tasks do %>
          <tr>
            <td><%= task.value %></td>
            <td><button phx-click="delete_task" phx-value-task_id="<%= task.id %>">delete</button></td>
            <td><button phx-click="finish_task" phx-value-task_id="<%= task.id %>">done</button></td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  def handle_event("save_new_task", %{"task" => task_params}, socket) do
    case Tasks.add_task(task_params) do
      {:ok, task} ->
        {:noreply,
         socket
         |> put_flash(:info, "task created")
         |> assign(:tasks, Tasks.list_unfinished_tasks())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(new_task_changeset: changeset)}
    end
  end

  def handle_event("delete_task", %{"task_id" => task_id}, socket) do
    Tasks.delete_task_by_id!(task_id)

    {:noreply,
     socket
     |> put_flash(:info, "task deleted")
     |> assign(:tasks, Tasks.list_unfinished_tasks())}
  end

  def handle_event("finish_task", %{"task_id" => task_id}, socket) do
    Tasks.finish_task_by_id!(task_id)

    {:noreply,
     socket
     |> put_flash(:info, "task completed")
     |> assign(:tasks, Tasks.list_unfinished_tasks())}
  end
end
