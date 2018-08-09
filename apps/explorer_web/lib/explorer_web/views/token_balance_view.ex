defmodule ExplorerWeb.TokenBalanceView do
  use ExplorerWeb, :view

  def balance_formatted(%{balance: balance, decimals: nil}) do
    format_according_to_decimals(balance, 0)
  end

  def balance_formatted(%{balance: balance, decimals: decimals}) do
    format_according_to_decimals(balance, decimals)
  end
end
