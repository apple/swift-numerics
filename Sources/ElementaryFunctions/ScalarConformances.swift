//===--- ScalarConformances.swift -----------------------------*- swift -*-===//
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

// In theory we might be able to get away with using @_silgen_name for these
// instead of NumericShims and remove a level of (source-only) indirection.
// However, at present if we do that we get a compiler crash when this module
// and the Swift platform module are both imported (<rdar://problem/53821031>).
import NumericsShims

extension Float: Real {
  @_transparent public static func cos(_ x: Float) -> Float { return libm_cosf(x) }
  @_transparent public static func sin(_ x: Float) -> Float { return libm_sinf(x) }
  @_transparent public static func tan(_ x: Float) -> Float { return libm_tanf(x) }
  @_transparent public static func acos(_ x: Float) -> Float { return libm_acosf(x) }
  @_transparent public static func asin(_ x: Float) -> Float { return libm_asinf(x) }
  @_transparent public static func atan(_ x: Float) -> Float { return libm_atanf(x) }
  @_transparent public static func cosh(_ x: Float) -> Float { return libm_coshf(x) }
  @_transparent public static func sinh(_ x: Float) -> Float { return libm_sinhf(x) }
  @_transparent public static func tanh(_ x: Float) -> Float { return libm_tanhf(x) }
  @_transparent public static func acosh(_ x: Float) -> Float { return libm_acoshf(x) }
  @_transparent public static func asinh(_ x: Float) -> Float { return libm_asinhf(x) }
  @_transparent public static func atanh(_ x: Float) -> Float { return libm_atanhf(x) }
  @_transparent public static func exp(_ x: Float) -> Float { return libm_expf(x) }
  @_transparent public static func expMinusOne(_ x: Float) -> Float  { return libm_expm1f(x) }
  @_transparent public static func log(_ x: Float) -> Float { return libm_logf(x) }
  @_transparent public static func log(onePlus x: Float) -> Float { return libm_log1pf(x) }
  @_transparent public static func erf(_ x: Float) -> Float { return libm_erff(x) }
  @_transparent public static func erfc(_ x: Float) -> Float { return libm_erfcf(x) }
  @_transparent public static func exp2(_ x: Float) -> Float { return libm_exp2f(x) }
  #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  @_transparent public static func exp10(_ x: Float) -> Float { return libm_exp10f(x) }
  #endif
  @_transparent public static func hypot(_ x: Float, _ y: Float) -> Float { return libm_hypotf(x, y) }
  @_transparent public static func gamma(_ x: Float) -> Float { return libm_tgammaf(x) }
  @_transparent public static func log2(_ x: Float) -> Float { return libm_log2f(x) }
  @_transparent public static func log10(_ x: Float) -> Float { return libm_log10f(x) }
  
  @_transparent public static func pow(_ x: Float, _ y: Float) -> Float {
    guard x >= 0 else { return .nan }
    return libm_powf(x, y)
  }
  
  @_transparent public static func pow(_ x: Float, _ n: Int) -> Float {
    // TODO: this implementation is not quite correct, because n may be
    // rounded in conversion to Float. This only effects very extreme cases,
    // so we'll leave it alone for now; however, it gets the sign wrong if
    // it rounds an odd number to an even number, so we should fix it soon.
    return libm_powf(x, Float(n))
  }
  
  @_transparent public static func atan2(y: Float, x: Float) -> Float {
    return libm_atan2f(y, x)
  }

  #if !os(Windows)
  @_transparent public static func logGamma(_ x: Float) -> Float {
    var dontCare: Int32 = 0
    return libm_lgammaf(x, &dontCare)
  }
  #endif
}

extension Double: Real {
  @_transparent public static func cos(_ x: Double) -> Double { return libm_cos(x) }
  @_transparent public static func sin(_ x: Double) -> Double { return libm_sin(x) }
  @_transparent public static func tan(_ x: Double) -> Double { return libm_tan(x) }
  @_transparent public static func acos(_ x: Double) -> Double { return libm_acos(x) }
  @_transparent public static func asin(_ x: Double) -> Double { return libm_asin(x) }
  @_transparent public static func atan(_ x: Double) -> Double { return libm_atan(x) }
  @_transparent public static func cosh(_ x: Double) -> Double { return libm_cosh(x) }
  @_transparent public static func sinh(_ x: Double) -> Double { return libm_sinh(x) }
  @_transparent public static func tanh(_ x: Double) -> Double { return libm_tanh(x) }
  @_transparent public static func acosh(_ x: Double) -> Double { return libm_acosh(x) }
  @_transparent public static func asinh(_ x: Double) -> Double { return libm_asinh(x) }
  @_transparent public static func atanh(_ x: Double) -> Double { return libm_atanh(x) }
  @_transparent public static func exp(_ x: Double) -> Double { return libm_exp(x) }
  @_transparent public static func expMinusOne(_ x: Double) -> Double  { return libm_expm1(x) }
  @_transparent public static func log(_ x: Double) -> Double { return libm_log(x) }
  @_transparent public static func log(onePlus x: Double) -> Double { return libm_log1p(x) }
  @_transparent public static func erf(_ x: Double) -> Double { return libm_erf(x) }
  @_transparent public static func erfc(_ x: Double) -> Double { return libm_erfc(x) }
  @_transparent public static func exp2(_ x: Double) -> Double { return libm_exp2(x) }
  #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  @_transparent public static func exp10(_ x: Double) -> Double { return libm_exp10(x) }
  #endif
  @_transparent public static func hypot(_ x: Double, _ y: Double) -> Double { return libm_hypot(x, y) }
  @_transparent public static func gamma(_ x: Double) -> Double { return libm_tgamma(x) }
  @_transparent public static func log2(_ x: Double) -> Double { return libm_log2(x) }
  @_transparent public static func log10(_ x: Double) -> Double { return libm_log10(x) }
  
