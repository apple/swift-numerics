//===--- Root.swift -------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2026 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension Augmented {
  /// The product of two implicit sums, renormalized to a new `head + tail`.
  @_transparent
  @usableFromInline
  internal static func product<T: FloatingPoint>(
    _ a: (head: T, tail: T), _ b: (head: T, tail: T)
  ) -> (head: T, tail: T) {
    let exact = product(a.head, b.head)
    let tail = exact.tail + (a.head*b.tail + a.tail*b.head)
    return sum(large: exact.head, small: tail)
  }

  /// `y` raised to the positive power `n` as an implicit sum `head + tail`.
  @_transparent
  @usableFromInline
  internal static func power<T: FloatingPoint>(
    _ y: T, _ n: UInt
  ) -> (head: T, tail: T) {
    var result = (head: T(1), tail: T(0))
    var base = (head: y, tail: T(0))
    var remaining = n
    while remaining > 0 {
      if remaining & 1 == 1 { result = product(result, base) }
      remaining >>= 1
      if remaining > 0 { base = product(base, base) }
    }
    return result
  }
}

/// One Newton step on `f(y) = yⁿ - x`, refining an estimate of the `n`th root.
///
/// `yⁿ` is evaluated to roughly twice the working precision, so the residual
/// survives the cancellation that makes it useless in working precision.
/// Returns `nil` where the step cannot be taken, leaving the estimate in place.
@_transparent
@usableFromInline
internal func _correctedRoot<T: BinaryFloatingPoint>(
  _ y: T, exponent n: UInt, of x: T
) -> T? {
  guard (2...1024).contains(n), y.isNormal, x.isFinite else { return nil }
  let power = Augmented.power(y, n)
  guard power.head.isNormal else { return nil }
  let residual = (power.head - x) + power.tail
  let step = residual * y / (T(n) * power.head)
  guard step.isFinite else { return nil }
  return y - step
}
