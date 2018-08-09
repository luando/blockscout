defmodule Explorer.SmartContract.TokenBalanceReader do
  @moduledoc """
  Reads Token's balances using Smart Contract functions from the blockchain.
  """

  alias Explorer.SmartContract.Reader

  @abi [
    %{
      "type" => "function",
      "stateMutability" => "view",
      "payable" => false,
      "outputs" => [
        %{
          "type" => "uint256",
          "name" => "balance"
        }
      ],
      "name" => "balanceOf",
      "inputs" => [
        %{
          "type" => "address",
          "name" => "tokenOwner"
        }
      ],
      "constant" => true
    }
  ]

  def fetch_token_balances_from_blockchain(tokens, address_hash_string) do
    tokens
    |> Task.async_stream(&fetch_from_block_chain(&1, address_hash_string))
    |> Enum.map(&format_result/1)
  end

  defp fetch_from_block_chain(%{contract_address_hash: address_hash} = token, address_hash_string) do
    address_hash
    |> Reader.query_unverified_contract(@abi, %{"balanceOf" => [address_hash_string]})
    |> format_block_chain_result(token)
  end

  defp format_block_chain_result(%{"balanceOf" => {_, balance}}, token) do
    Map.put(token, :balance, balance)
  end

  defp format_result({:ok, map}) do
    map
  end
end
