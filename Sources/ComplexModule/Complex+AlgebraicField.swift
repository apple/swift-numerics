//===--- Complex+AlgebraicField.swift -------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2025 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import RealModule

extension Complex: AlgebraicField {
  /// The multiplicative identity `1 + 0i`.
  ///
  /// See also: ``zero``, ``i``, ``infinity``
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
    return z * w.conjugate.divided(by: lenSq)
  }
  
  @usableFromInline @_alwaysEmitIntoClient @inline(never)
  internal static func rescaledDivide(_ z: Complex, _ w: Complex) -> Complex {
    if w.isZero { return .infinity }
    if !w.isFinite { return .zero }
    //  Scaling algorithm adapted from Doug Priest's "Efficient Scaling for
    //  Complex Division":
    if w.magnitude < .leastNormalMagnitude {
      //  A difference from Priest's algorithm is that he didn't have to worry
      //  about types like Float16, where the significand width is comparable
      //  to the exponent range, such that |leastNormalMagnitude|^(-¾) isn't
      //  representable (e.g. for Float16 it would want to be 2¹⁸, but the
      //  largest allowed exponent is 15). Note that it's critical to use zʹ/wʹ
      //  after rescaling to avoid this, rather than falling through into the
      //  normal rescaling, because otherwise we might end up back in the
      //  situation where |w| ~ 1.
      let s = 1/(RealType(RealType.radix) * .leastNormalMagnitude)
      let wʹ = w.multiplied(by: s)
      let zʹ = z.multiplied(by: s)
      return zʹ / wʹ
    }
    //  Having handled that case, we proceed pretty similarly to Priest:
    //
    //  1. Choose real scale s ~ |w|^(-¾), an exact power of the radix.
    //  2. wʹ ← sw
    //  3. zʹ ← sz
    //  4. return zʹ * (wʹ.conjugate / wʹ.lengthSquared) (i.e. zʹ/wʹ).
    //
    //  Why is this safe and accurate? First, observe that wʹ and zʹ are both
    //  computed exactly because:
    //
    //  - s is an exact power of radix.
    //  - wʹ ~ |w|^(¼), and hence cannot overflow or underflow.
    //  - zʹ might overflow or underflow, but only if the final result also
    //       overflows or underflows. (This is more subtle than I make it
    //       sound. In particular, most of the fast ways one might try to
    //       compute s give rise to a situation where when |w| is close to
    //       one, multiplication by s is a dilation even though the actual
    //       division is a contraction or vice-versa, and thus intermediate
    //       computations might incorrectly overflow or underflow. Priest
    //       had to take some care to avoid this situation, but we do not,
    //       because we have already ruled out |w| ~ 1 before we call this
    //       function.)
    //
    //  Next observe that |wʹ.lengthSquared| ~ |w|^(½), so again this cannot
    //  overflow or underflow, and neither can (wʹ.conjugate/wʹ.lengthSquared),
    //  which has magnitude like |w|^(-¼).
    //
    //  Note that because the scale factor is always a power of the radix,
    //  the rescaling does not affect rounding, and so this algorithm is scale-
    //  invariant compared to the mainline `/` implementation, up to the
    //  underflow boundary.
    //
    //  Note that our final assembly of the result is different from Priest;
    //  he applies s to w twice, instead of once to w and once to z, and
    //  does the product as (zw̅ʺ)*(1/|wʹ|²), while we do zʹ(w̅ʹ/|wʹ|²). We
    //  prefer our version for three reasons:
    //
    //  1. it extracts a little more ILP
    //  2. it makes it so that we get exactly the same roundings on the
    //     rescaled divide path as on the fast path, so that z/w = tz/tw
    //     when tz and tw are computed exactly.
    //  3. it unlocks a future optimization where we hoist s and
    //     (w̅ʹ/|wʹ|²) and make divisions all fast-path without perturbing
    //     rounding.
    let s = RealType(
      sign: .plus,
      exponent: -3*w.magnitude.exponent/4,
      significand: 1
    )
    let wʹ = w.multiplied(by: s)
    let zʹ = z.multiplied(by: s)
    return zʹ * wʹ.conjugate.divided(by: wʹ.lengthSquared)
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
