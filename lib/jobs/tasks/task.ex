defmodule Jobs.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :name, :string
    field :command, :string
    field :job_uuid, Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:name, :command, :job_uuid])
    |> validate_required([:name, :command, :job_uuid])
    |> unique_constraint(:name)
  end
end
