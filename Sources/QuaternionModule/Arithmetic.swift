//===--- Arithmetic.swift -------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import RealModule

// MARK: - Conformance to Additive Arithmetic
extension Quaternion: AdditiveArithmetic {
  @_transparent
  public static func + (lhs: Quaternion, rhs: Quaternion) -> Quaternion {
    Quaternion(real: lhs.w+rhs.w, imaginary: lhs.x+rhs.x, lhs.y+rhs.y, lhs.z+rhs.z)
  }

  @_transparent
  public static func - (lhs: Quaternion, rhs: Quaternion) -> Quaternion {
    Quaternion(real: lhs.w-rhs.w, imaginary: lhs.x-rhs.x, lhs.y-rhs.y, lhs.z-rhs.z)
  }

  @_transparent
  public static func += (lhs: inout Quaternion, rhs: Quaternion) {
    lhs = lhs + rhs
  }

  @_transparent
  public static func -= (lhs: inout Quaternion, rhs: Quaternion) {
    lhs = lhs - rhs
  }
}

// MARK: - Vector space structure
//
// See: https://github.com/apple/swift-numerics/issues/12
// While the issue addresses complex operations, this applies to quaternions as well.
extension Quaternion {
  @usableFromInline @_transparent
  internal func multiplied(by scalar: RealType) -> Quaternion {
    Quaternion(real: w*scalar, imaginary: x*scalar, y*scalar, z*scalar)
  }

  @usableFromInline @_transparent
  internal func divided(by scalar: RealType) -> Quaternion {
    Quaternion(real: w/scalar, imaginary: x/scalar, y/scalar, z/scalar)
  }
}

// MARK: - Multiplicative structure
extension Quaternion: AlgebraicField {
  @_transparent
  public static func * (lhs: Quaternion, rhs: Quaternion) -> Quaternion {
    // The following expressions have been split up so the type-check
    // can resolve them in a reasonable time.

    let xW = lhs.w * rhs.x
    let xX = lhs.x * rhs.w
    let xY = lhs.y * rhs.z
    let xZ = lhs.z * rhs.y
    let x = xW + xX + xY - xZ

    let yW = lhs.w * rhs.y
    let yX = lhs.x * rhs.z
    let yY = lhs.y * rhs.w
    let yZ = lhs.z * rhs.x
    let y = yW - yX + yY + yZ

    let zW = lhs.w * rhs.z
    let zX = lhs.x * rhs.y
    let zY = lhs.y * rhs.x
    let zZ = lhs.z * rhs.w
    let z = zW + zX - zY + zZ

    let wW = lhs.w * rhs.w
    let wX = lhs.x * rhs.x
    let wY = lhs.y * rhs.y
    let wZ = lhs.z * rhs.z
    let w = wW - wX - wY - wZ

    return Quaternion(real: w, imaginary: x, y, z)
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
  public static func *= (lhs: inout Quaternion, rhs: Quaternion) {
    lhs = lhs * rhs
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
    let recip = 1/self
    if recip.isNormal || isZero || !isFinite {
      return recip
    }
    return nil
  }
}

