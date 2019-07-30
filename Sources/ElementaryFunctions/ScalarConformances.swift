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

extension Float: Real {
  @_silgen_name("cosf") public static func cos(_ x: Float) -> Float
  @_silgen_name("sinf") public static func sin(_ x: Float) -> Float
  @_silgen_name("tanf") public static func tan(_ x: Float) -> Float
  @_silgen_name("acosf") public static func acos(_ x: Float) -> Float
  @_silgen_name("asinf") public static func asin(_ x: Float) -> Float
  @_silgen_name("atanf") public static func atan(_ x: Float) -> Float
  @_silgen_name("coshf") public static func cosh(_ x: Float) -> Float
  @_silgen_name("sinhf") public static func sinh(_ x: Float) -> Float
  @_silgen_name("tanhf") public static func tanh(_ x: Float) -> Float
  @_silgen_name("acoshf") public static func acosh(_ x: Float) -> Float
  @_silgen_name("asinhf") public static func asinh(_ x: Float) -> Float
  @_silgen_name("atanhf") public static func atanh(_ x: Float) -> Float
  @_silgen_name("expf") public static func exp(_ x: Float) -> Float
  @_silgen_name("expMinusOnef") public static func expMinusOne(_ x: Float) -> Float
  @_silgen_name("logf") public static func log(_ x: Float) -> Float
  @_silgen_name("log1pf") public static func log(onePlus x: Float) -> Float
  @_silgen_name("erff") public static func erf(_ x: Float) -> Float
  @_silgen_name("erfcf") public static func erfc(_ x: Float) -> Float
  @_silgen_name("exp2f") public static func exp2(_ x: Float) -> Float
  #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  @_silgen_name("__exp10f") public static func exp10(_ x: Float) -> Float
  #endif
  @_silgen_name("hypotf") public static func hypot(_ x: Float, _ y: Float) -> Float
  @_silgen_name("tgammaf") public static func gamma(_ x: Float) -> Float
  @_silgen_name("log2f") public static func log2(_ x: Float) -> Float
  @_silgen_name("log10f") public static func log10(_ x: Float) -> Float

  @usableFromInline @_silgen_name("powf")
  internal static func libm_pow(_ x: Float, _ y: Float) -> Float
  
  @_transparent public static func pow(_ x: Float, _ y: Float) -> Float {
    guard x >= 0 else { return .nan }
    return libm_pow(x, y)
  }
  
  @_transparent public static func pow(_ x: Float, _ n: Int) -> Float {
    // TODO: this implementation is not quite correct, because n may be
    // rounded in conversion to Float. This only effects very extreme cases,
    // so we'll leave it alone for now; however, it gets the sign wrong if
    // it rounds an odd number to an even number, so we should fix it soon.
    return libm_pow(x, Float(n))
  }
  
  @usableFromInline @_silgen_name("atan2f")
  internal static func libm_atan2(_ y: Float, _ x: Float) -> Float
  
  @_transparent public static func atan2(y: Float, x: Float) -> Float {
    return libm_atan2(y, x)
  }

  #if !os(Windows)
  @usableFromInline @_silgen_name("lgammaf_r")
  internal static func libm_lgamma(_ x: Float, _ signgam: UnsafeMutablePointer<Int32>) -> Float
  
  @_transparent public static func logGamma(_ x: Float) -> Float {
    var dontCare: Int32 = 0
    return libm_lgamma(x, &dontCare)
  }
  #endif
}

extension Double: Real {
  @_silgen_name("cos") public static func cos(_ x: Double) -> Double
  @_silgen_name("sin") public static func sin(_ x: Double) -> Double
  @_silgen_name("tan") public static func tan(_ x: Double) -> Double
  @_silgen_name("acos") public static func acos(_ x: Double) -> Double
  @_silgen_name("asin") public static func asin(_ x: Double) -> Double
  @_silgen_name("atan") public static func atan(_ x: Double) -> Double
  @_silgen_name("cosh") public static func cosh(_ x: Double) -> Double
  @_silgen_name("sinh") public static func sinh(_ x: Double) -> Double
  @_silgen_name("tanh") public static func tanh(_ x: Double) -> Double
  @_silgen_name("acosh") public static func acosh(_ x: Double) -> Double
  @_silgen_name("asinh") public static func asinh(_ x: Double) -> Double
  @_silgen_name("atanh") public static func atanh(_ x: Double) -> Double
  @_silgen_name("exp") public static func exp(_ x: Double) -> Double
  @_silgen_name("expMinusOne") public static func expMinusOne(_ x: Double) -> Double
  @_silgen_name("log") public static func log(_ x: Double) -> Double
  @_silgen_name("log1p") public static func log(onePlus x: Double) -> Double
  @_silgen_name("erf") public static func erf(_ x: Double) -> Double
  @_silgen_name("erfc") public static func erfc(_ x: Double) -> Double
  @_silgen_name("exp2") public static func exp2(_ x: Double) -> Double
  #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  @_silgen_name("__exp10") public static func exp10(_ x: Double) -> Double
  #endif
  @_silgen_name("hypot") public static func hypot(_ x: Double, _ y: Double) -> Double
  @_silgen_name("tgamma") public static func gamma(_ x: Double) -> Double
  @_silgen_name("log2") public static func log2(_ x: Double) -> Double
  @_silgen_name("log10") public static func log10(_ x: Double) -> Double

