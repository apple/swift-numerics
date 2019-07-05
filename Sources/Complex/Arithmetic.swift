//===--- Arithmetic.swift -------------------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

// MARK: - Additive structure
extension Complex: AdditiveArithmetic {
  @_transparent
  public static func +(z: Complex, w: Complex) -> Complex {
    return Complex(z.x + w.x, z.y + w.y)
  }
  
  @_transparent
  public static func -(z: Complex, w: Complex) -> Complex {
    return Complex(z.x - w.x, z.y - w.y)
  }
  
  @_transparent
  public static func +=(z: inout Complex, w: Complex) {
    z = z + w
  }
  
  @_transparent
  public static func -=(z: inout Complex, w: Complex) {
    z = z - w
  }
}

// MARK: - Vector space structure
//
// Policy: deliberately not using the * and / operators for these at the
// moment, because then there's an ambiguity in expressions like 2*z; is
// that Complex(2) * z or is it RealType(2) * z? This is especially
// problematic in type inference: suppose we have:
//
//   let a: RealType = 1
//   let b = 2*a
//
// what is the type of b? If we don't have a type context, it's ambiguous.
// If we have a Complex type context, then b will be inferred to have type
// Complex! Obviously, that doesn't help anyone.
//
// TODO: figure out if there's some way to avoid these surprising results
// and turn these into operators if/when we have it.
// (https://github.com/apple/swift-numerics/issues/12)
extension Complex {
  @inline(__always) @usableFromInline
  internal func multiplied(by a: RealType) -> Complex {
    Complex(x*a, y*a)
  }
  
  @inline(__always) @usableFromInline
  internal func divided(by a: RealType) -> Complex {
    Complex(x/a, y/a)
  }
}

// MARK: - Multiplicative structure
extension Complex: Numeric {
  @inlinable
  public static func *(z: Complex, w: Complex) -> Complex {
    return Complex(z.x*w.x - z.y*w.y, z.x*w.y + z.y*w.x)
  }
  
  @inlinable
  public static func /(z: Complex, w: Complex) -> Complex {
    // Try the naive expression z/w = z*conj(w) / |w|^2; if the result is
    // normal, then everything was fine, and we can simply return the result.
    let naive = z * w.conjugate.divided(by: w.unsafeMagnitudeSquared)
    guard naive.isNormal else { return carefulDivide(z, w) }
    return naive
  }
  
  @inlinable
  public static func *=(z: inout Complex, w: Complex) {
    z = z * w
  }
  
  @inlinable
  public static func /=(z: inout Complex, w: Complex) {
    z = z / w
  }
  
  @usableFromInline
  internal static func carefulDivide(_ z: Complex, _ w: Complex) -> Complex {
    if z.isZero || !w.isFinite { return .zero }
    let zScale = max(abs(z.x), abs(z.y))
    let wScale = max(abs(w.x), abs(w.y))
    let zNorm = z.divided(by: zScale)
    let wNorm = w.divided(by: wScale)
    let r = (zNorm * wNorm.conjugate).divided(by: wNorm.unsafeMagnitudeSquared)
    let rScale = max(abs(r.x), abs(r.y))
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
    if (rScale * zScale).isNormal {
      return r.multiplied(by: zScale).divided(by: wScale)
    }
    return r.divided(by: wScale).multiplied(by: zScale)
  }
  
  /// A normalized complex number with the same phase as this value.
  ///
  /// If such a value cannot be produced (because the phase of zero and infinity is undefined),
  /// `nil` is returned.
  public var normalized: Complex? {
    let norm = magnitude
    if magnitude.isNormal {
      return self.divided(by: norm)
    }
    if isZero || !isFinite {
      return nil
    }
    let scale = RealType.maximumMagnitude(abs(x), abs(y))
    return self.divided(by: scale).normalized
  }
}
