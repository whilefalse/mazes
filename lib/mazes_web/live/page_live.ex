defmodule MazesWeb.PageLive do
  @moduledoc """
  Live view for showing a maze and allowing you to navigate around it.
  """
  use MazesWeb, :live_view

  alias Mazes.{Compass, Maze}

  @keys_map %{"ArrowUp" => :N, "ArrowDown" => :S, "ArrowLeft" => :W, "ArrowRight" => :E}
  @keys Map.keys(@keys_map)

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    if connected?(socket) do
      {:ok, new_maze(socket)}
    else
      {:ok, assign(socket, :loading, true)}
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
    r = random()
    size = r.integer_between(15, 20)
    start = {r.integer_between(0, size - 1), r.integer_between(0, size - 1)}
    finish = {r.integer_between(0, size - 1), r.integer_between(0, size - 1)}

    socket
    |> assign(:maze, Maze.generate(size))
    |> assign(:visited, MapSet.new([start]))
    |> assign(:location, start)
    |> assign(:start, start)
    |> assign(:finish, finish)
    |> assign(:finished?, false)
    |> assign(:size, size)
    |> assign(:color, rand_color())
    |> assign(:loading, false)
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
  defp can_move?(maze, curr_coord, dir) do
    maze[curr_coord][dir]
  end

  @spec perform_move(MapSet.t(Maze.coord()), Maze.coord(), Maze.coord()) :: MapSet.t(Maze.coord())
  defp perform_move(visited, curr_coord, new_coord) do
    if MapSet.member?(visited, new_coord) do
      # Moving backwards, so unhighlight the current cell
      send_update(Mazes.CellComponent, id: cell_id(curr_coord), highlighted: false)
      MapSet.delete(visited, curr_coord)
    else
      # Moving forwards, so highlight the new cell
      send_update(Mazes.CellComponent, id: cell_id(new_coord), highlighted: true)
      MapSet.put(visited, new_coord)
    end
  end

  @spec rand_color() :: String.t()
  defp rand_color() do
    r = random()

    "rgb(#{r.integer_between(193, 255)}, #{r.integer_between(193, 255)}, #{r.integer_between(193, 255)})"
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

  defp random(), do: Application.get_env(:mazes, :random)
end
