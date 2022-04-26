//===--- Quaternion+AlgebraicField.swift ----------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2022 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import RealModule

extension Quaternion: AlgebraicField {
  /// The multiplicative identity, with real part one and *all* imaginary parts
  /// zero, i.e.: `1 + 0i + 0j + 0k`
  ///
  /// See also: `zero`, `i`, `j`, `k`, `infinity`
  @_transparent
  public static var one: Quaternion {
    Quaternion(from: SIMD4(0,0,0,1))
  }

  /// The [conjugate][conj] of this value.
  ///
  /// [conj]: https://en.wikipedia.org/wiki/Quaternion#Conjugation,_the_norm,_and_reciprocal
  @_transparent
  public var conjugate: Quaternion {
    Quaternion(from: components * [-1, -1, -1, 1])
  }

  @_transparent
  public static func / (lhs: Quaternion, rhs: Quaternion) -> Quaternion {
    // Try the naive expression lhs/rhs = lhs*conj(rhs) / |rhs|^2; if we can compute
    // this without over/underflow, everything is fine and the result is
    // correct. If not, we have to rescale and do the computation carefully.
    let lengthSquared = rhs.lengthSquared
    guard lengthSquared.isNormal else { return rescaledDivide(lhs, rhs) }
    return lhs * (rhs.conjugate.divided(by: lengthSquared))
  }

  @_transparent
  public static func /= (lhs: inout Quaternion, rhs: Quaternion) {
    lhs = lhs / rhs
  }

  @usableFromInline @_alwaysEmitIntoClient @inline(never)
  internal static func rescaledDivide(_ lhs: Quaternion, _ rhs: Quaternion) -> Quaternion {
    if rhs.isZero { return .infinity }
    if lhs.isZero || !rhs.isFinite { return .zero }
    // TODO: detect when RealType is Float and just promote to Double, then
    // use the naive algorithm.
    let lhsScale = lhs.magnitude
    let rhsScale = rhs.magnitude
    let lhsNorm = lhs.divided(by: lhsScale)
    let rhsNorm = rhs.divided(by: rhsScale)
    let r = (lhsNorm * rhsNorm.conjugate).divided(by: rhsNorm.lengthSquared)
    // At this point, the result is (r * lhsScale)/rhsScale computed without
    // undue overflow or underflow. We know that r is close to unity, so
    // the question is simply what order in which to do this computation
    // to avoid spurious overflow or underflow. There are three options
    // to choose from:
    //
    // - r * (lhsScale / rhsScale)
    // - (r * lhsScale) / rhsScale
    // - (r / rhsScale) * lhsScale
    //
    // The simplest case is when lhsScale / rhsScale is normal:
    if (lhsScale / rhsScale).isNormal {
      return r.multiplied(by: lhsScale / rhsScale)
    }
    // Otherwise, we need to compute either rNorm * lhsScale or rNorm / rhsScale
    // first. Choose the first if the first scaling behaves well, otherwise
    // choose the other one.
    if (r.magnitude * lhsScale).isNormal {
      return r.multiplied(by: lhsScale).divided(by: rhsScale)
    }
    return r.divided(by: rhsScale).multiplied(by: lhsScale)
  }

  /// A normalized quaternion with the same direction and phase as this value.
  ///
  /// If such a value cannot be produced, `nil` is returned.
  @inlinable
  public var normalized: Quaternion? {
    if length.isNormal {
      return divided(by: length)
    }
    if isZero || !isFinite {
      return nil
    }
    return divided(by: magnitude).normalized
  }

  /// The reciprocal of this value, if it can be computed without undue overflow or underflow.
  ///
  /// If z.reciprocal is non-nil, you can safely replace division by z with multiplication by this
  /// value. It is not advantageous to do this for an isolated division, but if you are dividing
  /// many values by a single denominator, this will often be a significant performance win.
  ///
  /// Typical use looks like this:
  /// ```
  /// func divide<T: Real>(data: [Quaternion<T>], by divisor: Quaternion<T>) -> [Quaternion<T>] {
  ///   // If divisor is well-scaled, use multiply by reciprocal.
  ///   if let recip = divisor.reciprocal {
  ///     return data.map { $0 * recip }
  ///   }
  ///   // Fallback on using division.
  ///   return data.map { $0 / divisor }
  /// }
  /// ```
  @inlinable
  public var reciprocal: Quaternion? {
    let recip = Quaternion(1)/self
    if recip.isNormal || isZero || !isFinite {
      return recip
    }
    return nil
  }
}
