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

import NumericsShims

extension Float: Real {
  @_transparent public static func cos(_ x: Float) -> Float { return swift_cosf(x) }
  @_transparent public static func sin(_ x: Float) -> Float { return swift_sinf(x) }
  @_transparent public static func tan(_ x: Float) -> Float { return swift_tanf(x) }
  @_transparent public static func acos(_ x: Float) -> Float { return swift_acosf(x) }
  @_transparent public static func asin(_ x: Float) -> Float { return swift_asinf(x) }
  @_transparent public static func atan(_ x: Float) -> Float { return swift_atanf(x) }
  @_transparent public static func cosh(_ x: Float) -> Float { return swift_coshf(x) }
  @_transparent public static func sinh(_ x: Float) -> Float { return swift_sinhf(x) }
  @_transparent public static func tanh(_ x: Float) -> Float { return swift_tanhf(x) }
  @_transparent public static func acosh(_ x: Float) -> Float { return swift_acoshf(x) }
  @_transparent public static func asinh(_ x: Float) -> Float { return swift_asinhf(x) }
  @_transparent public static func atanh(_ x: Float) -> Float { return swift_atanhf(x) }
  @_transparent public static func exp(_ x: Float) -> Float { return swift_expf(x) }
  @_transparent public static func expm1(_ x: Float) -> Float { return swift_expm1f(x) }
  @_transparent public static func log(_ x: Float) -> Float { return swift_logf(x) }
  @_transparent public static func log1p(_ x: Float) -> Float { return swift_log1pf(x) }
  @_transparent public static func pow(_ x: Float, _ y: Float) -> Float {
    guard x >= 0 else { return .nan }
    return swift_powf(x, y)
  }
  @_transparent public static func pow(_ x: Float, _ n: Int) -> Float {
    // TODO: this implementation is not quite correct, because n may be
    // rounded in conversion to Float. This only effects very extreme cases,
    // so we'll leave it alone for now; however, it gets the sign wrong if
    // it rounds an odd number to an even number, so we should fix it soon.
    return swift_powf(x, Float(n))
  }
  @_transparent public static func atan2(y: Float, x: Float) -> Float { return swift_atan2f(y, x) }
  @_transparent public static func erf(_ x: Float) -> Float { return swift_erff(x) }
  @_transparent public static func erfc(_ x: Float) -> Float { return swift_erfcf(x) }
  @_transparent public static func exp2(_ x: Float) -> Float { return swift_exp2f(x) }
  #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  @_silgen_name("__exp10f") public static func exp10(_ x: Float) -> Float
  #endif
  @_transparent public static func hypot(_ x: Float, _ y: Float) -> Float { return swift_hypotf(x, y) }
  @_transparent public static func gamma(_ x: Float) -> Float { return swift_gammaf(x) }
  @_transparent public static func log2(_ x: Float) -> Float { return swift_log2f(x) }
  @_transparent public static func log10(_ x: Float) -> Float { return swift_log10f(x) }
  #if !os(Windows)
  @_transparent public static func logGamma(_ x: Float) -> Float { return swift_lgammaf(x) }
  #endif
}

