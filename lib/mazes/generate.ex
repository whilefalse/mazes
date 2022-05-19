defmodule Mazes.Generate do
  alias Mazes.{Compass, Types}

  @spec generate(integer()) :: Types.maze()
  def generate(size) do
    initial_grid =
      Stream.flat_map(0..(size - 1), fn x ->
        Stream.map(0..(size - 1), fn y ->
          {{x, y}, %{}}
        end)
      end)
      |> Map.new()

    recursive_carve_passage(initial_grid, {0, 0}, size)
  end

  @spec recursive_carve_passage(Types.maze(), Types.coord(), integer()) :: Types.maze()
  defp recursive_carve_passage(grid, {curr_x, curr_y}, size) do
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

        recursive_carve_passage(new_grid, {next_x, next_y}, size)
      else
        acc
      end
    end)
  end
end
