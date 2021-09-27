# Integer Utilities

## Utilities defined for `BinaryInteger`

The following API are defined for all integer types conforming to `BinaryInteger`:

- The `gcd(_:_:)` free function implements the _Greatest Common Divisor_
  operation.
  
- The `shifted(right:rounding:)` method implements _bitwise shift with
  rounding_.

## Utilities defined for `FixedWidthInteger`

- The `rotated(right:)` and `rotated(left:)` methods implement _bitwise
  rotation_ for signed and unsigned integer types. The count parameter may
  be any `BinaryInteger` type.

## Types

The `RoundingRule` enum is used with shift, division, and round operations
to specify how to round their results to a representable value.
