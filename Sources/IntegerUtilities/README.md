# Integer Utilities

_Note: This module is only present on `main`, and has not yet been stabilized and released in a tag._

## Utilities defined for `BinaryInteger`

The following API are defined for all integer types:

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
  
### [Saturating Arithmetic][saturating]

The following saturating operations are defined as methods on `FixedWidthInteger`:

- `addingWithSaturation(_:)`
- `subtractingWithSaturation(_:)`
- `negatedWithSaturation(_:)`
- `multipliedWithSaturation(by:)`
- `shiftedWithSaturation(leftBy:rounding:)`

These implement _saturating arithmetic_.
They are an alternative to the usual `+`, `-`, and `*` operators, which trap if the result cannot be represented in the argument type, and `&+`, `&-`, `&*`, and `<<`, which wrap out-of-range results modulo 2ⁿ for some n.
Instead these methods clamp the result to the representable range of the type:
```
let x: Int8 = 84
let y: Int8 = 100
let a = x + y                     // traps due to overflow
let b = x &+ y                    // wraps to -72
let c = x.addingWithSaturation(y) // saturates to 127
```

If you are using saturating arithmetic, you may also want to perform saturating conversions between integer types; this functionality is provided by the standard library via the [`init(clamping:)` API][clamping].

## Types

The `RoundingRule` enum is used with shift, division, and round operations to specify how to round their results to a representable value.

[saturating]: https://en.wikipedia.org/wiki/Saturation_arithmetic
[clamping]: https://developer.apple.com/documentation/swift/binaryinteger/init(clamping:)
