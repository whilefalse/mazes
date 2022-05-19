defmodule MazesWeb.PageLive do
  use MazesWeb, :live_view

  alias Mazes.{Compass, Types}

  @keys_map %{"ArrowUp" => :N, "ArrowDown" => :S, "ArrowLeft" => :W, "ArrowRight" => :E}
  @keys Map.keys(@keys_map)

  @impl true
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

  @impl true
  def handle_event("move_current_location", %{"key" => key}, socket) when key in @keys do
    {:noreply, move(socket, @keys_map[key])}
  end

  def handle_event(
        "move_current_location",
        _,
        %{assigns: %{location: location, finish: finish}} = socket
      ) do
    if finished?(location, finish) do
      {:noreply, new_maze(socket)}
    else
      {:noreply, socket}
    end
  end

  defp new_maze(socket) do
    size = :rand.uniform(10) + 14
    start = {:rand.uniform(size) - 1, :rand.uniform(size) - 1}
    finish = {:rand.uniform(size) - 1, :rand.uniform(size) - 1}

    socket
    |> assign(:maze, Mazes.Generate.generate(size))
    |> assign(:visited, MapSet.new([start]))
    |> assign(:location, start)
    |> assign(:start, start)
    |> assign(:finish, finish)
    |> assign(:finished, false)
    |> assign(:size, size)
    |> assign(:loading, false)
    |> assign(:color, rand_color())
  end

  defp move(
         %{
           assigns: %{
             maze: maze,
             visited: visited,
             finish: finish,
             location: {curr_x, curr_y}
           }
         } = socket,
         dir
       ) do
    new_x = curr_x + Compass.dx(dir)
    new_y = curr_y + Compass.dy(dir)

    if can_move?(maze, {curr_x, curr_y}, dir) do
      if MapSet.member?(visited, {new_x, new_y}) do
        send_update(Mazes.CellComponent, id: cell_id({curr_x, curr_y}), highlighted: false)
        assign(socket, :visited, MapSet.delete(visited, {curr_x, curr_y}))
      else
        send_update(Mazes.CellComponent, id: cell_id({new_x, new_y}), highlighted: true)
        assign(socket, :visited, MapSet.put(visited, {new_x, new_y}))
      end
      |> assign(:location, {new_x, new_y})
      |> assign(:finished, {new_x, new_y} == finish)
    else
      socket
    end
  end

  @spec can_move?(Types.maze(), Types.coord(), Compass.direction()) :: boolean()
  defp can_move?(maze, {curr_x, curr_y}, dir) do
    maze[{curr_x, curr_y}][dir]
  end

  @spec finished?(Types.coord(), Types.coord()) :: boolean()
  defp finished?(location, finish) do
    location == finish
  end

  @spec rand_color() :: String.t()
  defp rand_color() do
    "rgb(#{:rand.uniform(192) + 63}, #{:rand.uniform(192) + 63}, #{:rand.uniform(192) + 63})"
  end

  @spec cell_id(Types.coord()) :: String.t()
  defp cell_id({x, y}) do
    "cell-#{x}-#{y}"
  end
end