  @usableFromInline @_silgen_name("pow")
  internal static func libm_pow(_ x: Double, _ y: Double) -> Double
  
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
  
  @usableFromInline @_silgen_name("atan2")
  internal static func libm_atan2(_ y: Double, _ x: Double) -> Double
  
  @_transparent public static func atan2(y: Double, x: Double) -> Double {
    return libm_atan2(y, x)
  }

  #if !os(Windows)
  @usableFromInline @_silgen_name("lgamma_r")
  internal static func libm_lgamma_r(_ x: Double, _ signgam: UnsafeMutablePointer<Int32>) -> Double
  
  @_transparent public static func logGamma(_ x: Double) -> Double {
    var dontCare: Int32 = 0
    return libm_lgamma_r(x, &dontCare)
  }
  #endif
}

#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
extension Float80: Real {
  @_silgen_name("cosl") public static func cos(_ x: Float80) -> Float80
  @_silgen_name("sinl") public static func sin(_ x: Float80) -> Float80
  @_silgen_name("tanl") public static func tan(_ x: Float80) -> Float80
  @_silgen_name("acosl") public static func acos(_ x: Float80) -> Float80
  @_silgen_name("asinl") public static func asin(_ x: Float80) -> Float80
  @_silgen_name("atanl") public static func atan(_ x: Float80) -> Float80
  @_silgen_name("coshl") public static func cosh(_ x: Float80) -> Float80
  @_silgen_name("sinhl") public static func sinh(_ x: Float80) -> Float80
  @_silgen_name("tanhl") public static func tanh(_ x: Float80) -> Float80
  @_silgen_name("acoshl") public static func acosh(_ x: Float80) -> Float80
  @_silgen_name("asinhl") public static func asinh(_ x: Float80) -> Float80
  @_silgen_name("atanhl") public static func atanh(_ x: Float80) -> Float80
  @_silgen_name("expl") public static func exp(_ x: Float80) -> Float80
  @_silgen_name("expMinusOnel") public static func expMinusOne(_ x: Float80) -> Float80
  @_silgen_name("logl") public static func log(_ x: Float80) -> Float80
  @_silgen_name("log1pl") public static func log(onePlus x: Float80) -> Float80
  @_silgen_name("erfl") public static func erf(_ x: Float80) -> Float80
  @_silgen_name("erfcl") public static func erfc(_ x: Float80) -> Float80
  @_silgen_name("exp2l") public static func exp2(_ x: Float80) -> Float80
  @_silgen_name("hypotl") public static func hypot(_ x: Float80, _ y: Float80) -> Float80
  @_silgen_name("tgammal") public static func gamma(_ x: Float80) -> Float80
  @_silgen_name("log2l") public static func log2(_ x: Float80) -> Float80
  @_silgen_name("log10l") public static func log10(_ x: Float80) -> Float80

  @usableFromInline @_silgen_name("powl")
  internal static func libm_pow(_ x: Float80, _ y: Float80) -> Float80
  
  @_transparent public static func pow(_ x: Float80, _ y: Float80) -> Float80 {
    guard x >= 0 else { return .nan }
    return libm_pow(x, y)
  }
  
  @_transparent public static func pow(_ x: Float80, _ n: Int) -> Float80 {
    return libm_pow(x, Float80(n))
  }
  
  @usableFromInline @_silgen_name("atan2l")
  internal static func libm_atan2(_ y: Float80, _ x: Float80) -> Float80
  
  @_transparent public static func atan2(y: Float80, x: Float80) -> Float80 {
    return libm_atan2(y, x)
  }

  @usableFromInline @_silgen_name("lgammal_r")
  internal static func libm_lgamma_r(_ x: Float80, _ signgam: UnsafeMutablePointer<Int32>) -> Float80
  
  @_transparent public static func logGamma(_ x: Float80) -> Float80 {
    var dontCare: Int32 = 0
    return libm_lgamma_r(x, &dontCare)
  }
}
#endif
