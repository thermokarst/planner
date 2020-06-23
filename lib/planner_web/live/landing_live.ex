defmodule PlannerWeb.LandingLive do
  use Phoenix.LiveView, layout: {PlannerWeb.LayoutView, "live.html"}
  use Phoenix.HTML

  import PlannerWeb.ErrorHelpers

  alias Planner.Tasks
  alias Planner.Tasks.Task

  def mount(_params, _session, socket) do
    socket =
      socket
      |> clear_flash(:info)
      |> assign(:new_task_changeset, Tasks.change_task(%Task{}))

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="box">
      <%= f = form_for(@new_task_changeset, "#", [phx_submit: :save_new_task]) %>
        <div class="field">
          <div class="control">
            <%= text_input f, :value, placeholder: "add new task", class: "input", autocomplete: "off" %>
          </div>
          <%= error_tag f, :value %>
        </div>
      </form>
    </div>
    """
  end

  def handle_event("save_new_task", %{"task" => task_params}, socket) do
    case Tasks.add_task(task_params) do
      {:ok, task} ->
        {:noreply,
         socket
         |> clear_flash(:info)
         |> put_flash(:info, "task '" <> task.value <> "' created")
         |> assign(:new_task_changeset, Tasks.change_task(%Task{}))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(new_task_changeset: changeset)}
    end
  end
end
