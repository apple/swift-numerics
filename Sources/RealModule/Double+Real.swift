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
    // Otherwise, n is too large to losslessly represent as Double, so we
    // just split it into two parts, high and low. This is always exact,
    // so the only source of error is pow itself and the multiplication.
    //
    // mask constant is spelled in this funny way because if we just anded
    // with the hex value, we'd get a compile error on 32b platforms, even
    // though this whole branch is dead code on 32b.
    let mask = Int(truncatingIfNeeded: 0x1f_ffff_ffff_ffff as UInt64)
    let low = n & mask
    let high = n - low
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
}
