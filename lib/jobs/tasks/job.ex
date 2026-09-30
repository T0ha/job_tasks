defmodule Jobs.Tasks.Job do
  use Ecto.Schema
  import Ecto.Changeset
  

  alias Jobs.Tasks.Task

  embedded_schema do
    embeds_many :tasks, Task
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [])
    |> cast_embed(:tasks, with: &Jobs.Tasks.Task.changeset(&1, Map.put(&2, "job_uuid", job.id)))
    |> validate_unique_task_names()
    |> validate_required_tasks()
  end


  defp validate_unique_task_names(changeset) do
    tasks = get_field(changeset, :tasks, [])

    task_names = Enum.map(tasks, & &1.name)

    if length(task_names) == length(Enum.uniq(task_names)) do
      changeset
    else
      add_error(changeset, :tasks, "Task names must be unique")
    end
  end

  defp validate_required_tasks(%Ecto.Changeset{valid?: false} = changeset), do: changeset
  defp validate_required_tasks(changeset) do
    tasks = get_field(changeset, :tasks, [])

    tasks
    |> build_graph()
    |> verify_graph()
    |> update_changeset(changeset)
  end

  defp build_graph(tasks) do
    graph =
      Graph.new()
      |> Graph.add_vertices(Enum.map(tasks, & &1.name))

    Graph.add_edges(graph, Enum.flat_map(tasks,
      fn %Task{name: name, requires: requires} ->
        Enum.map(requires || [], &edge(graph, &1, name))
    end
    ))
  end

  defp edge(graph, from, to) do
    if Graph.has_vertex?(graph, from) do
      {from, to}
    else
      {from, to, label: :missing}
    end
  end

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

  defp update_changeset({:error, message}, changeset), do:
    add_error(changeset, :tasks, message)

  defp update_changeset({:ok, graph}, changeset) do
    update_change(changeset, :tasks, &sorted_tasks(graph, &1))
  end

  defp sorted_tasks(graph, tasks) do
    by_name = Map.new(tasks, &{get_field(&1, :name), &1})

    graph
      |> Graph.topsort()
      |> Enum.map(&Map.fetch!(by_name, &1))
  end
end
