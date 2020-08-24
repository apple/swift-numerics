//===--- ElementaryFunctions.swift ----------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2019-2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

// Implementation goals, in order of priority:
//
// 1. Get the branch cuts right. We should match Kahan's /Much Ado/
//    paper for finite values.
// 2. Have good relative accuracy in the complex norm.
// 3. Preserve sign symmetries where possible.
// 4. Handle the point at infinity consistently with basic operations.
//    This means diverging from what C and C++ do for non-finite inputs.
// 5. Get good componentwise accuracy /when possible/. I don't know how
//    to do that for all of these functions off the top of my head, and
//    I don't think that other libraries have tried to do so in general,
//    so this is a research project. We should not sacrifice 1-4 for it.
// 6. Give the best performance we can. We should care about performance,
//    but with lower precedence than the other considerations.

import RealModule

// TODO: uncomment conformance once all implementations are provided.
extension Complex /*: ElementaryFunctions */ {
  
  // MARK: - exp-like functions
  /// Checks if x is bounded away overflowing exp(x).
  ///
  /// This is a conservative (imprecise) check; if it returns `true`, `exp(x)` is definitely safe, but
  /// it will return `false` even in some cases where `exp(x)` would not overflow.
  @usableFromInline @inline(__always)
  internal static func expIsSafe(_ x: RealType) -> Bool {
    // If x < log(greatestFiniteMagnitude), then exp(x) does not overflow.
    // To protect ourselves against sketchy log or exp implementations in
    // an unknown host library, we round down to the nearest integer to get
    // some margin of safety.
    return x < RealType.log(.greatestFiniteMagnitude).rounded(.down)
  }
  
  /// Computes exp(z) with extra care near the overflow boundary.
  ///
  /// When x = z.real is large, exp(x) may overflow even when exp(z) is finite,
  /// because exp(z) = exp(x) * (cos(y) + i sin(y)), and max(cos(y),sin(y)) may
  /// be as small as 1/sqrt(2).
  ///
  /// - Parameter z: a complex number with large real part.
  @usableFromInline
  internal static func expNearOverflow(_ z: Complex) -> Complex {
    let xm1 = z.x - 1
    let y = z.y
    let r = Complex(.cos(y), .sin(y)).multiplied(by: .exp(1))
    return r.multiplied(by: .exp(xm1))
  }
  
  // exp(x + iy) = exp(x)(cos(y) + i sin(y))
  @inlinable
  public static func exp(_ z: Complex) -> Complex {
    // Naively we would let exp(-∞,0) fall out as 0, matching the real
    // type behavior, but that breaks the single-point-at-infinity
    // semantics, because exp has an essential singularity at infinity.
    guard z.x != -.infinity else { return .infinity }
    guard expIsSafe(z.x) else { return expNearOverflow(z) }
    return Complex(.cos(z.y), .sin(z.y)).multiplied(by: .exp(z.x))
  }
  
  // exp(x + iy) - 1 = (exp(x) cos(y) - 1) + i exp(x) sin(y)
  //                   -------- u --------
  // Note that the imaginary part is just the usual exp(x) sin(y);
  // the only trick is computing the real part ("u"):
  //
  // u = exp(x) cos(y) - 1
  //   = exp(x) cos(y) - cos(y) + cos(y) - 1
  //   = (exp(x) - 1) cos(y) + (cos(y) - 1)
  //   = expMinusOne(x) cos(y) + cosMinusOne(y)
  //
  // Note: most implementations of expm1 for complex (e.g. Julia's)
  // factor the real part as follows instead:
  //
  //     exp(x) cosMinuxOne(y) + expMinusOne(y)
  //
  // This expression gives good accuracy close to zero, but suffers from
  // catastrophic cancellation when z.x is large and z.y is near an odd
  // multiple of π/2. This is _OK_ (the componentwise error is bad, but
  // the error in a complex norm is acceptable), but we can do better by
  // factoring on cosine instead of exp.
  //
  // The other implementation that is sometimes seen, 2*exp(z/2)*sinh(z/2),
  // has the same weaknesses.
  //
  // The approach used here achieves good componentwise worst-case error
  // (7e-5 for Float) as well as normwise error (2.9e-7) in structured
  // and randomized tests. The alternative factorization achieves
  // comparable normwise error (3.9e-7), but dramatically worse
  // componentwise errors, e.g. Complex(18, -3π/2) produces (4.0, 6.57e7)
  // while the reference result would be (-0.22, 6.57e7).
  @inlinable
  public static func expMinusOne(_ z: Complex) -> Complex {
    // Naively we would let exp(-∞,0) fall out as 0, matching the real
    // type behavior, but that breaks the single-point-at-infinity
    // semantics, because exp has an essential singularity at infinity.
    guard z.x != -.infinity else { return .infinity }
    // If exp(z) is close to the overflow boundary, we don't need to
    // worry about the m1 part; we're just computing exp(z). (Even when
    // z.y is near a multiple of π/2, it can't be close enough to
    // overcome the scaling from exp(z.x), so the -1 term is _always_
    // negligable).
    guard expIsSafe(z.x) else { return expNearOverflow(z) }
    // Special cases out of the way, evaluate as discussed above.
    return Complex(
      RealType._mulAdd(.cos(z.y), .expMinusOne(z.x), .cosMinusOne(z.y)),
      .exp(z.x) * .sin(z.y)
    )
  }
  
