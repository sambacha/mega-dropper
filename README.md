# 💣 Mega Dropper

A hyper-optimized ERC20 & ETH distribution contracts. Use it for mass 1-time payments or for entire
airdrops.

## Usage
### ETH Airdropping

The [`ETHDropper`](src/ETHDropper.huff) contract manages sending unique amounts of ETH to a large
amount of addresses. Each recipient/amount pair in the batch of transfers must be encoded as
a packed uint96 and address in 32-byte chunks:

```python
def encode_eth_params(amounts: list[int], recipients: list[bytes]) -> bytes:
    final_calldata = bytes()

    assert len(amounts) == len(recipients), 'Param length mismatch'
    for amount, recipient in zip(amounts, recipients):
        assert amount in range(0, 1 << 96), 'Amount larger than uint96'
        final_calldata += amount.to_bytes(12, 'big')
        assert len(recipient) == 20, 'Not 20-byte address'
        final_calldata += recipient

    return final_calldata
```

### ERC20 Airdropping

The [`ERC20Dropper`](src/ERC20Dropper.huff) contract manages sending unique amounts of a single
ERC20 token to a large amount of addresses. Each recipient/amount pair in the batch of transfers
must be encoded as an address and packed uint96 in 32-byte chunks:

> **Warning**
> Unlike with the ETH contract the `address` and `amount` for each pair are encoded in reverse
> order.

```python
def encode_erc20_params(token: bytes, amounts: list[int], recipients: list[bytes]) -> bytes:
    final_calldata = bytes()

    total = sum(amounts)
    assert total in range(0, 1 << 96), 'Total larger than uint96'
    final_calldata += total.to_bytes(12, 'big')

    assert len(token) == 20, 'Token not 20-byte address'
    final_calldata += token

    assert len(amounts) == len(recipients), 'Param length mismatch'
    for amount, recipient in zip(amounts, recipients):
        assert len(recipient) == 20, 'Not 20-byte address'
        final_calldata += recipient
        assert amount in range(0, 1 << 96), 'Amount larger than uint96'
        final_calldata += amount.to_bytes(12, 'big')

    return final_calldata
```

