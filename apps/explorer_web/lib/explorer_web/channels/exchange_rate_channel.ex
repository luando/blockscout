defmodule ExplorerWeb.ExchangeRateChannel do
  @moduledoc """
  Establishes pub/sub channel for address page live updates.
  """
  use ExplorerWeb, :channel

  alias ExplorerWeb.ChainView

  intercept(["new_rate"])

  def join("exchange_rate:new_rate", _params, socket) do
    {:ok, %{}, socket}
  end

  def handle_out("new_rate", %{exchange_rate: exchange_rate}, socket) do
    Gettext.put_locale(ExplorerWeb.Gettext, socket.assigns.locale)

    push(socket, "transaction", %{
      exchange_rate: ChainView.format_exchange_rate(exchange_rate),
      market_cap: ChainView.format_market_cap(exchange_rate)
    })

    {:noreply, socket}
  end
end
