defmodule LiveViewCounterWeb.CounterLive do
  use LiveViewCounterWeb, :live_view

  def mount(_params, _session, socket) do
    send_tick()
    {:ok, assign(socket, count: 0, form: to_form(%{"increment_by" => "1"}))}
  end

  def render(assigns) do
    ~H"""
    <p>Count: <%= @count %></p>
    <.button id="increment-button" phx-click="increment">Increment</.button>
    <.simple_form id="increment-form" for={@form} phx-change="change" phx-submit="increment_by">
      <.input type="number" field={@form[:increment_by]} label="Increment count" />
      <:actions>
        <.button>Increment</.button>
      </:actions>
    </.simple_form>
    """
  end

  def handle_info(:tick, socket) do
    send_tick()
    {:noreply, assign(socket, count: socket.assigns.count + 1)}
  end

  def handle_event("increment", _, socket) do
    {:noreply, assign(socket, count: socket.assigns.count + 1)}
  end

  def handle_event("change", params, socket) do
    socket =
      case Integer.parse(params["increment_by"]) do
        :error ->
          assign(socket,
            form: to_form(params, errors: [increment_by: {"Must be a valid integer", []}])
          )

        _ ->
          assign(socket, form: to_form(params))
      end

    {:noreply, socket}
  end

  def handle_event("increment_by", params, socket) do
    {:noreply,
     assign(socket, count: String.to_integer(params["increment_by"]) + socket.assigns.count)}
  end

  defp send_tick() do
    Process.send_after(self(), :tick, 1_000)
  end
end
