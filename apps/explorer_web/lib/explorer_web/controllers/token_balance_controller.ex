defmodule ExplorerWeb.TokenBalanceController do
  use ExplorerWeb, :controller

  alias Explorer.Chain
  alias Explorer.SmartContract.TokenBalanceReader

  def index(conn, %{"address_id" => address_hash_string}) do
    with true <- ajax?(conn),
         {:ok, address_hash} <- Chain.string_to_address_hash(address_hash_string) do
      token_balances =
        address_hash
        |> Chain.fetch_tokens_from_address_hash()
        |> TokenBalanceReader.fetch_token_balances_from_blockchain(address_hash_string)

      conn
      |> put_status(200)
      |> put_layout(false)
      |> render("_token_balances.html", tokens: token_balances)
    else
      _ ->
        not_found(conn)
    end
  end

  defp ajax?(conn) do
    case get_req_header(conn, "x-requested-with") do
      [value] -> value in ["XMLHttpRequest", "xmlhttprequest"]
      [] -> false
    end
  end
end
