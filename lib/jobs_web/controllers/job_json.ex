defmodule JobsWeb.JobJSON do
  alias Jobs.Tasks.{Job, Task}

  @type job_data :: %{id: Ecto.UUID.t() | nil, tasks: [task_data()]}
  @type task_data :: %{name: String.t() | nil, command: String.t() | nil}

  @doc """
  Renders a list of jobs.
  """
  @spec index(%{jobs: [Job.t()]}) :: [job_data()]
  def index(%{jobs: jobs}) do
    for(job <- jobs, do: data(job))
  end

  @doc """
  Renders a single job.
  """
  @spec show(%{job: Job.t()}) :: job_data()
  def show(%{job: job}) do
    data(job)
  end

  @spec data(Job.t()) :: job_data()
  defp data(%Job{} = job) do
    %{
      id: job.id,
      tasks: Enum.map(job.tasks, &task_data/1)
    }
  end

  @spec task_data(Task.t()) :: task_data()
  defp task_data(%Task{} = task) do
    %{
      name: task.name,
      command: task.command
    }
  end
end
