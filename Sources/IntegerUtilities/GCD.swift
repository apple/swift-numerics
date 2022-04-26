//===--- GCD.swift --------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// The greatest common divisor of `a` and `b`.
///
/// If both inputs are zero, the result is zero. If one input is zero, the
/// result is the absolute value of the other input.
///
/// The result must be representable within its type. In particular, the gcd
/// of a signed, fixed-width integer type's minimum with itself (or zero)
/// cannot be represented, and results in a trap.
///
///     gcd(Int.min, Int.min)   // Overflow error
///     gcd(Int.min, 0)         // Overflow error
///
/// [wiki]: https://en.wikipedia.org/wiki/Greatest_common_divisor
@inlinable
public func gcd<T: BinaryInteger>(_ a: T, _ b: T) -> T {
  var x = a.magnitude
  var y = b.magnitude
  
  if x == 0 { return T(y) }
  if y == 0 { return T(x) }
  
  let xtz = x.trailingZeroBitCount
  let ytz = y.trailingZeroBitCount
  
  y >>= ytz
  
  // The binary GCD algorithm
  //
  // After the right-shift in the loop, both x and y are odd. Each pass removes
  // at least one low-order bit from the larger of the two, so the number of
  // iterations is bounded by the sum of the bit-widths of the inputs.
  //
  // A tighter bound is the maximum bit-width of the inputs, which is achieved
  // by odd numbers that sum to a power of 2, though the proof is more involved.
  repeat {
    x >>= x.trailingZeroBitCount
    if x < y { swap(&x, &y) }
    x -= y
  } while x != 0
  
  return T(y << min(xtz, ytz))
}
