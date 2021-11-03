# Integer Utilities

_Note: This module is only present on `main`, and has not yet been stabilized and released in a tag._

## Utilities defined for `BinaryInteger`

The following API are defined for all integer types conforming to `BinaryInteger`:

- The `gcd(_:_:)` free function implements the _Greatest Common Divisor_ operation.
  
- The `shifted(rightBy:rounding:)` method implements _bitwise shift with rounding_.
  
- The `divided(by:rounding:)` method implements division with specified rounding.
  (See also `SignedInteger.divided(by:rounding:)`, `remainder(dividingBy:rounding:)`, and `euclideanDivision(_:_:)` below).
  
## Utilities defined for `SignedInteger`

The following API are defined for signed integer types:

- The `divided(by:rounding:)` method implementing division with specified rounding, returning both quotient and remainder.
  This requires a signed type because the remainder is not generally representable for unsigned types.
  This is a disfavored overload; by default, you will get only the quotient as the result:
  ```
  let p = 5.divided(by: 3, rounding: .up)      // p = 2
  let (q, r) = 5.divided(by: 3, rounding: .up) // q = 2, r = -1
  ```
  
- The `remainder(dividingBy:rounding:)` method implementing the remainder operation; the `rounding` argument describes how to round the _quotient_, which is not returned.
  (The remainder is always exact, and hence is not rounded).
  
- The `euclideanDivision(_:_:)` free function implements _Euclidean division_.
  In this operation, the remainder is chosen to always be non-negative.
  This does not correspond to any rounding rule on the quotient, which is why it uses a distinct API.

## Utilities defined for `FixedWidthInteger`

- The `rotated(right:)` and `rotated(left:)` methods implement _bitwise rotation_ for signed and unsigned integer types.
  The count parameter may be any `BinaryInteger` type.

## Types

The `RoundingRule` enum is used with shift, division, and round operations to specify how to round their results to a representable value.
