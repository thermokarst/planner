defmodule Planner.PlansTest do
  use Planner.DataCase

  alias Planner.Plans

  describe "plans" do
    alias Planner.Plans.Plan

    @valid_attrs %{description: "some description", done: true, end: ~N[2010-04-17 14:00:00], id: "some id", name: "some name", start: ~N[2010-04-17 14:00:00]}
    @update_attrs %{description: "some updated description", done: false, end: ~N[2011-05-18 15:01:01], id: "some updated id", name: "some updated name", start: ~N[2011-05-18 15:01:01]}
    @invalid_attrs %{description: nil, done: nil, end: nil, id: nil, name: nil, start: nil}

    def plan_fixture(attrs \\ %{}) do
      {:ok, plan} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Plans.create_plan()

      plan
    end

    test "list_plans/0 returns all plans" do
      plan = plan_fixture()
      assert Plans.list_plans() == [plan]
    end

    test "get_plan!/1 returns the plan with given id" do
      plan = plan_fixture()
      assert Plans.get_plan!(plan.id) == plan
    end

    test "create_plan/1 with valid data creates a plan" do
      assert {:ok, %Plan{} = plan} = Plans.create_plan(@valid_attrs)
      assert plan.description == "some description"
      assert plan.done == true
      assert plan.end == ~N[2010-04-17 14:00:00]
      assert plan.id == "some id"
      assert plan.name == "some name"
      assert plan.start == ~N[2010-04-17 14:00:00]
    end

    test "create_plan/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Plans.create_plan(@invalid_attrs)
    end

    test "update_plan/2 with valid data updates the plan" do
      plan = plan_fixture()
      assert {:ok, %Plan{} = plan} = Plans.update_plan(plan, @update_attrs)
      assert plan.description == "some updated description"
      assert plan.done == false
      assert plan.end == ~N[2011-05-18 15:01:01]
      assert plan.id == "some updated id"
      assert plan.name == "some updated name"
      assert plan.start == ~N[2011-05-18 15:01:01]
    end

    test "update_plan/2 with invalid data returns error changeset" do
      plan = plan_fixture()
      assert {:error, %Ecto.Changeset{}} = Plans.update_plan(plan, @invalid_attrs)
      assert plan == Plans.get_plan!(plan.id)
    end

    test "delete_plan/1 deletes the plan" do
      plan = plan_fixture()
      assert {:ok, %Plan{}} = Plans.delete_plan(plan)
      assert_raise Ecto.NoResultsError, fn -> Plans.get_plan!(plan.id) end
    end

    test "change_plan/1 returns a plan changeset" do
      plan = plan_fixture()
      assert %Ecto.Changeset{} = Plans.change_plan(plan)
    end
  end
end