  public static func cosh(_ z: Complex) -> Complex {
    fatalError()
  }
  
  public static func sinh(_ z: Complex) -> Complex {
    fatalError()
  }
  
  public static func tanh(_ z: Complex) -> Complex {
    fatalError()
  }
  
  // cos(z) = cosh(iz)
  public static func cos(_ z: Complex) -> Complex {
    return cosh(Complex(-z.y, z.x))
  }
  
  // sin(z) = -i*sinh(iz)
  public static func sin(_ z: Complex) -> Complex {
    let w = sinh(Complex(-z.y, z.x))
    return Complex(w.y, -w.x)
  }
  
  // tan(z) = -i*tanh(iz)
  public static func tan(_ z: Complex) -> Complex {
    let w = tanh(Complex(-z.y, z.x))
    return Complex(w.y, -w.x)
  }
  
  // MARK: - log-like functions
  public static func log(_ z: Complex) -> Complex {
    // If z is zero or infinite, the phase is undefined, so the result is
    // the single exceptional value.
    guard z.isFinite && !z.isZero else { return .infinity }
    // Otherwise, try computing lengthSquared; if the result is normal,
    // we can just take its log to get the real part of the result.
    let r2 = z.lengthSquared
    let θ = z.phase
    if r2.isNormal { return Complex(.log(r2)/2, θ) }
    // z is finite, but z.lengthSquared is not normal. Rescale and recompute.
    let w = z.divided(by: z.magnitude)
    return Complex(.log(z.magnitude) + .log(w.lengthSquared)/2, θ)
  }
  
  public static func log(onePlus z: Complex) -> Complex {
    fatalError()
  }
  
  public static func acos(_ z: Complex) -> Complex {
    fatalError()
  }
  
  // asin(z) = -i*asinh(iz)
  public static func asin(_ z: Complex) -> Complex {
    let w = asinh(Complex(-z.y, z.x))
    return Complex(w.y, -w.x)
  }
  
  // atan(z) = -i*atanh(iz)
  public static func atan(_ z: Complex) -> Complex {
    let w = atanh(Complex(-z.y, z.x))
    return Complex(w.y, -w.x)
  }
  
  public static func acosh(_ z: Complex) -> Complex {
    fatalError()
  }
  
  public static func asinh(_ z: Complex) -> Complex {
    fatalError()
  }
  
  public static func atanh(_ z: Complex) -> Complex {
    fatalError()
  }
  
  // MARK: - pow-like functions
  public static func pow(_ z: Complex, _ w: Complex) -> Complex {
    return exp(w * log(z))
  }
  
  public static func pow(_ z: Complex, _ n: Int) -> Complex {
    if z.isZero { return .zero }
    // TODO: this implementation is not quite correct, because n may be
    // rounded in conversion to RealType. This only effects very extreme
    // cases, so we'll leave it alone for now.
    //
    // Note that this does not have the same problems that a similar
    // implementation for a real type would have, because there's no
    // parity/sign interaction in the complex plane.
    return exp(log(z).multiplied(by: RealType(n)))
  }
  
  public static func sqrt(_ z: Complex) -> Complex {
    let lengthSquared = z.lengthSquared
    if lengthSquared.isNormal {
      // If |z|^2 doesn't overflow, then define u and v by:
      //
      //    u = sqrt((|z|+|x|)/2)
      //    v = y/2u
      //
      // If x is positive, the result is just w = (u, v). If x is negative,
      // the result is (|v|, copysign(u, y)) instead.
      let norm = RealType.sqrt(lengthSquared)
      let u = RealType.sqrt((norm + abs(z.x))/2)
      let v: RealType = z.y / (2*u)
      if z.x.sign == .plus {
        return Complex(u, v)
      } else {
        return Complex(abs(v), RealType(signOf: z.y, magnitudeOf: u))
      }
    }
    // Handle edge cases:
    if z.isZero { return Complex(0, z.y) }
    if !z.isFinite { return z }
    // z is finite but badly-scaled. Rescale and replay by factoring out
    // the larger of x and y.
    let scale = RealType.maximum(abs(z.x), abs(z.y))
    return Complex.sqrt(z.divided(by: scale)).multiplied(by: .sqrt(scale))
  }
  
  public static func root(_ z: Complex, _ n: Int) -> Complex {
    if z.isZero { return .zero }
    // TODO: this implementation is not quite correct, because n may be
    // rounded in conversion to RealType. This only effects very extreme
    // cases, so we'll leave it alone for now.
    //
    // Note that this does not have the same problems that a similar
    // implementation for a real type would have, because there's no
    // parity/sign interaction in the complex plane.
    return exp(log(z).divided(by: RealType(n)))
  }
}
