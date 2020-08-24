//===--- Double+Real.swift ------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import _NumericsShims

extension Double: Real {
  @_transparent
  public static func cos(_ x: Double) -> Double {
    libm_cos(x)
  }
  
  @_transparent
  public static func sin(_ x: Double) -> Double {
    libm_sin(x)
  }
  
  @_transparent
  public static func tan(_ x: Double) -> Double {
    libm_tan(x)
  }
  
  @_transparent
  public static func acos(_ x: Double) -> Double {
    libm_acos(x)
  }
  
  @_transparent
  public static func asin(_ x: Double) -> Double {
    libm_asin(x)
  }
  
  @_transparent
  public static func atan(_ x: Double) -> Double {
    libm_atan(x)
  }
  
  @_transparent
  public static func cosh(_ x: Double) -> Double {
    libm_cosh(x)
  }
  
  @_transparent
  public static func sinh(_ x: Double) -> Double {
    libm_sinh(x)
  }
  
  @_transparent
  public static func tanh(_ x: Double) -> Double {
    libm_tanh(x)
  }
  
  @_transparent
  public static func acosh(_ x: Double) -> Double {
    libm_acosh(x)
  }
  
  @_transparent
  public static func asinh(_ x: Double) -> Double {
    libm_asinh(x)
  }
  
  @_transparent
  public static func atanh(_ x: Double) -> Double {
    libm_atanh(x)
  }
  
  @_transparent
  public static func exp(_ x: Double) -> Double {
    libm_exp(x)
  }
  
  @_transparent
  public static func expMinusOne(_ x: Double) -> Double {
    libm_expm1(x)
  }
  
  @_transparent
  public static func log(_ x: Double) -> Double {
    libm_log(x)
  }
  
  @_transparent
  public static func log(onePlus x: Double) -> Double {
    libm_log1p(x)
  }
  
  @_transparent
  public static func erf(_ x: Double) -> Double {
    libm_erf(x)
  }
  
  @_transparent
  public static func erfc(_ x: Double) -> Double {
    libm_erfc(x)
  }
  
  @_transparent
  public static func exp2(_ x: Double) -> Double {
    libm_exp2(x)
  }
  
  #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  @_transparent
  public static func exp10(_ x: Double) -> Double {
    libm_exp10(x)
  }
  #endif
  
  #if os(macOS) && arch(x86_64)
  // Workaround for macOS bug (<rdar://problem/56844150>) where hypot can
  // overflow for values very close to the overflow boundary of the naive
  // algorithm. Since this is only for macOS, we can just unconditionally
  // use Float80, which makes the implementation trivial.
  public static func hypot(_ x: Double, _ y: Double) -> Double {
    if x.isInfinite || y.isInfinite { return .infinity }
    let x80 = Float80(x)
    let y80 = Float80(y)
    return Double(Float80.sqrt(x80*x80 + y80*y80))
  }
  #else
  @_transparent
  public static func hypot(_ x: Double, _ y: Double) -> Double {
    libm_hypot(x, y)
  }
  #endif
  
  @_transparent
  public static func gamma(_ x: Double) -> Double {
    libm_tgamma(x)
  }
  
  @_transparent
  public static func log2(_ x: Double) -> Double {
    libm_log2(x)
  }
  
  @_transparent
  public static func log10(_ x: Double) -> Double {
    libm_log10(x)
  }
  
  @_transparent
  public static func pow(_ x: Double, _ y: Double) -> Double {
    guard x >= 0 else { return .nan }
    return libm_pow(x, y)
  }
  
  @_transparent
  public static func pow(_ x: Double, _ n: Int) -> Double {
    // If n is exactly representable as Double, we can just call pow:
    // Note that all calls on a 32b platform go down this path.
    if let y = Double(exactly: n) { return libm_pow(x, y) }
    // n is not representable in Double, so we will split it into two parts,
    // low and high, such that (high + low) = n, and use the identity:
    //
    //   x**(high + low) = x**high * x**low.
    //
    // We put the high-order 32 bits into high, and the remaining 32 bits
    // in low.
    //
    // The exact split isn't important; all we need is that both pieces get
    // less than 53 bits (so that they are exact) and that they both have
    // the same sign as n.
    //
    // This second point is a little bit subtle--why is
    // it necessary? Consider what would happen if we took x = 2 and
    // n = Int.min + Int(UInt32.max), and simply naively split n without
    // taking care with the sign. We would end up computing:
    //
    //   2**n = 2**Int.min * 2**UInt32.max
    //
    // The first exponent is negative, the second positive, so the first term
    // underflows to zero, and the second overflows to infinity, so the final
    // result is NaN, when it should be zero. In order to avoid this
    // situation, we make sure that high contains n rounded *towards zero*,
    // rather than using simple two's-complement truncation (which rounds
    // down).
    let mask = Int(truncatingIfNeeded: UInt32.max)
    let round = n < 0 ? mask : 0
    // The addition and subtraction below cannot actually overflow (proof:
    // round is positive if n is negative, and zero otherwise, so n + round
    // is guaranteed to be representable, and n and high have the same sign,
    // so n - high is also representable), but it's hard to tell the compiler
    // that, so I'm using wrapping operations instead.
    let high = (n &+ round) & ~mask
    let low = n &- high
    return libm_pow(x, Double(low)) * libm_pow(x, Double(high))
  }
  
  @_transparent
  public static func root(_ x: Double, _ n: Int) -> Double {
    guard x >= 0 || n % 2 != 0 else { return .nan }
    // Workaround the issue mentioned below for the specific case of n = 3
    // where we can fallback on cbrt.
    if n == 3 { return libm_cbrt(x) }
    // TODO: this implementation is not quite correct, because either n or
    // 1/n may be not be representable as Double.
    return Double(signOf: x, magnitudeOf: libm_pow(x.magnitude, 1/Double(n)))
  }
  
  @_transparent
  public static func atan2(y: Double, x: Double) -> Double {
    libm_atan2(y, x)
  }
  
  #if !os(Windows)
  @_transparent
  public static func logGamma(_ x: Double) -> Double {
    var dontCare: Int32 = 0
    return libm_lgamma(x, &dontCare)
  }
  #endif
  
  @_transparent
  public static func _mulAdd(_ a: Double, _ b: Double, _ c: Double) -> Double {
    _numerics_muladd(a, b, c)
  }
}
