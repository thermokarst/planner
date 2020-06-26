defmodule PlannerWeb.Util do
  import Phoenix.HTML

  def md_to_html(md_text) do
    md_text
    |> Earmark.as_html!()
    |> raw
  end
end
