defmodule PlannerWeb.PageController do
  use PlannerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
