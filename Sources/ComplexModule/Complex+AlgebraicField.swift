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
  public static func /=(z: inout Complex, w: Complex) {
    z = z / w
  }
  
  @_transparent
  public static func /(z: Complex, w: Complex) -> Complex {
    // Try the naive expression z/w = z * (conj(w) / |w|^2); if we can
    // compute this without over/underflow, everything is fine and the
    // result is correct. If not, we have to rescale and do the
    // computation carefully (see below).
    let lenSq = w.lengthSquared
    guard lenSq.isNormal else { return rescaledDivide(z, w) }
    return z * (w.conjugate.divided(by: lenSq))
  }
  
  @inline(never)
  @_specialize(exported: true, where RealType == Float)
  @_specialize(exported: true, where RealType == Double)
  @usableFromInline
  internal static func rescaledDivide(_ z: Complex, _ w: Complex) -> Complex {
    if w.isZero { return .infinity }
    if !w.isFinite { return .zero }
    // Scaling algorithm adapted from Doug Priest's "Efficient Scaling for
    // Complex Division":
    //
    // 1. Choose real scale s ≅ |w|^(-¾), an exact power of the radix.
    // 2. wʹ ← sw
    // 3. zʹ ← sz
    // 4. return zʹ * (wʹ.conjugate / wʹ.lengthSquared)
    //
    // Why is this safe and accurate? First, observe that wʹ and zʹ are both
    // computed exactly because:
    //
    // - s is an exact power of radix.
    // - wʹ ~ |w|^(¼), and hence cannot overflow or underflow.
    // - zʹ can overflow or underflow, but only if the final result also
    //      overflows or underflows (this is more subtle than it might
    //      appear at first; Priest has to be very careful about it
    //      because you get into trouble precisely in the case where
    //      |w| is very close to 1. However, if we were in that case, we would
    //      have just handled the division inline and never would have ended
    //      up here.
    //
    // Next observe that |wʹ.lengthSquared| ~ |w|^(½), so again this cannot
    // overflow or underflow, and neither can
    // (wʹ.conjugate / wʹ.lengthSquared)
    
    
    // are of comparable
    // magnitude, and in particular the exponents of their magnitudes have the
    // same sign, so either both are a contraction or both are an expansion,
    // so any intermediate overflow or underflow is deserved.²
    //
    // Note that because the scale factor is always a power of the radix,
    // the rescaling does not affect rounding, and so this algorithm is scale-
    // invariant compared to the mainline `/` implementation, up to the
    // underflow boundary.
    //
    // ¹ This falls apart for formats where the number of significand bits is
    // comparable to the exponent range (in particular Float16), because then
    // the desired s is not representable. E.g. if w ~ .leastNonzeroMagnitude
    // in Float16 (0x1p-24), we want to have s = 0x1p18, which is outside the
    // range of representable values. This does not occur for any other types,
    // so we just carry a special-case implementation for Float16 to fix it.
    //
    // Priest never had to worry about this because Float16 didn't really exist
    // yet when he published and he was interested in double anyway.
    //
    // ² This WOULD NOT BE TRUE if we hadn't already handled well-scaled
    // divisors in the mainline path for the `/` operator above; it only
    // holds for sufficiently badly-scaled `w`. If the well-scaled cases
    // were not already eliminated, it would be possible to have |wʹ| a
    // little bigger than one and |wʺ| a bit smaller than one (or vice-versa), so
    // that intermediate undeserved overflow or underflow might occur. Priest
    // has to worry about this, but we do not.
    if w.magnitude < RealType.leastNormalMagnitude {
      let z = z.divided(by: RealType.leastNormalMagnitude)
      let w = w.divided(by: RealType.leastNormalMagnitude)
      return rescaledDivide(z, w)
    }
    var exponent = -3 * w.magnitude.exponent / 4
    let s = RealType(
      sign: .plus,
      exponent: exponent,
      significand: 1
    )
    let wʹ = w.multiplied(by: s)
    let zʹ = z.multiplied(by: s)
    return zʹ / wʹ
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
  
  @_transparent
  public static func _relaxedAdd(_ a: Self, _ b: Self) -> Self {
    Complex(Relaxed.sum(a.x, b.x), Relaxed.sum(a.y, b.y))
  }
  
  @_transparent
  public static func _relaxedMul(_ a: Self, _ b: Self) -> Self {
    Complex(
      Relaxed.sum(Relaxed.product(a.x, b.x), -Relaxed.product(a.y, b.y)),
      Relaxed.sum(Relaxed.product(a.x, b.y),  Relaxed.product(a.y, b.x))
    )
  }
}
