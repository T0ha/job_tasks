defmodule Jobs.Repo do
  use Ecto.Repo,
    otp_app: :jobs,
    adapter: Ecto.Adapters.Postgres
end
