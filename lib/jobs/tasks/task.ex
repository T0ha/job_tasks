defmodule Jobs.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          name: String.t() | nil,
          command: String.t() | nil,
          job_uuid: Ecto.UUID.t() | nil,
          requires: [String.t()],
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

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
  @spec changeset(t(), map()) :: Ecto.Changeset.t(t())
  def changeset(task, attrs) do
    task
    |> cast(attrs, @allowable_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name)
  end
end
