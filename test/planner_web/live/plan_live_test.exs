defmodule PlannerWeb.PlanLiveTest do
  use PlannerWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Planner.Plans

  @create_attrs %{description: "some description", done: true, end: ~N[2010-04-17 14:00:00], id: "some id", name: "some name", start: ~N[2010-04-17 14:00:00]}
  @update_attrs %{description: "some updated description", done: false, end: ~N[2011-05-18 15:01:01], id: "some updated id", name: "some updated name", start: ~N[2011-05-18 15:01:01]}
  @invalid_attrs %{description: nil, done: nil, end: nil, id: nil, name: nil, start: nil}

  defp fixture(:plan) do
    {:ok, plan} = Plans.create_plan(@create_attrs)
    plan
  end

  defp create_plan(_) do
    plan = fixture(:plan)
    %{plan: plan}
  end

  describe "Index" do
    setup [:create_plan]

    test "lists all plans", %{conn: conn, plan: plan} do
      {:ok, _index_live, html} = live(conn, Routes.plan_index_path(conn, :index))

      assert html =~ "Listing Plans"
      assert html =~ plan.description
    end

    test "saves new plan", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.plan_index_path(conn, :index))

      assert index_live |> element("a", "New Plan") |> render_click() =~
               "New Plan"

      assert_patch(index_live, Routes.plan_index_path(conn, :new))

      assert index_live
             |> form("#plan-form", plan: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#plan-form", plan: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.plan_index_path(conn, :index))

      assert html =~ "Plan created successfully"
      assert html =~ "some description"
    end

    test "updates plan in listing", %{conn: conn, plan: plan} do
      {:ok, index_live, _html} = live(conn, Routes.plan_index_path(conn, :index))

      assert index_live |> element("#plan-#{plan.id} a", "Edit") |> render_click() =~
               "Edit Plan"

      assert_patch(index_live, Routes.plan_index_path(conn, :edit, plan))

      assert index_live
             |> form("#plan-form", plan: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#plan-form", plan: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.plan_index_path(conn, :index))

      assert html =~ "Plan updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes plan in listing", %{conn: conn, plan: plan} do
      {:ok, index_live, _html} = live(conn, Routes.plan_index_path(conn, :index))

      assert index_live |> element("#plan-#{plan.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#plan-#{plan.id}")
    end
  end

  describe "Show" do
    setup [:create_plan]

    test "displays plan", %{conn: conn, plan: plan} do
      {:ok, _show_live, html} = live(conn, Routes.plan_show_path(conn, :show, plan))

      assert html =~ "Show Plan"
      assert html =~ plan.description
    end

    test "updates plan within modal", %{conn: conn, plan: plan} do
      {:ok, show_live, _html} = live(conn, Routes.plan_show_path(conn, :show, plan))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Plan"

      assert_patch(show_live, Routes.plan_show_path(conn, :edit, plan))

      assert show_live
             |> form("#plan-form", plan: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#plan-form", plan: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.plan_show_path(conn, :show, plan))

      assert html =~ "Plan updated successfully"
      assert html =~ "some updated description"
    end
  end
end
