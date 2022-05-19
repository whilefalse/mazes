defmodule Mazes.Generate do
  alias Mazes.{Compass, Types}

  @spec generate(integer()) :: Types.maze()
  def generate(size) do
    initial_grid =
      Enum.flat_map(0..(size - 1), fn x ->
        Enum.map(0..(size - 1), fn y ->
          {{x, y}, %{}}
        end)
      end)
      |> Map.new()

    recursive_carve_passage({0, 0}, initial_grid, size)
  end

  @spec recursive_carve_passage(Types.coord(), Types.maze(), integer()) :: Types.maze()
  defp recursive_carve_passage({curr_x, curr_y}, grid, size) do
    Compass.directions()
    |> Enum.shuffle()
    |> Enum.reduce(grid, fn dir, acc ->
      next_x = curr_x + Compass.dx(dir)
      next_y = curr_y + Compass.dy(dir)

      if next_y >= 0 and next_y < size and
           next_x >= 0 and next_x < size and
           Map.get(acc, {next_x, next_y}) == %{} do
        new_grid =
          acc
          |> put_in([{curr_x, curr_y}, dir], true)
          |> put_in([{next_x, next_y}, Compass.opposite(dir)], true)

        recursive_carve_passage({next_x, next_y}, new_grid, size)
      else
        acc
      end
    end)
  end
end
