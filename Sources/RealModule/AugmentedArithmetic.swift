//===--- AugmentedArithmetic.swift ----------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020-2025 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

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
  ///
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
  ///
  /// - If `head` is normal, then `abs(tail) < head.ulp`.
  ///   Assuming IEEE 754 default rounding, `abs(tail) <= head.ulp/2`.
  /// - If both `head` and `tail` are normal, then `a * b` is exactly
  ///   equal to `head + tail` when computed as real numbers.
  @_transparent
  public static func product<T:FloatingPoint>(
    _ a: T, _ b: T
  ) -> (head: T, tail: T) {
    let head = a*b
    // TODO: consider providing an FMA-less implementation for use when
    // targeting platforms without hardware FMA support. This works everywhere,
    // falling back on the C math.h fma funcions, but may be slow on older x86.
    let tail = (-head).addingProduct(a, b)
    return (head, tail)
  }
  
  /// The sum `a + b` represented as an implicit sum `head + tail`.
  ///
  /// - Parameters:
  ///   - a: The summand with larger magnitude.
  ///   - b: The summand with smaller magnitude.
  ///
  /// `head` is the correctly rounded value of `a + b`. `tail` is the
  /// error from that computation rounded to the closest representable
  /// value.
  ///
  /// > Note:
  /// > `tail` is guaranteed to be the best approximation to the error of
  ///   the sum only if `large.magnitude` >= `small.magnitude`. If this is
  ///   not the case, then `head` is the correctly rounded sum, but `tail`
  ///   is not guaranteed to be the exact error. If you do not know a priori
  ///   how the magnitudes of `a` and `b` compare, you likely want to use
  ///   ``sum(_:_:)`` instead.
  ///
  /// Unlike ``product(_:_:)``, the rounding error of `sum` never underflows.
  ///
  /// This operation is sometimes called ["fastTwoSum"].
  ///
  /// > Note:
  /// > Classical fastTwoSum does not work when `radix` is 10. This function
  ///   will fall back on another algorithm for decimal floating-point types
  ///   to ensure correct results.
  ///
  /// Edge Cases:
  ///
  /// - `head` is always the IEEE 754 sum `a + b`.
  /// - If `head` is not finite, `tail` is unspecified and should not be
  ///   interpreted as having any meaning (it may be `NaN` or `infinity`).
  ///
  /// Postconditions:
  ///
  /// - If `head` is normal, then `abs(tail) < head.ulp`.
  ///   Assuming IEEE 754 default rounding, `abs(tail) <= head.ulp/2`.
  ///
  /// ["fastTwoSum"]:  https://en.wikipedia.org/wiki/2Sum
  @_transparent
  public static func sum<T: FloatingPoint>(
    large a: T, small b: T
  ) -> (head: T, tail: T) {
    // Fall back on 2Sum if radix != 2. Future implementations might use an
    // cheaper algorithm specialized for decimal FP, but must deliver a
    // correct result if the preconditions are satisfied.
    guard T.radix == 2 else { return sum(a, b) }
    // Fast2Sum:
    let head = a + b
    let tail = a - head + b
    return (head, tail)
  }
  
  /// The sum `a + b` represented as an implicit sum `head + tail`.
  ///
  /// `head` is the correctly rounded value of `a + b`. `tail` is the
  /// error from that computation rounded to the closest representable
  /// value.
  ///
  /// The magnitude of the summands does not change the result of this
  /// operation. If you know statically that `a.magnitude >= b.magnitude`,
  /// you may want to consider using ``sum(large:small:)`` to get the same
  /// result somewhat more efficiently. If you do not have such a static
  /// bound, you usually want to use this function instead.
  ///
  /// Unlike ``product(_:_:)``, the rounding error of `sum` never underflows.
  ///
  /// This operation is sometimes called ["twoSum"].
  ///
  /// - Parameters:
  ///   - a: One of the summands
  ///   - b: The other summand
  ///
  /// Edge Cases:
  ///
  /// - `head` is always the IEEE 754 sum `a + b`.
  /// - If `head` is not finite, `tail` is unspecified and should not be
  ///   interpreted as having any meaning (it may be `NaN` or `infinity`).
  ///
  /// Postconditions:
  ///
  /// - If `head` is normal, then `abs(tail) < head.ulp`.
  ///   Assuming IEEE 754 default rounding, `abs(tail) <= head.ulp/2`.
  ///
  /// ["twoSum"]:  https://en.wikipedia.org/wiki/2Sum
  @_transparent
  public static func sum<T: FloatingPoint>(
    _ a: T, _ b: T
  ) -> (head: T, tail: T) {
    let head = a + b
    let x = head - b
    let y = head - x
    let tail = (a - x) + (b - y)
    return (head, tail)
  }
  
  /// `ab - cd` computed with extra care to avoid catastrophic cancellation.
  ///
  /// When the vectors `(a,c)` and `(d,b)` are nearly colinear, the expression
  /// `ab - cd` will suffer from cancellation if computed naively, and the
  /// relative error of the result may be quite large.
  /// `fastDifferenceOfProducts` uses augmented arithmetic to avoid this and
  /// produce a result that is guaranteed accurate to (1+radix)/2 ulp.¹
  ///
  /// For example:
  ///
  /// ```swift
  /// let a: Float = 1
  /// let b: Float = 1
  /// let c: Float = 1 + .ulpOfOne
  /// let d: Float = 1 - .ulpOfOne
  /// let naive = a*b - c*d                           // 0, all bits were lost
  /// let precise = fastDifferenceOfProducts(a,b,c,d) // 1.42108547E-14
  /// ```
  ///
  /// Note that `fDOP(a,b,c,d)` is not generally equal to `-fDOP(c,d,-a,b)`;
  /// it achieves a much better error bound than the naive expression at the
  /// cost of this symmetry. This does not typically matter in practice, but
  /// may occasionally be surprising.
  ///
  /// -----
  ///
  /// ¹ It is not immediately obvious that such a good bound can be achieved;
  ///   see the following paper for proofs:
  ///
  ///  "Further analysis of Kahan's algorithm for the accurate computation
  ///   of 2 x 2 determinants," Jeannerod, Claude-Pierre and Louvet, Nicolas
  ///   and Muller, Jean-Michel, https://ens-lyon.hal.science/ensl-00649347
  @_transparent
  public static func fastDifferenceOfProducts<T: FloatingPoint>(
    _ a: T, _ b: T, _ c: T, _ d: T
  ) -> T {
    let p = product(c, d)
    return (-p.head).addingProduct(a, b) - p.tail
  }
}
