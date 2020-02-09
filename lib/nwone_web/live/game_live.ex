defmodule NwoneWeb.GameLive do
  use Phoenix.LiveView

  alias Nwone.GameServer
  alias Nwone.PlayerServer

  @control_key_codes ["ArrowUp", "ArrowDown", "ArrowLeft", "ArrowRight", "Space"]

  def render(assigns) do
    NwoneWeb.GameView.render("game.html", assigns)
  end

  def mount(params, socket) do
    if connected?(socket), do: NwoneWeb.Endpoint.subscribe(topic())

    socket =
      socket
      |> assign(
        player: params["player"],
        map: GameServer.get_map(),
        player_pid: params["player_pid"]
      )

    {:ok, socket}
  end

  def handle_event("do_action", %{"code" => code}, socket) when code in @control_key_codes do
    {new_map, new_player} = PlayerServer.move(socket.assigns.player_pid, String.to_atom(code))
    notify(topic())
    {:noreply, assign(socket, map: new_map, player: new_player)}
  end

  def handle_event("do_action", _key, socket) do
    {:noreply, socket}
  end

  def notify(topic) do
    NwoneWeb.Endpoint.broadcast_from(self(), topic, "state_update", %{})
  end

  def topic() do
    "game-topic"
  end

  def handle_info(%{event: "state_update"}, socket) do
    new_map = GameServer.get_map()
    new_player = PlayerServer.get_player(socket.assigns.player_pid)
    {:noreply, assign(socket, map: new_map, player: new_player)}
  end
end
