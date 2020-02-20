//===--- Float80+Real.swift -----------------------------------*- swift -*-===//
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

// Restrict extension to platforms for which Float80 exists.
#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
extension Float80: Real {
  @_transparent
  public static func cos(_ x: Float80) -> Float80 {
    libm_cosl(x)
  }
  
  @_transparent
  public static func sin(_ x: Float80) -> Float80 {
    libm_sinl(x)
  }
  
  @_transparent
  public static func tan(_ x: Float80) -> Float80 {
    libm_tanl(x)
  }
  
  @_transparent
  public static func acos(_ x: Float80) -> Float80 {
    libm_acosl(x)
  }
  
  @_transparent
  public static func asin(_ x: Float80) -> Float80 {
    libm_asinl(x)
  }
  
  @_transparent
  public static func atan(_ x: Float80) -> Float80 {
    libm_atanl(x)
  }
  
  @_transparent
  public static func cosh(_ x: Float80) -> Float80 {
    libm_coshl(x)
  }
  
  @_transparent
  public static func sinh(_ x: Float80) -> Float80 {
    libm_sinhl(x)
  }
  
  @_transparent
  public static func tanh(_ x: Float80) -> Float80 {
    libm_tanhl(x)
  }
  
  @_transparent
  public static func acosh(_ x: Float80) -> Float80 {
    libm_acoshl(x)
  }
  
  @_transparent
  public static func asinh(_ x: Float80) -> Float80 {
    libm_asinhl(x)
  }
  
  @_transparent
  public static func atanh(_ x: Float80) -> Float80 {
    libm_atanhl(x)
  }
  
  @_transparent
  public static func exp(_ x: Float80) -> Float80 {
    libm_expl(x)
  }
  
  @_transparent
  public static func expMinusOne(_ x: Float80) -> Float80 {
    libm_expm1l(x)
  }
  
  @_transparent
  public static func log(_ x: Float80) -> Float80 {
    libm_logl(x)
  }
  
  @_transparent
  public static func log(onePlus x: Float80) -> Float80 {
    libm_log1pl(x)
  }
  
  @_transparent
  public static func erf(_ x: Float80) -> Float80 {
    libm_erfl(x)
  }
  
  @_transparent
  public static func erfc(_ x: Float80) -> Float80 {
    libm_erfcl(x)
  }
  
  @_transparent
  public static func exp2(_ x: Float80) -> Float80 {
    libm_exp2l(x)
  }
  
  @_transparent
  public static func hypot(_ x: Float80, _ y: Float80) -> Float80 {
    libm_hypotl(x, y)
  }
  
  @_transparent
  public static func gamma(_ x: Float80) -> Float80 {
    libm_tgammal(x)
  }
  
  @_transparent
  public static func log2(_ x: Float80) -> Float80 {
    libm_log2l(x)
  }
  
  @_transparent
  public static func log10(_ x: Float80) -> Float80 {
    libm_log10l(x)
  }
  
  @_transparent
  public static func pow(_ x: Float80, _ y: Float80) -> Float80 {
    guard x >= 0 else { return .nan }
    return libm_powl(x, y)
  }
  
  @_transparent
  public static func pow(_ x: Float80, _ n: Int) -> Float80 {
    // Every Int value is exactly representable as Float80, so we don't need
    // to do anything fancy--unlike Float and Double, we can just call the
    // libm pow function.
    libm_powl(x, Float80(n))
  }
  
  @_transparent
  public static func root(_ x: Float80, _ n: Int) -> Float80 {
    guard x >= 0 || n % 2 != 0 else { return .nan }
    // Workaround the issue mentioned below for the specific case of n = 3
    // where we can fallback on cbrt.
    if n == 3 { return libm_cbrtl(x) }
    // TODO: this implementation is not quite correct, because either n or
    // 1/n may be not be representable as Float80.
    return Float80(signOf: x, magnitudeOf: libm_powl(x.magnitude, 1/Float80(n)))
  }
  
  @_transparent
  public static func atan2(y: Float80, x: Float80) -> Float80 {
    libm_atan2l(y, x)
  }
  
  @_transparent
  public static func logGamma(_ x: Float80) -> Float80 {
    var dontCare: Int32 = 0
    return libm_lgammal(x, &dontCare)
  }
}
#endif
