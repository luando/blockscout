defmodule ExplorerWeb.SmartContractController do
  use ExplorerWeb, :controller

  def index(conn, %{"address_id" => address_hash_string}) do
      with true <- ajax?(conn),
           {:ok, address_hash} <- Chain.string_to_address_hash(address_hash_string),
           {:ok, address} <- Chain.find_contract_address(address_hash) do
        read_only_functions = Reader.read_only_functions(address_hash)

        render(
          conn,
          "index.html",
          read_only_functions: read_only_functions,
          address: address,
          exchange_rate: Market.get_exchange_rate(Explorer.coin()) || Token.null(),
          transaction_count: transaction_count(address)
        )
      else
        _ ->
          not_found(conn)
      end
    end

    def show(conn, params) do
      with true <- ajax?(conn),
           {:ok, address_hash} <- Chain.string_to_address_hash(params["address_id"]),
           outputs =
             Reader.query_function(
               address_hash,
               %{name: params["function_name"], args: params["args"]}
             ) do
        conn
        |> put_status(200)
        |> put_layout(false)
        |> render(
          "_function_response.html",
          function_name: params["function_name"],
          outputs: outputs
        )
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
