defmodule JobsWeb.JobController do
  use JobsWeb, :controller

  alias Jobs.Tasks
  alias Jobs.Tasks.Job

  action_fallback JobsWeb.FallbackController

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _params) do
    jobs = Tasks.list_jobs()
    render(conn, :index, jobs: jobs)
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t() | {:error, Ecto.Changeset.t(Job.t())}
  def create(conn, %{"job" => job_params}) do
    with {:ok, %Job{} = job} <- Tasks.create_job(job_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/jobs/#{job}")
      |> render(:show, job: job)
    end
  end

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    job = Tasks.get_job!(id)
    render(conn, :show, job: job)
  end
end