extension Double: Real {
  @_transparent public static func cos(_ x: Double) -> Double { return swift_cos(x) }
  @_transparent public static func sin(_ x: Double) -> Double { return swift_sin(x) }
  @_transparent public static func tan(_ x: Double) -> Double { return swift_tan(x) }
  @_transparent public static func acos(_ x: Double) -> Double { return swift_acos(x) }
  @_transparent public static func asin(_ x: Double) -> Double { return swift_asin(x) }
  @_transparent public static func atan(_ x: Double) -> Double { return swift_atan(x) }
  @_transparent public static func cosh(_ x: Double) -> Double { return swift_cosh(x) }
  @_transparent public static func sinh(_ x: Double) -> Double { return swift_sinh(x) }
  @_transparent public static func tanh(_ x: Double) -> Double { return swift_tanh(x) }
  @_transparent public static func acosh(_ x: Double) -> Double { return swift_acosh(x) }
  @_transparent public static func asinh(_ x: Double) -> Double { return swift_asinh(x) }
  @_transparent public static func atanh(_ x: Double) -> Double { return swift_atanh(x) }
  @_transparent public static func exp(_ x: Double) -> Double { return swift_exp(x) }
  @_transparent public static func expm1(_ x: Double) -> Double { return swift_expm1(x) }
  @_transparent public static func log(_ x: Double) -> Double { return swift_log(x) }
  @_transparent public static func log1p(_ x: Double) -> Double { return swift_log1p(x) }
  @_transparent public static func pow(_ x: Double, _ y: Double) -> Double {
    guard x >= 0 else { return .nan }
    return swift_pow(x, y)
  }
  @_transparent public static func pow(_ x: Double, _ n: Int) -> Double {
    // TODO: this implementation is not quite correct, because n may be
    // rounded in conversion to Double. This only effects very extreme cases,
    // so we'll leave it alone for now; however, it gets the sign wrong if
    // it rounds an odd number to an even number, so we should fix it soon.
    return swift_pow(x, Double(n))
  }
  @_transparent public static func atan2(y: Double, x: Double) -> Double { return swift_atan2(y, x) }
  @_transparent public static func erf(_ x: Double) -> Double { return swift_erf(x) }
  @_transparent public static func erfc(_ x: Double) -> Double { return swift_erfc(x) }
  @_transparent public static func exp2(_ x: Double) -> Double { return swift_exp2(x) }
  #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  @_silgen_name("__exp10") public static func exp10(_ x: Double) -> Double
  #endif
  @_transparent public static func hypot(_ x: Double, _ y: Double) -> Double { return swift_hypot(x, y) }
  @_transparent public static func gamma(_ x: Double) -> Double { return swift_gamma(x) }
  @_transparent public static func log2(_ x: Double) -> Double { return swift_log2(x) }
  @_transparent public static func log10(_ x: Double) -> Double { return swift_log10(x) }
  #if !os(Windows)
  @_transparent public static func logGamma(_ x: Double) -> Double { return swift_lgamma(x) }
  #endif
}

#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
extension Float80: Real {
  @_transparent public static func cos(_ x: Float80) -> Float80 { return swift_cosl(x) }
  @_transparent public static func sin(_ x: Float80) -> Float80 { return swift_sinl(x) }
  @_transparent public static func tan(_ x: Float80) -> Float80 { return swift_tanl(x) }
  @_transparent public static func acos(_ x: Float80) -> Float80 { return swift_acosl(x) }
  @_transparent public static func asin(_ x: Float80) -> Float80 { return swift_asinl(x) }
  @_transparent public static func atan(_ x: Float80) -> Float80 { return swift_atanl(x) }
  @_transparent public static func cosh(_ x: Float80) -> Float80 { return swift_coshl(x) }
  @_transparent public static func sinh(_ x: Float80) -> Float80 { return swift_sinhl(x) }
  @_transparent public static func tanh(_ x: Float80) -> Float80 { return swift_tanhl(x) }
  @_transparent public static func acosh(_ x: Float80) -> Float80 { return swift_acoshl(x) }
  @_transparent public static func asinh(_ x: Float80) -> Float80 { return swift_asinhl(x) }
  @_transparent public static func atanh(_ x: Float80) -> Float80 { return swift_atanhl(x) }
  @_transparent public static func exp(_ x: Float80) -> Float80 { return swift_expl(x) }
  @_transparent public static func expm1(_ x: Float80) -> Float80 { return swift_expm1l(x) }
  @_transparent public static func log(_ x: Float80) -> Float80 { return swift_logl(x) }
  @_transparent public static func log1p(_ x: Float80) -> Float80 { return swift_log1pl(x) }
  @_transparent public static func pow(_ x: Float80, _ y: Float80) -> Float80 {
    guard x >= 0 else { return .nan }
    return swift_powl(x, y)
  }
  @_transparent public static func pow(_ x: Float80, _ n: Int) -> Float80 {
    return swift_powl(x, Float80(n))
  }
  @_transparent public static func atan2(y: Float80, x: Float80) -> Float80 { return swift_atan2l(y, x) }
  @_transparent public static func erf(_ x: Float80) -> Float80 { return swift_erfl(x) }
  @_transparent public static func erfc(_ x: Float80) -> Float80 { return swift_erfcl(x) }
  @_transparent public static func exp2(_ x: Float80) -> Float80 { return swift_exp2l(x) }
  @_transparent public static func hypot(_ x: Float80, _ y: Float80) -> Float80 { return swift_hypotl(x, y) }
  @_transparent public static func gamma(_ x: Float80) -> Float80 { return swift_gammal(x) }
  @_transparent public static func log2(_ x: Float80) -> Float80 { return swift_log2l(x) }
  @_transparent public static func log10(_ x: Float80) -> Float80 { return swift_log10l(x) }
  @_transparent public static func logGamma(_ x: Float80) -> Float80 { return swift_lgammal(x) }
}
#endif
