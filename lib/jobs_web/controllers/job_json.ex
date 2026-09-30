defmodule JobsWeb.JobJSON do
  alias Jobs.Tasks.{Job, Task}

  @doc """
  Renders a list of jobs.
  """
  def index(%{jobs: jobs}) do
    for(job <- jobs, do: data(job))
  end

  @doc """
  Renders a single job.
  """
  def show(%{job: job}) do
    data(job)
  end

  defp data(%Job{} = job) do
    %{
      id: job.id,
      tasks: Enum.map(job.tasks, &task_data/1)
    }
  end

  defp task_data(%Task{} = task) do
    %{
      name: task.name,
      command: task.command
    }
  end
end
