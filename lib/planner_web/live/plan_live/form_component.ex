defmodule PlannerWeb.PlanLive.FormComponent do
  use PlannerWeb, :live_component

  alias Planner.Plans

  @impl true
  def update(%{plan: plan} = assigns, socket) do
    changeset = Plans.change_plan(plan)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"plan" => plan_params}, socket) do
    changeset =
      socket.assigns.plan
      |> Plans.change_plan(plan_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"plan" => plan_params}, socket) do
    save_plan(socket, socket.assigns.action, plan_params)
  end

  defp save_plan(socket, :edit, plan_params) do
    case Plans.update_plan(socket.assigns.plan, plan_params) do
      {:ok, _plan} ->
        {:noreply,
         socket
         |> put_flash(:info, "Plan updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_plan(socket, :new, plan_params) do
    case Plans.create_plan(plan_params) do
      {:ok, _plan} ->
        {:noreply,
         socket
         |> put_flash(:info, "Plan created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
