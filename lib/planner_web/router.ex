defmodule PlannerWeb.Router do
  use PlannerWeb, :router

  import PlannerWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {PlannerWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  # Other scopes may use custom stacks.
  # scope "/api", PlannerWeb do
  #   pipe_through :api
  # end

  scope "/", PlannerWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    get("/users/login", UserSessionController, :new)
    post("/users/login", UserSessionController, :create)
    get("/users/reset_password", UserResetPasswordController, :new)
    post("/users/reset_password", UserResetPasswordController, :create)
    get("/users/reset_password/:token", UserResetPasswordController, :edit)
    put("/users/reset_password/:token", UserResetPasswordController, :update)
  end

  scope "/", PlannerWeb do
    pipe_through([:browser, :require_authenticated_user])

    live("/", TasksLive, :index)
    live("/tasks", TasksLive, :index)
    live("/tasks/:task_id", TasksLive, :show_task)
    live("/tasks/:task_id/edit", TasksLive, :edit_task)
    live("/plans/:plan_id/tasks", TasksLive, :show_plan)
    live("/plans/:plan_id/tasks/:task_id", TasksLive, :show_task)
    live("/plans/:plan_id/tasks/:task_id/edit", TasksLive, :edit_task)

    get("/users/settings", UserSettingsController, :edit)
    put("/users/settings/update_password", UserSettingsController, :update_password)
    put("/users/settings/update_email", UserSettingsController, :update_email)
    get("/users/settings/confirm_email/:token", UserSettingsController, :confirm_email)
  end

  scope "/", PlannerWeb do
    pipe_through([:browser])

    delete("/users/logout", UserSessionController, :delete)
  end
end
