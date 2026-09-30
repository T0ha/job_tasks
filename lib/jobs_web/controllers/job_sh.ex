defmodule JobsWeb.JobSH do
  @moduledoc """
  Renders `Jobs.Tasks.Job` structs as bash scripts.
  """

  alias Jobs.Tasks.Job

  @doc """
  Renders a job as a bash script.
  """
  @spec show(%{job: Job.t()}) :: String.t()
  def show(%{job: %Job{tasks: tasks}}) do
    [
      "#!/usr/bin/env bash",
      Enum.map(tasks, & &1.command)
    ]
    |> List.flatten()
    |> Enum.join("\n")
  end
end
