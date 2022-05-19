defmodule Mazes.MazeTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  import StreamData

  describe "Deteministic mazes" do
    setup do
      # This deterministic maze always goes in the order N, S, E, W, so it will carve
      # a passage downwards to the bottom wall, move right one, then back up again,
      # crossing the grid column by column. These assersions check that.
      Mox.stub(Mazes.MockRandom, :shuffle, fn _ -> [:N, :S, :E, :W] end)
      :ok
    end

    test "generates a small expected deterministic maze" do
      maze = Mazes.Maze.generate(4)

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
      size = 100
      bound = size - 1
      maze = Mazes.Maze.generate(size)

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
      Mox.stub_with(Mazes.MockRandom, Mazes.Random)
      :ok
    end

    property "every cell is reachable" do
      check all(size <- integer(2..20)) do
        maze = Mazes.Maze.generate(size)

        assert Enum.all?(maze, fn {_, cell} ->
                 Enum.any?(cell, fn {_dir, val} -> val == true end)
               end)
      end
    end

    property "edges of the maze are never breachable" do
      check all(size <- integer(2..20)) do
        maze = Mazes.Maze.generate(size)

        for i <- 0..(size - 1) do
          assert maze[{i, 0}][:N] == nil
          assert maze[{i, size - 1}][:S] == nil

          assert maze[{0, i}][:W] == nil
          assert maze[{size - 1, i}][:E] == nil
        end
      end
    end

    property "there are no cycles" do
      # TODO
    end
  end
end
