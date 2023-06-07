# ``Augmented``

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
handle cases like this more carefully.
