defmodule PlannerWeb.PlansLive do
  use PlannerWeb, :live_view

  alias Planner.Plans
  alias Planner.Plans.Plan

  def mount(_params, _session, socket) do
    {:ok, refresh_data(socket)}
  end

  def handle_params(%{"id" => plan_id}, _, socket) do
    {:noreply, socket}
  end

  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="content">
      <%= f = form_for(@new_plan_changeset, "#", [phx_submit: "new-plan"]) %>
        <div class="field">
          <div class="control">
            <%= text_input(f,
              :name,
              placeholder: "add new plan",
              class: "input", autocomplete: "off"
            )%>
          </div>
          <%= error_tag(f, :value) %>
        </div>
      </form>

      <ul>
        <%= for plan <- @plans do %>
          <li>
            <%= live_patch(to: Routes.plans_path(@socket, :show, plan)) do %>
              <%= plan.name %>
            <% end %>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  def handle_event("new-plan", %{"plan" => plan_params}, socket) do
    case Plans.create_plan(plan_params) do
      {:ok, plan} ->
        socket = refresh_data(socket)

        {:noreply,
         socket
         |> clear_flash(:info)
         |> put_flash(:info, "plan '#{plan.name}' created")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(new_plan_changeset: changeset)}
    end
  end

  defp refresh_data(socket) do
    socket
    |> assign(:plans, Plans.list_plans())
    |> assign(:new_plan_changeset, Plans.change_plan(%Plan{}))
  end
end