  @_transparent public static func pow(_ x: Double, _ y: Double) -> Double {
    guard x >= 0 else { return .nan }
    return libm_pow(x, y)
  }
  
  @_transparent public static func pow(_ x: Double, _ n: Int) -> Double {
    // TODO: this implementation is not quite correct, because n may be
    // rounded in conversion to Double. This only effects very extreme cases,
    // so we'll leave it alone for now; however, it gets the sign wrong if
    // it rounds an odd number to an even number, so we should fix it soon.
    return libm_pow(x, Double(n))
  }
  
  @_transparent public static func atan2(y: Double, x: Double) -> Double {
    return libm_atan2(y, x)
  }

  #if !os(Windows)
  @_transparent public static func logGamma(_ x: Double) -> Double {
    var dontCare: Int32 = 0
    return libm_lgamma(x, &dontCare)
  }
  #endif
}

#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
extension Float80: Real {
  @_transparent public static func cos(_ x: Float80) -> Float80 { return libm_cosl(x) }
  @_transparent public static func sin(_ x: Float80) -> Float80 { return libm_sinl(x) }
  @_transparent public static func tan(_ x: Float80) -> Float80 { return libm_tanl(x) }
  @_transparent public static func acos(_ x: Float80) -> Float80 { return libm_acosl(x) }
  @_transparent public static func asin(_ x: Float80) -> Float80 { return libm_asinl(x) }
  @_transparent public static func atan(_ x: Float80) -> Float80 { return libm_atanl(x) }
  @_transparent public static func cosh(_ x: Float80) -> Float80 { return libm_coshl(x) }
  @_transparent public static func sinh(_ x: Float80) -> Float80 { return libm_sinhl(x) }
  @_transparent public static func tanh(_ x: Float80) -> Float80 { return libm_tanhl(x) }
  @_transparent public static func acosh(_ x: Float80) -> Float80 { return libm_acoshl(x) }
  @_transparent public static func asinh(_ x: Float80) -> Float80 { return libm_asinhl(x) }
  @_transparent public static func atanh(_ x: Float80) -> Float80 { return libm_atanhl(x) }
  @_transparent public static func exp(_ x: Float80) -> Float80 { return libm_expl(x) }
  @_transparent public static func expMinusOne(_ x: Float80) -> Float80  { return libm_expm1l(x) }
  @_transparent public static func log(_ x: Float80) -> Float80 { return libm_logl(x) }
  @_transparent public static func log(onePlus x: Float80) -> Float80 { return libm_log1pl(x) }
  @_transparent public static func erf(_ x: Float80) -> Float80 { return libm_erfl(x) }
  @_transparent public static func erfc(_ x: Float80) -> Float80 { return libm_erfcl(x) }
  @_transparent public static func exp2(_ x: Float80) -> Float80 { return libm_exp2l(x) }
  @_transparent public static func hypot(_ x: Float80, _ y: Float80) -> Float80 { return libm_hypotl(x, y) }
  @_transparent public static func gamma(_ x: Float80) -> Float80 { return libm_tgammal(x) }
  @_transparent public static func log2(_ x: Float80) -> Float80 { return libm_log2l(x) }
  @_transparent public static func log10(_ x: Float80) -> Float80 { return libm_log10l(x) }
  
  @_transparent public static func pow(_ x: Float80, _ y: Float80) -> Float80 {
    guard x >= 0 else { return .nan }
    return libm_powl(x, y)
  }
  
  @_transparent public static func pow(_ x: Float80, _ n: Int) -> Float80 {
    // TODO: this implementation is not quite correct, because n may be
    // rounded in conversion to Float80. This only effects very extreme cases,
    // so we'll leave it alone for now; however, it gets the sign wrong if
    // it rounds an odd number to an even number, so we should fix it soon.
    return libm_powl(x, Float80(n))
  }
  
  @_transparent public static func atan2(y: Float80, x: Float80) -> Float80 {
    return libm_atan2l(y, x)
  }

  #if !os(Windows)
  @_transparent public static func logGamma(_ x: Float80) -> Float80 {
    var dontCare: Int32 = 0
    return libm_lgammal(x, &dontCare)
  }
  #endif
}
#endif
