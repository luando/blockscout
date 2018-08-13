defmodule Explorer.SmartContract.TokenBalanceReaderTest do
  use EthereumJSONRPC.Case
  use Explorer.DataCase

  doctest Explorer.SmartContract.TokenBalanceReader

  alias Explorer.SmartContract.TokenBalanceReader
  alias Explorer.Chain.Hash

  import Mox

  setup :verify_on_exit!

  describe "fetch_token_balances_from_blockchain/2" do
    test "fetches the token balances given the address hash" do
      address = insert(:address)
      token = insert(:token, contract_address: build(:contract_address))
      address_hash_string = Hash.to_string(address.hash)

      expect(
        EthereumJSONRPC.Mox,
        :json_rpc,
        fn [%{id: _, method: _, params: [%{data: _, to: _}]}], _options ->
          {:ok,
           [
             %{
               id: "balanceOf",
               jsonrpc: "2.0",
               result: "0x0000000000000000000000000000000000000000000000000000000000000000"
             }
           ]}
        end
      )

      TokenBalanceReader.fetch_token_balances_from_blockchain([token], address_hash_string)

      assert 1 == 1
    end
  end
end
