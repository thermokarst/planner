defmodule Mix.Tasks.Planner.Register do
  use Mix.Task

  alias Planner.Accounts

  @shortdoc "Register a new Planner user"

  def run([email, password]) do
    Mix.Task.run("app.start")

    case Accounts.register_user(%{email: email, password: password}) do
      {:ok, _} ->
        Mix.shell().info("User created successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)
        Mix.shell().error("There was a problem.")
    end
  end
end
