defmodule MazesWeb.PageLive do
  use MazesWeb, :live_view
  @dx %{N: 0, S: 0, E: 1, W: -1}
  @dy %{N: -1, S: 1, E: 0, W: 0}

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
  def handle_event("move_current_location", %{"code" => "ArrowUp"}, socket) do
    {:noreply, move(socket, :N)}
  end

  def handle_event("move_current_location", %{"code" => "ArrowDown"}, socket) do
    {:noreply, move(socket, :S)}
  end

  def handle_event("move_current_location", %{"code" => "ArrowLeft"}, socket) do
    {:noreply, move(socket, :W)}
  end

  def handle_event("move_current_location", %{"code" => "ArrowRight"}, socket) do
    {:noreply, move(socket, :E)}
  end

  def handle_event("move_current_location", _, socket) do
    if finished?(socket) do
      {:noreply, new_maze(socket)}
    else
      {:noreply, socket}
    end
  end

  defp finished?(%{assigns: %{finish: finish, location: location}}) do
    location == finish
  end

  defp new_maze(socket) do
    size = :rand.uniform(10) + 19
    start = {:rand.uniform(size) - 1, :rand.uniform(size) - 1}
    finish = {:rand.uniform(size) - 1, :rand.uniform(size) - 1}

    socket
    |> assign(:maze, Mazes.Generate.generate(size))
    |> assign(:visited, [start])
    |> assign(:location, start)
    |> assign(:start, start)
    |> assign(:finish, finish)
    |> assign(:size, size)
    |> assign(:loading, false)
    |> assign(:color, rand_color())
  end

  defp move(
         %{assigns: %{maze: maze, size: size, visited: visited, location: {curr_x, curr_y}}} =
           socket,
         dir
       ) do
    new_x = curr_x + @dx[dir]
    new_y = curr_y + @dy[dir]

    if new_x >= 0 and new_x < size and
         new_y >= 0 and new_y < size and
         maze[curr_y][curr_x][dir] do
      updated_location = assign(socket, :location, {new_x, new_y})

      if Enum.member?(visited, {new_x, new_y}) do
        updated_location
        |> assign(:visited, List.delete(visited, {curr_x, curr_y}))
      else
        updated_location
        |> assign(:visited, [{new_x, new_y} | visited])
      end
    else
      socket
    end
  end

  defp rand_color() do
    "rgb(#{:rand.uniform(192) + 63}, #{:rand.uniform(192) + 63}, #{:rand.uniform(192) + 63})"
  end
end
