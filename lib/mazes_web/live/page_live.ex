defmodule MazesWeb.PageLive do
  use MazesWeb, :live_view

  alias Mazes.{Compass, Maze}

  @keys_map %{"ArrowUp" => :N, "ArrowDown" => :S, "ArrowLeft" => :W, "ArrowRight" => :E}
  @keys Map.keys(@keys_map)

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    if connected?(socket) do
      {:ok, new_maze(socket)}
    else
      {
        :ok,
        socket
        |> assign(:loading, true)
      }
    end
  end

  @impl Phoenix.LiveView
  def handle_event("move_current_location", %{"key" => key}, socket) when key in @keys do
    {:noreply, move(socket, @keys_map[key])}
  end

  def handle_event("move_current_location", _, socket) do
    {:noreply, socket}
  end

  @spec new_maze(Phoenix.LiveView.Socket.t()) :: Phoenix.LiveView.Socket.t()
  defp new_maze(socket) do
    size = :rand.uniform(10) + 14
    start = {:rand.uniform(size) - 1, :rand.uniform(size) - 1}
    finish = {:rand.uniform(size) - 1, :rand.uniform(size) - 1}

    socket
    |> assign(:maze, Maze.generate(size))
    |> assign(:visited, MapSet.new([start]))
    |> assign(:location, start)
    |> assign(:start, start)
    |> assign(:finish, finish)
    |> assign(:finished?, false)
    |> assign(:size, size)
    |> assign(:loading, false)
    |> assign(:color, rand_color())
  end

  @spec move(Phoenix.LiveView.Socket.t(), Compass.direction()) :: Phoenix.LiveView.Socket.t()
  defp move(
         %{
           assigns: %{
             maze: maze,
             visited: visited,
             finish: finish,
             location: {curr_x, curr_y} = curr_coord
           }
         } = socket,
         dir
       ) do
    new_coord = {
      curr_x + Compass.dx(dir),
      curr_y + Compass.dy(dir)
    }

    if can_move?(maze, curr_coord, dir) do
      new_visited = perform_move(visited, curr_coord, new_coord)

      socket
      |> assign(:visited, new_visited)
      |> assign(:location, new_coord)
      |> assign(:finished?, new_coord == finish)
    else
      socket
    end
  end

  @spec can_move?(Maze.t(), Maze.coord(), Compass.direction()) :: boolean()
  defp can_move?(maze, {curr_x, curr_y}, dir) do
    maze[{curr_x, curr_y}][dir]
  end

  @spec perform_move(MapSet.t(Maze.coord()), Maze.coord(), Maze.coord()) :: MapSet.t(Maze.coord())
  defp perform_move(visited, curr_coord, new_coord) do
    if MapSet.member?(visited, new_coord) do
      send_update(Mazes.CellComponent, id: cell_id(curr_coord), highlighted: false)
      MapSet.delete(visited, curr_coord)
    else
      send_update(Mazes.CellComponent, id: cell_id(new_coord), highlighted: true)
      MapSet.put(visited, new_coord)
    end
  end

  @spec rand_color() :: String.t()
  defp rand_color() do
    "rgb(#{:rand.uniform(192) + 63}, #{:rand.uniform(192) + 63}, #{:rand.uniform(192) + 63})"
  end

  @spec cell_id(Maze.coord()) :: String.t()
  defp cell_id({x, y}) do
    "cell-#{x}-#{y}"
  end

  @spec text(Maze.coord(), Maze.coord(), Maze.coord()) :: String.t()
  defp text(coord, start, finish) do
    case coord do
      ^start -> "S"
      ^finish -> "F"
      _ -> raw("&nbsp;")
    end
  end
end
