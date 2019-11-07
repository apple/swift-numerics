//===--- Functions.swift --------------------------------------*- swift -*-===//
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

import Real

extension Complex: ElementaryFunctions {
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
    guard expIsSafe(z.x) else { return expNearOverflow(z) }
    return Complex(.cos(z.y), .sin(z.y)).multiplied(by: .exp(z.x))
  }
  
  // exp(x + iy) - 1 = (exp(x) cos(y) - 1) + i exp(x) sin(y)
  //                   -------- u --------
  // Note that the imaginary part is just the usual exp(x) sin(y);
  // the only trick is computing the real part ("u"):
  //
  // u = exp(x) cos(y) - 1
  //   = exp(x)(cos(y) - 1) + expm1(x)
  //
  // This reduces the problem to computing cos(y) - 1 accurately, which
  // we can do as -2*sin(y/2)^2.
  @inlinable
  public static func expMinusOne(_ z: Complex) -> Complex {
    // If exp(z) is close to the overflow boundary, we don't need to
    // worry about the m1 part; we're just computing exp(z).
    guard expIsSafe(z.x) else { return expNearOverflow(z) }
    let expm1x = RealType.expMinusOne(z.x)
    let expx = 1 + expm1x
    let sinyo2 = RealType.sin(z.y/2)
    let cosm1y = -2*sinyo2*sinyo2
    return Complex(expx*cosm1y + expm1x, expx * .sin(z.y))
  }
  
  // cosh(x + iy) = cosh(x) cos(y) + i sinh(x) sin(y)
  public static func cosh(_ z: Complex) -> Complex {
    fatalError()
  }
  
  // sinh(x + iy) = sinh(x)
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
    let mag = z.magnitude
    if mag.isFinite { return Complex(.log(mag), z.phase) }
    guard z.isFinite else { return z }
    // We're in the tiny range where z is finite but z.magnitude
    // overflows. Scale down, compute the log, add scale factor.
    let scale: RealType = .maximum(abs(z.x), abs(z.y))
    let w = z.divided(by: scale)
    return Complex(.log(scale) + .log(w.unsafeLengthSquared)/2, z.phase)
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
    return exp(log(z).multiplied(by: RealType(n)))
  }
  
  public static func sqrt(_ z: Complex) -> Complex {
    let lengthSquared = z.unsafeLengthSquared
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
    return exp(log(z).divided(by: RealType(n)))
  }
}
