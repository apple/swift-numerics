# Arbitrarily Large Signed Integers (BigInt)

This module provides a `BigInt` number type:

```swift
1> import BigIntModule
2> let a = 42 as BigInt
```

The usual arithmetic operators are provided, as well as conversion to and from a collection of words (of type `UInt`), plus conformances to the obvious usual protocols: `Comparable` (hence also `Equatable`), `Hashable`, `LosslessStringConvertible`, `Codable`, `ExpressibleByIntegerLiteral`, and `SignedInteger` (hence also `Strideable`, `AdditiveArithmetic`, `Numeric`, `SignedNumeric`, and `BinaryInteger`).

### Dependencies:
- None.

### Test dependencies:
- `attaswift/BigInt` (reference implementation).

## Design notes

_To be completed_