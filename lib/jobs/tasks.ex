defmodule Jobs.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias Jobs.Repo

  alias Jobs.Tasks.Task
  alias Jobs.Tasks.Job

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  @spec list_tasks() :: [Task.t()]
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
  @spec get_task!(term()) :: Task.t()
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_task(map()) :: {:ok, Task.t()} | {:error, Ecto.Changeset.t(Task.t())}
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
  @spec update_task(Task.t(), map()) :: {:ok, Task.t()} | {:error, Ecto.Changeset.t(Task.t())}
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
  @spec delete_task(Task.t()) :: {:ok, Task.t()} | {:error, Ecto.Changeset.t(Task.t())}
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{data: %Task{}}

  """
  @spec change_task(Task.t(), map()) :: Ecto.Changeset.t(Task.t())
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  @doc """
  Returns the list of jobs.

  ## Examples

      iex> list_jobs()
      [%Job{}, ...]

  """
  @spec list_jobs() :: [Job.t()]
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
  @spec get_job!(Ecto.UUID.t()) :: Job.t()
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
  @spec create_job(map()) :: {:ok, Job.t()} | {:error, Ecto.Changeset.t(Job.t())}
  def create_job(attrs) do
    %Job{id: Ecto.UUID.generate()}
    |> Job.changeset(attrs)
    |> Ecto.Changeset.apply_action(:insert)
    |> insert_tasks()
  end

  @spec insert_tasks({:ok, Job.t()} | {:error, Ecto.Changeset.t(Job.t())}) ::
          {:ok, Job.t()} | {:error, Ecto.Changeset.t(Job.t())}
  defp insert_tasks({:error, _changeset} = error), do: error

  defp insert_tasks({:ok, %Job{tasks: tasks} = job}) do
    inserted_tasks = Enum.map(tasks, &Repo.insert!(&1, returning: true))
    {:ok, %{job | tasks: inserted_tasks}}
  end
end
