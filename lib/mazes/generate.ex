defmodule Mazes.Generate do
  @dx %{N: 0, S: 0, W: -1, E: 1}
  @dy %{N: -1, S: 1, W: 0, E: 0}
  @opposite %{N: :S, S: :N, E: :W, W: :E}

  def generate(size) do
    initial_grid =
      0..(size - 1)
      |> Map.new(fn y ->
        {
          y,
          0..(size - 1)
          |> Map.new(fn x ->
            {x, %{}}
          end)
        }
      end)

    recursive_carve_passage(0, 0, initial_grid, size)
  end

  defp recursive_carve_passage(curr_x, curr_y, grid, size) do
    [:N, :E, :S, :W]
    |> Enum.shuffle()
    |> Enum.reduce(grid, fn dir, acc ->
      next_x = curr_x + @dx[dir]
      next_y = curr_y + @dy[dir]

      if next_y >= 0 and next_y < size and
           next_x >= 0 and next_x < size and
           acc[next_y][next_x] == %{} do
        new_grid =
          acc
          |> put_in([curr_y, curr_x, dir], true)
          |> put_in([next_y, next_x, @opposite[dir]], true)

        recursive_carve_passage(next_x, next_y, new_grid, size)
      else
        acc
      end
    end)
  end
end
