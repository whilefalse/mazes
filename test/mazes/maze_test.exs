defmodule MazeTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  import StreamData

  alias Mazes.{Compass, Maze, MockRandom, Random}

  describe "Deteministic mazes" do
    setup do
      # This deterministic maze always goes in the order N, S, E, W, so it will carve
      # a passage downwards to the bottom wall, move right one, then back up again,
      # crossing the grid column by column.
      Mox.stub(MockRandom, :shuffle, fn _ -> [:N, :S, :E, :W] end)
      :ok
    end

    test "generates a small expected deterministic maze" do
      maze = Maze.generate(4)

      # Expected maze looks like this:
      # |==|==|==|==|
      # |  |     |  |
      # |  |  |  |  |
      # |  |  |  |  |
      # |     |     |
      # |==|==|==|==|

      assert maze == %{
               {0, 0} => %{S: true},
               {0, 1} => %{S: true, N: true},
               {0, 2} => %{S: true, N: true},
               {0, 3} => %{E: true, N: true},
               {1, 3} => %{W: true, N: true},
               {1, 2} => %{N: true, S: true},
               {1, 1} => %{N: true, S: true},
               {1, 0} => %{E: true, S: true},
               {2, 0} => %{W: true, S: true},
               {2, 1} => %{S: true, N: true},
               {2, 2} => %{S: true, N: true},
               {2, 3} => %{E: true, N: true},
               {3, 3} => %{N: true, W: true},
               {3, 2} => %{N: true, S: true},
               {3, 1} => %{N: true, S: true},
               {3, 0} => %{S: true}
             }
    end

    test "generates a bigger expected deterministic maze" do
      size = 50
      bound = size - 1
      maze = Maze.generate(size)

      for x <- 0..bound do
        for y <- 0..bound do
          expected =
            %{
              N: y != 0,
              S: y != bound,
              E: (y == bound and rem(x, 2) == 0) or (y == 0 and rem(x, 2) == 1 and x < bound),
              W: (y == bound and rem(x, 2) == 1) or (y == 0 and rem(x, 2) == 0 and x > 0)
            }
            |> Enum.filter(fn {_, val} -> val end)
            |> Map.new()

          actual = maze[{x, y}]

          assert actual == expected,
                 "Failed at position: #{inspect({x, y})}.\nExpected: #{inspect(expected)}.\nActual: #{inspect(actual)}"
        end
      end
    end
  end

  describe "Non deterministic maze properties" do
    setup do
      # Use the real random implementation
      Mox.stub_with(MockRandom, Random)
      :ok
    end

    property "no cell is completely closed" do
      check all(size <- maze_sizes_to_test()) do
        maze = Maze.generate(size)

        if size == 1 do
          # A maze of size 1 by definition is just a single square, so this is
          # the one exception where all cells have a wall.
          [{{0, 0}, cell}] = Map.to_list(maze)
          assert cell == %{}
        else
          for {_, cell} <- maze do
            assert Enum.any?(cell, fn {_, val} -> val == true end)
          end
        end
      end
    end

    property "all nodes are connected" do
      check all(size <- maze_sizes_to_test()) do
        maze = Maze.generate(size)

        assert connected?(maze)
      end
    end

    property "edges of the maze are never breachable" do
      check all(size <- maze_sizes_to_test()) do
        maze = Maze.generate(size)

        for i <- 0..(size - 1) do
          assert maze[{i, 0}][:N] == nil
          assert maze[{i, size - 1}][:S] == nil

          assert maze[{0, i}][:W] == nil
          assert maze[{size - 1, i}][:E] == nil
        end
      end
    end

    property "passages are symetrical" do
      check all(size <- maze_sizes_to_test()) do
        maze = Maze.generate(size)

        for x <- 0..(size - 1) do
          for y <- 0..(size - 1) do
            cell = maze[{x, y}]
            children = children(maze, {x, y})

            for {dir, child} <- children do
              assert cell[dir]
              assert maze[child][Compass.opposite(dir)]
            end
          end
        end
      end
    end

    property "there are no cycles" do
      check all(size <- maze_sizes_to_test()) do
        maze = Maze.generate(size)

        refute contains_cycle?(maze)
      end
    end
  end

  describe "contains_cycle?/1 test function" do
    test "detects a maze with a cycle" do
      # |==|==|==|
      # |  |     |
      # |  |  |  |
      # |        |
      # |==|==|==|

      maze = %{
        {0, 0} => %{S: true},
        {0, 1} => %{S: true, N: true},
        {0, 2} => %{E: true, N: true},
        {1, 2} => %{N: true, E: true, W: true},
        {1, 1} => %{N: true, S: true},
        {1, 0} => %{S: true, E: true},
        {2, 0} => %{W: true, S: true},
        {2, 1} => %{N: true, S: true},
        {2, 2} => %{N: true, W: true}
      }

      assert contains_cycle?(maze)
    end

    test "correctly says there are no cycles when there isn't one" do
      # |==|==|==|
      # |  |  |  |
      # |  |  |  |
      # |        |
      # |==|==|==|

      maze = %{
        {0, 0} => %{S: true},
        {0, 1} => %{S: true, N: true},
        {0, 2} => %{E: true, N: true},
        {1, 2} => %{N: true, E: true, W: true},
        {1, 1} => %{N: true, S: true},
        {1, 0} => %{S: true},
        {2, 0} => %{S: true},
        {2, 1} => %{N: true, S: true},
        {2, 2} => %{N: true, W: true}
      }

      refute contains_cycle?(maze)
    end
  end

  describe "connected?/1 test function" do
    test "detects a disconnected maze" do
      # |==|==|==|
      # |  |  |  |
      # |  |  |  |
      # |  |  |  |
      # |==|==|==|

      maze = %{
        {0, 0} => %{S: true},
        {0, 1} => %{S: true, N: true},
        {0, 2} => %{N: true},
        {1, 2} => %{N: true},
        {1, 1} => %{N: true, S: true},
        {1, 0} => %{S: true},
        {2, 0} => %{S: true},
        {2, 1} => %{N: true, S: true},
        {2, 2} => %{N: true}
      }

      refute connected?(maze)
    end

    test "detects a connected maze" do
      # |==|==|==|
      # |  |  |  |
      # |  |  |  |
      # |        |
      # |==|==|==|

      maze = %{
        {0, 0} => %{S: true},
        {0, 1} => %{S: true, N: true},
        {0, 2} => %{E: true, N: true},
        {1, 2} => %{N: true, E: true, W: true},
        {1, 1} => %{N: true, S: true},
        {1, 0} => %{S: true},
        {2, 0} => %{S: true},
        {2, 1} => %{N: true, S: true},
        {2, 2} => %{N: true, W: true}
      }

      assert connected?(maze)
    end

    test "detects a connected maze with a cycle" do
      # |==|==|==|
      # |  |     |
      # |  |  |  |
      # |        |
      # |==|==|==|

      maze = %{
        {0, 0} => %{S: true},
        {0, 1} => %{S: true, N: true},
        {0, 2} => %{E: true, N: true},
        {1, 2} => %{N: true, E: true, W: true},
        {1, 1} => %{N: true, S: true},
        {1, 0} => %{S: true, E: true},
        {2, 0} => %{W: true, S: true},
        {2, 1} => %{N: true, S: true},
        {2, 2} => %{N: true, W: true}
      }

      assert connected?(maze)
    end

    test "detects a disconnected maze with a cycle" do
      # |==|==|==|
      # |     |  |
      # |  |  |  |
      # |     |  |
      # |==|==|==|

      maze = %{
        {0, 0} => %{S: true, E: true},
        {0, 1} => %{S: true, N: true},
        {0, 2} => %{E: true, N: true},
        {1, 2} => %{N: true, W: true},
        {1, 1} => %{N: true, S: true},
        {1, 0} => %{S: true, W: true},
        {2, 0} => %{S: true},
        {2, 1} => %{N: true, S: true},
        {2, 2} => %{N: true}
      }

      refute connected?(maze)
    end
  end

  @spec contains_cycle?(Maze.t(), MapSet.t(Maze.coord()), Maze.coord(), Maze.coord() | nil) ::
          boolean()
  defp contains_cycle?(
         maze,
         visited \\ MapSet.new([]),
         curr_coord \\ {0, 0},
         parent_coord \\ nil
       ) do
    if MapSet.member?(visited, curr_coord) do
      true
    else
      new_visited = MapSet.put(visited, curr_coord)

      children =
        children(maze, curr_coord)
        |> Enum.map(fn {_, child} -> child end)
        |> Enum.filter(&(&1 != parent_coord))

      Enum.any?(
        children,
        &contains_cycle?(maze, new_visited, &1, curr_coord)
      )
    end
  end

  @spec connected?(Maze.t()) :: boolean
  defp connected?(maze) do
    dfs(maze) == MapSet.new(Map.keys(maze))
  end

  @spec dfs(Maze.t(), MapSet.t(Maze.coord()), Maze.coord()) ::
          MapSet.t(Maze.coord())
  defp dfs(maze, visited \\ MapSet.new([]), curr_coord \\ {0, 0}) do
    new_visited = MapSet.put(visited, curr_coord)

    children =
      children(maze, curr_coord)
      |> Enum.map(fn {_, child} -> child end)
      |> Enum.filter(&(!MapSet.member?(visited, &1)))

    Enum.reduce(children, new_visited, fn child, v ->
      dfs(maze, v, child)
    end)
  end

  @spec children(Maze.t(), Maze.coord()) :: [{Compass.direction(), Maze.coord()}]
  defp children(maze, {curr_x, curr_y} = curr_coord) do
    maze[curr_coord]
    |> Enum.filter(fn {_, v} -> v == true end)
    |> Enum.map(fn {dir, _} ->
      {
        dir,
        {
          curr_x + Compass.dx(dir),
          curr_y + Compass.dy(dir)
        }
      }
    end)
  end

  @spec maze_sizes_to_test() :: StreamData.t(integer())
  defp maze_sizes_to_test() do
    integer(1..20)
  end
end
