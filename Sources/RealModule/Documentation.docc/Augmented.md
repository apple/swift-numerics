# ``Augmented``

A namespace for a family of algorithms that compute the results of floating-
point arithmetic using multiple values such that either the error is minimized
or the result is exact.

## Overview

Consider multiplying two Doubles. A Double has 53 significand bits, so their
product could be up to 106 bits wide before it is rounded to a Double result.
So up to 53 of those 106 bits will be "lost" in that process:

```swift
let a = 1.0 + .ulpOfOne // 1 + 2⁻⁵²
let b = 1.0 - .ulpOfOne // 1 - 2⁻⁵²
let c = a * b           // 1 - 2⁻¹⁰⁴ before rounding, rounds to 1.0
```

Sometimes it is necessary to preserve some or all of those low-order bits;
maybe a subsequent subtraction cancels most of the high-order bits, and so
the low-order part of the product suddenly becomes significant:

```swift
let result = 1 - c      // exactly zero, but "should be" 2⁻¹⁰⁴
```

Augmented arithmetic is a building-block that library writers can use to
handle cases like this more carefully. For the example above, one might
compute:

```swift
let (head, tail) = Augmented.product(a,b)
```

`head` is then 1.0 and `tail` is -2⁻¹⁰⁴, so no information has been lost.
Of course, the result is now split across two Doubles instead of one, but the
information in `tail` can be carried forward into future computations.
