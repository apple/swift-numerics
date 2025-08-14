# ``Relaxed``

A namespace for a family of operations that "relax" the usual rules for
floating-point to allow reassociation of arithmetic and FMA formation.

## Overview

Because of rounding, and the arithmetic rules for infinity and NaN values,
floating-point addition and multiplication are not associative:

```swift
let ε = Double.leastNormalMagnitude
let sumLeft  = (-1 + 1) + ε  //  0 + ε = ε
let sumRight =  -1 + (1 + ε) // -1 + 1 = 0

let ∞ = Double.infinity
let productLeft  = (ε * ε) * ∞  // 0 * ∞ = .nan
let productRight =  ε * (ε * ∞) // ε * ∞ = ∞
```

For some algorithms, the distinction between these results is incidental; for
some others it is critical to their correct function. Because of this,
compilers cannot freely change the order of reductions, which prevents some
important optimizations: extraction of instruction-level parallelism and
vectorization.

If you know that you are in a case where the order of elements being summed
or multiplied is incidental, the Relaxed operations give you a mechanism
to communicate that to the compiler and unlock these optimizations. For
example, consider the following two functions:

```swift
func sum(array: [Float]) -> Float {
  array.reduce(0, +)
}

func relaxedSum(array: [Float]) -> Float {
  array.reduce(0, Relaxed.sum)
}
```

when called on an array with 1000 elements in a Release build, `relaxedSum`
is about 8x faster than `sum` on Apple M2, with a similar speedup on Intel
processors, without the need for any unsafe code or flags.

### multiplyAdd

In addition to `sum` and `product`, `Relaxed` provides the
``multiplyAdd(_:_:_:)`` operation, which communciates to the compiler that
it is allowed to replace separate multiply and add operations with a single
_fused multiply-add_ instruction if its cost model indicates that it would
be advantageous to do so. When targeting processors that support this
instruction, this may be a significant performance advantage.
