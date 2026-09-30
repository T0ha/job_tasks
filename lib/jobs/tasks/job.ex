defmodule Jobs.Tasks.Job do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    embeds_many :tasks, Jobs.Tasks.Task
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [])
    |> cast_embed(:tasks, with: &Jobs.Tasks.Task.changeset(&1, Map.put(&2, "job_uuid", job.id)))
  end
end
