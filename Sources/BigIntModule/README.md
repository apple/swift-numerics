# Arbitrarily Large Signed Integers (BigInt)

This module provides a `BigInt` number type to represent arbitrarily large signed integers:

```swift
1> import BigIntModule
2> let a = 42 as BigInt
```

The usual arithmetic operators are provided, as well as conversion to and from a collection of words (of type `UInt`) or a string (in any base between 2 and 36), plus conformances to the obvious usual protocols:

* `Comparable` (hence also `Equatable`)
* `Hashable`
* `ExpressibleByIntegerLiteral`
* `SignedInteger` (hence also `BinaryInteger`, `Strideable`, `SignedNumeric`, `Numeric`, and `AdditiveArithmetic`)
* `LosslessStringConvertible`
* `Codable`

Finally, greatest common divisor (gcd), lowest common multiple (lcm), exponentiation (power), and square root operations are implemented provided for all `BinaryInteger` types, as are the modular multiplicative inverse and modular exponentiation operations.

## Implementation notes

Internally, `BigInt` represents values by their signum function, significand, and exponent using the following notional formula:

```swift
let value = signum * significand << (UInt.bitWidth * exponent)
```

Bitwise and bit shift operators use the two's complement representation of negative values despite the way in which those values are stored internally.

### Dependencies:
- None.

### Test dependencies:
- `attaswift/BigInt` (reference implementation).
