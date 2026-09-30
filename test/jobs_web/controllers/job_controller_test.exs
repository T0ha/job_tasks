defmodule JobsWeb.JobControllerTest do
  use JobsWeb.ConnCase

  import Jobs.TasksFixtures
  alias Jobs.Tasks.Job

  @create_attrs %{
    "tasks" => [
      %{
        "name" => "task-1",
        "command" => "touch /tmp/file1"
      },
      %{
        "name" => "task-2",
        "command" => "cat /tmp/file1",
        "requires" => [
          "task-3"
        ]
      },
      %{
        "name" => "task-3",
        "command" => "echo 'Hello World!' > /tmp/file1",
        "requires" => [
          "task-1"
        ]
      },
      %{
        "name" => "task-4",
        "command" => "rm /tmp/file1",
        "requires" => [
          "task-2",
          "task-3"
        ]
      }
    ]
  }

  @create_responce_tasks [
      %{
        "name" => "task-1",
        "command" => "touch /tmp/file1"
      },
      %{
        "name" => "task-3",
        "command" => "echo 'Hello World!' > /tmp/file1"
      },
      %{
        "name" => "task-2",
        "command" => "cat /tmp/file1"
      },
      %{
        "name" => "task-4",
        "command" => "rm /tmp/file1"
      }
    ]

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all jobs", %{conn: conn} do
      conn = get(conn, ~p"/api/jobs")
      assert json_response(conn, 200) == []
    end
  end

  describe "create job" do
    test "renders job to json when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/jobs", job: @create_attrs)

      assert %{
               "id" => id,
        "tasks" => @create_responce_tasks
      } = json_response(conn, 201)
      assert String.length(id) == 36 # A bit ugli check if it's a UUID
    end

    test "renders job to bash when data is valid and headers are correct", %{conn: conn} do
      conn = 
        conn
        |> put_req_header("accept", "text/x-shellscript")
        |> post(~p"/api/jobs", job: @create_attrs)

      response_bash = ~w(
        #!/usr/bin/env bash
        touch /tmp/file1
        echo "Hello World!" > /tmp/file1
        cat /tmp/file1
        rm /tmp/file1
      )

      assert  response(conn, 201) == response_bash
    end

    test "renders job with duplicated task names returns error", %{conn: conn} do
      create_attrs_duplicated = %{
        "tasks" => [
          %{
            "name" => "task-1",
            "command" => "touch /tmp/file1"
          },
          %{
            "name" => "task-2",
            "command" => "cat /tmp/file1",
            "requires" => [
              "task-3"
            ]
          },
          %{
            "name" => "task-1",
            "command" => "touch /tmp/file1"
          },
          %{
            "name" => "task-3",
            "command" => "echo 'Hello World!' > /tmp/file1",
            "requires" => [
              "task-1"
            ]
          },
          %{
            "name" => "task-4",
            "command" => "rm /tmp/file1",
            "requires" => [
              "task-2",
              "task-3"
            ]
          }
        ]
      }
      conn = post(conn, ~p"/api/jobs", job: create_attrs_duplicated)

      assert json_response(conn, 422)["errors"] == %{}
    end

    test "renders job with cyclic dependet tasks returns error", %{conn: conn} do
      create_attrs_cyclic = %{
        "tasks" => [
          %{
            "name" => "task-1",
            "command" => "touch /tmp/file1"
          },
          %{
            "name" => "task-2",
            "command" => "cat /tmp/file1",
            "requires" => [
              "task-3"
            ]
          },
          %{
            "name" => "task-3",
            "command" => "echo 'Hello World!' > /tmp/file1",
            "requires" => [
              "task-1",
              "task-2"
            ]
          },
          %{
            "name" => "task-4",
            "command" => "rm /tmp/file1",
            "requires" => [
              "task-2",
              "task-3"
            ]
          }
        ]
      }

      conn = post(conn, ~p"/api/jobs", job: create_attrs_cyclic)

      assert json_response(conn, 422)["errors"] == %{}
    end
  end
end
