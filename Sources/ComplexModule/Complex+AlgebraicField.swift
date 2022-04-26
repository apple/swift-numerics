//===--- Complex+AlgebraicField.swift -------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2021 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import RealModule

extension Complex: AlgebraicField {
  /// The multiplicative identity `1 + 0i`.
  @_transparent
  public static var one: Complex {
    Complex(1, 0)
  }
  
  /// The [complex conjugate][conj] of this value.
  ///
  /// [conj]: https://en.wikipedia.org/wiki/Complex_conjugate
  @_transparent
  public var conjugate: Complex {
    Complex(x, -y)
  }
  
  @_transparent
  public static func /(z: Complex, w: Complex) -> Complex {
    // Try the naive expression z/w = z*conj(w) / |w|^2; if we can compute
    // this without over/underflow, everything is fine and the result is
    // correct. If not, we have to rescale and do the computation carefully.
    let lenSq = w.lengthSquared
    guard lenSq.isNormal else { return rescaledDivide(z, w) }
    return z * (w.conjugate.divided(by: lenSq))
  }
  
  @_transparent
  public static func /=(z: inout Complex, w: Complex) {
    z = z / w
  }
  
  @usableFromInline @_alwaysEmitIntoClient @inline(never)
  internal static func rescaledDivide(_ z: Complex, _ w: Complex) -> Complex {
    if w.isZero { return .infinity }
    if z.isZero || !w.isFinite { return .zero }
    // TODO: detect when RealType is Float and just promote to Double, then
    // use the naive algorithm.
    let zScale = z.magnitude
    let wScale = w.magnitude
    let zNorm = z.divided(by: zScale)
    let wNorm = w.divided(by: wScale)
    let r = (zNorm * wNorm.conjugate).divided(by: wNorm.lengthSquared)
    // At this point, the result is (r * zScale)/wScale computed without
    // undue overflow or underflow. We know that r is close to unity, so
    // the question is simply what order in which to do this computation
    // to avoid spurious overflow or underflow. There are three options
    // to choose from:
    //
    // - r * (zScale / wScale)
    // - (r * zScale) / wScale
    // - (r / wScale) * zScale
    //
    // The simplest case is when zScale / wScale is normal:
    if (zScale / wScale).isNormal {
      return r.multiplied(by: zScale / wScale)
    }
    // Otherwise, we need to compute either rNorm * zScale or rNorm / wScale
    // first. Choose the first if the first scaling behaves well, otherwise
    // choose the other one.
    if (r.magnitude * zScale).isNormal {
      return r.multiplied(by: zScale).divided(by: wScale)
    }
    return r.divided(by: wScale).multiplied(by: zScale)
  }
  
  /// A normalized complex number with the same phase as this value.
  ///
  /// If such a value cannot be produced (because the phase of zero and
  /// infinity is undefined), `nil` is returned.
  @inlinable
  public var normalized: Complex? {
    if length.isNormal {
      return self.divided(by: length)
    }
    if isZero || !isFinite {
      return nil
    }
    return self.divided(by: magnitude).normalized
  }
  
  /// The reciprocal of this value, if it can be computed without undue
  /// overflow or underflow.
  ///
  /// If z.reciprocal is non-nil, you can safely replace division by z with
  /// multiplication by this value. It is not advantageous to do this for an
  /// isolated division, but if you are dividing many values by a single
  /// denominator, this will often be a significant performance win.
  ///
  /// A typical use case looks something like this:
  /// ```
  /// func divide<T: Real>(data: [Complex<T>], by divisor: Complex<T>) -> [Complex<T>] {
  ///   // If divisor is well-scaled, multiply by reciprocal.
  ///   if let recip = divisor.reciprocal {
  ///     return data.map { $0 * recip }
  ///   }
  ///   // Fallback on using division.
  ///   return data.map { $0 / divisor }
  /// }
  /// ```
  ///
  /// Error Bounds:
  ///
  /// Unlike real types, when working with complex types, multiplying by the
  /// reciprocal instead of dividing cannot change the result. If the
  /// reciprocal is non-nil, the two computations are always equivalent.
  @inlinable
  public var reciprocal: Complex? {
    let recip = 1/self
    if recip.isNormal || isZero || !isFinite {
      return recip
    }
    return nil
  }
}
