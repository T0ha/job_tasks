defmodule JobsWeb.TaskJSON do
  alias Jobs.Tasks.Task

  @doc """
  Renders a list of tasks.
  """
  def index(%{tasks: tasks}) do
    for(task <- tasks, do: data(task))
  end

  @doc """
  Renders a single task.
  """
  def show(%{task: task}) do
    data(task)
  end

  defp data(%Task{} = task) do
    %{
      name: task.name,
      command: task.command
    }
  end
end
