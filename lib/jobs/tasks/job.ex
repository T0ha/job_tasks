defmodule Jobs.Tasks.Job do
  use Ecto.Schema
  import Ecto.Changeset

  alias Jobs.Tasks.Task

  @type t :: %__MODULE__{
          id: Ecto.UUID.t() | nil,
          tasks: [Task.t()]
        }

  embedded_schema do
    embeds_many :tasks, Task
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t(t())
  def changeset(job, attrs) do
    job
    |> cast(attrs, [])
    |> cast_embed(:tasks, with: &Jobs.Tasks.Task.changeset(&1, Map.put(&2, "job_uuid", job.id)))
    |> validate_unique_task_names()
    |> validate_required_tasks()
  end

  @spec validate_unique_task_names(Ecto.Changeset.t(t())) :: Ecto.Changeset.t(t())
  defp validate_unique_task_names(changeset) do
    tasks = get_field(changeset, :tasks, [])

    task_names = Enum.map(tasks, & &1.name)

    if length(task_names) == length(Enum.uniq(task_names)) do
      changeset
    else
      add_error(changeset, :tasks, "Task names must be unique")
    end
  end

  @spec validate_required_tasks(Ecto.Changeset.t(t())) :: Ecto.Changeset.t(t())
  defp validate_required_tasks(%Ecto.Changeset{valid?: false} = changeset), do: changeset

  defp validate_required_tasks(changeset) do
    tasks = get_field(changeset, :tasks, [])

    tasks
    |> build_graph()
    |> verify_graph()
    |> update_changeset(changeset)
  end

  @spec build_graph([Task.t()]) :: Graph.t()
  defp build_graph(tasks) do
    graph =
      Graph.new()
      |> Graph.add_vertices(Enum.map(tasks, & &1.name))

    Graph.add_edges(
      graph,
      Enum.flat_map(
        tasks,
        fn %Task{name: name, requires: requires} ->
          Enum.map(requires || [], &edge(graph, &1, name))
        end
      )
    )
  end

  @spec edge(Graph.t(), Graph.vertex(), Graph.vertex()) ::
          {Graph.vertex(), Graph.vertex()} | {Graph.vertex(), Graph.vertex(), [label: atom()]}
  defp edge(graph, from, to) do
    if Graph.has_vertex?(graph, from) do
      {from, to}
    else
      {from, to, label: :missing}
    end
  end

  @spec verify_graph(Graph.t()) :: {:ok, Graph.t()} | {:error, String.t()}
  defp verify_graph(graph) do
    cond do
      Graph.is_cyclic?(graph) ->
        {:error, "Tasks have circular dependencies"}

      Enum.any?(Graph.edges(graph), &(&1.label == :missing)) ->
        {:error, "Some tasks have missing dependencies"}

      true ->
        {:ok, graph}
    end
  end

  @spec update_changeset({:ok, Graph.t()} | {:error, String.t()}, Ecto.Changeset.t(t())) ::
          Ecto.Changeset.t(t())
  defp update_changeset({:error, message}, changeset), do: add_error(changeset, :tasks, message)

  defp update_changeset({:ok, graph}, changeset) do
    update_change(changeset, :tasks, &sorted_tasks(graph, &1))
  end

  @spec sorted_tasks(Graph.t(), [Ecto.Changeset.t(Task.t())]) :: [Ecto.Changeset.t(Task.t())]
  defp sorted_tasks(graph, tasks) do
    by_name = Map.new(tasks, &{get_field(&1, :name), &1})

    graph
    |> Graph.topsort()
    |> Enum.map(&Map.fetch!(by_name, &1))
  end
end
