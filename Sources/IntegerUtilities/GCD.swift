//===--- GCD.swift --------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021-2024 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// The [greatest common divisor][gcd] of `a` and `b`.
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
/// [gcd]: https://en.wikipedia.org/wiki/Greatest_common_divisor
@inlinable
public func gcd<T: BinaryInteger>(_ a: T, _ b: T) -> T {
  var x = a
  var y = b
  if x.magnitude < y.magnitude { swap(&x, &y) }
  // Avoid overflow when x = signed min, y = -1.
  if y.magnitude == 1 { return 1 }
  // Euclidean algorithm for GCD. It's worth using Lehmer instead for larger
  // integer types, but for now this is good and dead-simple and faster than
  // the other obvious choice, the binary algorithm.
  while y != 0 { (x, y) = (y, x%y) }
  // Try to convert result to T.
  if let result = T(exactly: x.magnitude) { return result }
  // If that fails, produce a diagnostic.
  fatalError("GCD (\(x)) is not representable as \(T.self).")
}
