defmodule PlannerWeb.Util do
  import Phoenix.HTML
  alias Earmark.Options

  def md_to_html(md_text) do
    md_text
    |> Earmark.as_html!(%Options{smartypants: false})
    |> raw
  end
end
