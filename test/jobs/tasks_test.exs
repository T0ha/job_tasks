defmodule Jobs.TasksTest do
  use Jobs.DataCase

  alias Jobs.Tasks

  describe "tasks" do
    alias Jobs.Tasks.Task

    import Jobs.TasksFixtures

    @invalid_attrs %{command: nil, name: nil, job_uuid: nil}

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Tasks.list_tasks() == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Tasks.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      valid_attrs = %{command: "some command", name: "some name", job_uuid: "7488a646-e31f-11e4-aace-600308960662"}

      assert {:ok, %Task{} = task} = Tasks.create_task(valid_attrs)
      assert task.command == "some command"
      assert task.name == "some name"
      assert task.job_uuid == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()
      update_attrs = %{command: "some updated command", name: "some updated name", job_uuid: "7488a646-e31f-11e4-aace-600308960668"}

      assert {:ok, %Task{} = task} = Tasks.update_task(task, update_attrs)
      assert task.command == "some updated command"
      assert task.name == "some updated name"
      assert task.job_uuid == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_task(task, @invalid_attrs)
      assert task == Tasks.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Tasks.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Tasks.change_task(task)
    end
  end
end
