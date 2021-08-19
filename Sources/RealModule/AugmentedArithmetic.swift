//===--- AugmentedArithmetic.swift ----------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// A namespace for "augmented arithmetic" operations for types conforming to
/// `Real`.
///
/// Augmented arithmetic refers to a family of algorithms that represent
/// the results of floating-point computations using multiple values such that
/// either the error is minimized or the result is exact.
public enum Augmented { }

extension Augmented {
  /// The product `a * b` represented as an implicit sum `head + tail`.
  ///
  /// `head` is the correctly rounded value of `a*b`. If no overflow or
  /// underflow occurs, `tail` represents the rounding error incurred in
  /// computing `head`, such that the exact product is the sum of `head`
  /// and `tail` computed without rounding.
  ///
  /// This operation is sometimes called "twoProd" or "twoProduct".
  ///
  /// Edge Cases:
  /// -
  /// - `head` is always the IEEE 754 product `a * b`.
  /// - If `head` is not finite, `tail` is unspecified and should not be
  ///   interpreted as having any meaning (it may be `NaN` or `infinity`).
  /// - When `head` is close to the underflow boundary, the rounding error
  ///   may not be representable due to underflow, and `tail` will be rounded.
  ///   If `head` is very small, `tail` may even be zero, even though the
  ///   product is not exact.
  /// - If `head` is zero, `tail` is also a zero with unspecified sign.
  ///
  /// Postconditions:
  /// -
  /// - If `head` is normal, then `abs(tail) < head.ulp`.
  ///   Assuming IEEE 754 default rounding, `abs(tail) <= head.ulp/2`.
  /// - If both `head` and `tail` are normal, then `a * b` is exactly
  ///   equal to `head + tail` when computed as real numbers.
  @_transparent
  public static func product<T:Real>(_ a: T, _ b: T) -> (head: T, tail: T) {
    let head = a*b
    // TODO: consider providing an FMA-less implementation for use when
    // targeting platforms without hardware FMA support. This works everywhere,
    // falling back on the C math.h fma funcions, but may be slow on older x86.
    let tail = (-head).addingProduct(a, b)
    return (head, tail)
  }
  
  /// The sum `a + b` represented as an implicit sum `head + tail`.
  ///
  /// `head` is the correctly rounded value of `a + b`. `tail` is the
  /// error from that computation rounded to the closest representable
  /// value.
  ///
  /// Unlike `Augmented.product(a, b)`, the rounding error of a sum can
  /// never underflow. However, it may not be exactly representable when
  /// `a` and `b` differ widely in magnitude.
  ///
  /// This operation is sometimes called "fastTwoSum".
  ///
  /// - Parameters:
  ///   - a: The summand with larger magnitude.
  ///   - b: The summand with smaller magnitude.
  ///
  /// Preconditions:
  /// -
  /// - `large.magnitude` must not be smaller than `small.magnitude`.
  ///   They may be equal, or one or both may be `NaN`.
  ///   This precondition is only enforced in debug builds.
  ///
  /// Edge Cases:
  /// -
  /// - `head` is always the IEEE 754 sum `a + b`.
  /// - If `head` is not finite, `tail` is unspecified and should not be
  ///   interpreted as having any meaning (it may be `NaN` or `infinity`).
  ///
  /// Postconditions:
  /// -
  /// - If `head` is normal, then `abs(tail) < head.ulp`.
  ///   Assuming IEEE 754 default rounding, `abs(tail) <= head.ulp/2`.
  @_transparent
  public static func sum<T:Real>(large a: T, small b: T) -> (head: T, tail: T) {
    assert(!(b.magnitude > a.magnitude))
    let head = a + b
    let tail = a - head + b
    return (head, tail)
  }
}
