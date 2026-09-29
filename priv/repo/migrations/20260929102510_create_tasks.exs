defmodule Jobs.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :name, :string
      add :command, :string
      add :job_uuid, :uuid

      timestamps(type: :utc_datetime)
    end

    create unique_index(:tasks, [:name])
  end
end
