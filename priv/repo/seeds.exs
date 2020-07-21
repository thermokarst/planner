# mix run priv/repo/seeds.exs

alias Planner.Tasks
alias Planner.Plans

tasks_records = [
  %{"value" => "task1"},
  %{"value" => "task2"},
  %{"value" => "task3"},
  %{"value" => "task4"},
  %{"value" => "task5"},
  %{"value" => "task6"}
]

tasks =
  Enum.map(tasks_records, fn record ->
    {:ok, task} = Tasks.add_task(record)
    task
  end)

plans_records = [
  %{name: "plan1"},
  %{name: "plan2"},
  %{name: "plan3"}
]

plans =
  Enum.map(plans_records, fn record ->
    {:ok, plan} = Plans.create_plan(record)
    plan
  end)

[t1, t2, t3, t4, t5, _] = tasks
[p1, p2, _] = plans

plan_details_records = [
  %{plan_id: p1.id, task_id: t1.id, sort: 0},
  %{plan_id: p1.id, task_id: t2.id, sort: 0},
  %{plan_id: p1.id, task_id: t3.id, sort: 0},
  %{plan_id: p2.id, task_id: t4.id, sort: 0},
  %{plan_id: p2.id, task_id: t5.id, sort: 0}
  # deliberately leave off the last task
]

Enum.each(plan_details_records, fn record ->
  Plans.create_plan_detail(record)
end)
