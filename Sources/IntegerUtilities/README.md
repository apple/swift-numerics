# Integer Utilities

_Note: This module is only present on `main`, and has not yet been stabilized and released in a tag._

## Utilities defined for `BinaryInteger`

The following API are defined for all integer types conforming to `BinaryInteger`:

- The `gcd(_:_:)` free function implements the _Greatest Common Divisor_
  operation.

## Utilities defined for `FixedWidthInteger`

- The `rotated(right:)` and `rotated(left:)` methods implement _bitwise
  rotation_ for signed and unsigned integer types. The count parameter may
  be any `BinaryInteger` type.
