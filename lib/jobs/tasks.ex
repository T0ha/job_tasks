defmodule Jobs.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias Jobs.Repo

  alias Jobs.Tasks.Task

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks do
    Repo.all(Task)
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{data: %Task{}}

  """
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  alias Jobs.Tasks.Job

  @doc """
  Returns the list of jobs.

  ## Examples

      iex> list_jobs()
      [%Job{}, ...]

  """
  def list_jobs do
    Task
    |> Repo.all()
    |> Enum.group_by(& &1.job_uuid)
    |> Enum.map(fn {job_uuid, tasks} -> %Job{id: job_uuid, tasks: tasks} end)
  end

  @doc """
  Gets a single job.

  Raises `Ecto.NoResultsError` if the Job does not exist.

  ## Examples

      iex> get_job!(123)
      %Job{}

  """
  def get_job!(id) do
    query = from t in Task, where: t.job_uuid == ^id

    case Repo.all(query) do
      [] -> raise Ecto.NoResultsError, queryable: query
      tasks -> %Job{id: id, tasks: tasks}
    end
  end

  @doc """
  Creates a job.

  ## Examples

      iex> create_job(%{field: value})
      {:ok, %Job{}}

      iex> create_job(%{field: bad_value})
      {:error, ...}

  """
  def create_job(attrs) do
    %Job{id: Ecto.UUID.generate()}
    |> Job.changeset(attrs)
    |> Ecto.Changeset.apply_action(:insert)
    |> insert_tasks()
  end

  defp insert_tasks({:error, _e} = error), do: error
  defp insert_tasks({:ok, %Job{} = job}) do
    job
    |> Map.update(:tasks, [], fn tasks ->
      Enum.map(tasks, fn task ->
        Repo.insert!(task, returning: true)
      end)
    end)
    |> then(&({:ok, &1}))
  end

end
