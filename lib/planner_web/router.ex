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

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)
      live_dashboard("/dashboard", metrics: PlannerWeb.Telemetry)
    end
  end

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
    live("/:task_id", TasksLive, :show)
    live("/:task_id/edit", TasksLive, :edit)

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
