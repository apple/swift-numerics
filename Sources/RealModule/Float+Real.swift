//===--- Float+Real.swift -------------------------------------*- swift -*-===//
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

extension Float: Real {
  @_transparent
  public static func cos(_ x: Float) -> Float {
    libm_cosf(x)
  }
  
  @_transparent
  public static func sin(_ x: Float) -> Float {
    libm_sinf(x)
  }
  
  @_transparent
  public static func tan(_ x: Float) -> Float {
    libm_tanf(x)
  }
  
  @_transparent
  public static func acos(_ x: Float) -> Float {
    libm_acosf(x)
  }
  
  @_transparent
  public static func asin(_ x: Float) -> Float {
    libm_asinf(x)
  }
  
  @_transparent
  public static func atan(_ x: Float) -> Float {
    libm_atanf(x)
  }
  
  @_transparent
  public static func cosh(_ x: Float) -> Float {
    libm_coshf(x)
  }
  
  @_transparent
  public static func sinh(_ x: Float) -> Float {
    libm_sinhf(x)
  }
  
  @_transparent
  public static func tanh(_ x: Float) -> Float {
    libm_tanhf(x)
  }
  
  @_transparent
  public static func acosh(_ x: Float) -> Float {
    libm_acoshf(x)
  }
  
  @_transparent
  public static func asinh(_ x: Float) -> Float {
    libm_asinhf(x)
  }
  
  @_transparent
  public static func atanh(_ x: Float) -> Float {
    libm_atanhf(x)
  }
  
  @_transparent
  public static func exp(_ x: Float) -> Float {
    libm_expf(x)
  }
  
  @_transparent
  public static func expMinusOne(_ x: Float) -> Float {
    libm_expm1f(x)
  }
  
  @_transparent
  public static func log(_ x: Float) -> Float {
    libm_logf(x)
  }
  
  @_transparent
  public static func log(onePlus x: Float) -> Float {
    libm_log1pf(x)
  }
  
  @_transparent
  public static func erf(_ x: Float) -> Float {
    libm_erff(x)
  }
  
  @_transparent
  public static func erfc(_ x: Float) -> Float {
    libm_erfcf(x)
  }
  
  @_transparent
  public static func exp2(_ x: Float) -> Float {
    libm_exp2f(x)
  }
  
  #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  @_transparent
  public static func exp10(_ x: Float) -> Float {
    libm_exp10f(x)
  }
  #endif
  
  @_transparent
  public static func hypot(_ x: Float, _ y: Float) -> Float {
    libm_hypotf(x, y)
  }
  
  @_transparent
  public static func gamma(_ x: Float) -> Float {
    libm_tgammaf(x)
  }
  
  @_transparent
  public static func log2(_ x: Float) -> Float {
    libm_log2f(x)
  }
  
  @_transparent
  public static func log10(_ x: Float) -> Float {
    libm_log10f(x)
  }
  
  @_transparent
  public static func pow(_ x: Float, _ y: Float) -> Float {
    guard x >= 0 else { return .nan }
    return libm_powf(x, y)
  }
  
  @_transparent
  public static func pow(_ x: Float, _ n: Int) -> Float {
    // If n is exactly representable as Float, we can just call powf:
    if let y = Float(exactly: n) {
      return libm_powf(x, y)
    }
    // Otherwise, n is too large to losslessly represent as Float.
    // The range of "interesting" n is -1488522191 ... 1744361944; outside
    // of this range, all x != 1 overflow or underflow, so only the parity
    // of x matters. We don't really care about the specific range at all,
    // only that the bounds fit exactly into two Floats.
    //
    // We do, however, need to be careful that high and low both have the
    // same sign as n (consult the Double implementation for details of why
    // this matters), so we need to be a little bit careful constructing
    // them.
    //
    // Unlike the Double implementation, when n is very large, high will
    // get rounded here; that's OK because it does not change the sign or
    // parity, which are the only two bits that matter for such large
    // exponents in Float.
    let mask = Int(truncatingIfNeeded: 0xffffff)
    let round = n < 0 ? mask : 0
    let high = (n &+ round) & ~mask
    let low = n &- high
    return libm_powf(x, Float(low)) * libm_powf(x, Float(high))
  }
  
  @_transparent
  public static func root(_ x: Float, _ n: Int) -> Float {
    guard x >= 0 || n % 2 != 0 else { return .nan }
    // Workaround the issue mentioned below for the specific case of n = 3
    // where we can fallback on cbrt.
    if n == 3 { return libm_cbrtf(x) }
    // TODO: this implementation is not quite correct, because either n or
    // 1/n may be not be representable as Float.
    return Float(signOf: x, magnitudeOf: libm_powf(x.magnitude, 1/Float(n)))
  }
  
  @_transparent
  public static func atan2(y: Float, x: Float) -> Float {
    libm_atan2f(y, x)
  }
  
  #if !os(Windows)
  @_transparent
  public static func logGamma(_ x: Float) -> Float {
    var dontCare: Int32 = 0
    return libm_lgammaf(x, &dontCare)
  }
  #endif
  
  @_transparent
  public static func _mulAdd(_ a: Float, _ b: Float, _ c: Float) -> Float {
    _numerics_muladdf(a, b, c)
  }
}
