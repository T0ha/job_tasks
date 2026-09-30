defmodule Jobs.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @allowable_fields ~w(name command job_uuid requires)a
  @required_fields @allowable_fields

  schema "tasks" do
    field :name, :string
    field :command, :string
    field :job_uuid, Ecto.UUID

    field :requires, {:array, :string}, default: []

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, @allowable_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name)
  end
end
