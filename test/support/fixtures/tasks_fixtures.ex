defmodule Jobs.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Jobs.Tasks` context.
  """

  @doc """
  Generate a unique task name.
  """
  def unique_task_name, do: "some name#{System.unique_integer([:positive])}"

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        command: "some command",
        job_uuid: "7488a646-e31f-11e4-aace-600308960662",
        name: unique_task_name()
      })
      |> Jobs.Tasks.create_task()

    task
  end

  @doc """
  Generate a unique job name.
  """
  def unique_job_name, do: "some name#{System.unique_integer([:positive])}"

  @doc """
  Generate a job.
  """
  def job_fixture(attrs \\ %{}) do
    {:ok, job} =
      attrs
      |> Enum.into(%{
        "tasks" => [
          %{"name" => unique_job_name(), "command" => "some command"}
        ]
      })
      |> Jobs.Tasks.create_job()

    job
  end
end
