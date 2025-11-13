//===--- Float16+Real.swift -----------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import _NumericsShims

// Float16 is only available on macOS when targeting arm64.
#if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))

@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
extension Float16: Real {
  @_transparent
  public static func cos(_ x: Float16) -> Float16 {
    Float16(.cos(Float(x)))
  }
  
  @_transparent
  public static func sin(_ x: Float16) -> Float16 {
    Float16(.sin(Float(x)))
  }
  
  @_transparent
  public static func tan(_ x: Float16) -> Float16 {
    Float16(.tan(Float(x)))
  }
  
  @_transparent
  public static func acos(_ x: Float16) -> Float16 {
    Float16(.acos(Float(x)))
  }
  
  @_transparent
  public static func asin(_ x: Float16) -> Float16 {
    Float16(.asin(Float(x)))
  }
  
  @_transparent
  public static func atan(_ x: Float16) -> Float16 {
    Float16(.atan(Float(x)))
  }
  
  @_transparent
  public static func cosh(_ x: Float16) -> Float16 {
    Float16(.cosh(Float(x)))
  }
  
  @_transparent
  public static func sinh(_ x: Float16) -> Float16 {
    Float16(.sinh(Float(x)))
  }
  
  @_transparent
  public static func tanh(_ x: Float16) -> Float16 {
    Float16(.tanh(Float(x)))
  }
  
  @_transparent
  public static func acosh(_ x: Float16) -> Float16 {
    Float16(.acosh(Float(x)))
  }
  
  @_transparent
  public static func asinh(_ x: Float16) -> Float16 {
    Float16(.asinh(Float(x)))
  }
  
  @_transparent
  public static func atanh(_ x: Float16) -> Float16 {
    Float16(.atanh(Float(x)))
  }
  
  @_transparent
  public static func exp(_ x: Float16) -> Float16 {
    Float16(.exp(Float(x)))
  }
  
  @_transparent
  public static func expMinusOne(_ x: Float16) -> Float16 {
    Float16(.expMinusOne(Float(x)))
  }
  
  @_transparent
  public static func log(_ x: Float16) -> Float16 {
    Float16(.log(Float(x)))
  }
  
  @_transparent
  public static func log(onePlus x: Float16) -> Float16 {
    Float16(.log(onePlus: Float(x)))
  }
  
  @_transparent
  public static func erf(_ x: Float16) -> Float16 {
    Float16(.erf(Float(x)))
  }
  
  @_transparent
  public static func erfc(_ x: Float16) -> Float16 {
    Float16(.erfc(Float(x)))
  }
  
  @_transparent
  public static func exp2(_ x: Float16) -> Float16 {
    Float16(.exp2(Float(x)))
  }
  
  @_transparent
  public static func exp10(_ x: Float16) -> Float16 {
    Float16(.exp10(Float(x)))
  }
  
  @_transparent
  public static func hypot(_ x: Float16, _ y: Float16) -> Float16 {
    if x.isInfinite || y.isInfinite { return .infinity }
    let xf = Float(x)
    let yf = Float(y)
    return Float16(.sqrt(xf*xf + yf*yf))
  }
  
  @_transparent
  public static func gamma(_ x: Float16) -> Float16 {
    Float16(.gamma(Float(x)))
  }
  
  @_transparent
  public static func log2(_ x: Float16) -> Float16 {
    Float16(.log2(Float(x)))
  }
  
  @_transparent
  public static func log10(_ x: Float16) -> Float16 {
    Float16(.log10(Float(x)))
  }
  
  @_transparent
  public static func pow(_ x: Float16, _ y: Float16) -> Float16 {
    Float16(.pow(Float(x), Float(y)))
  }
  
  @_transparent
  public static func pow(_ x: Float16, _ n: Int) -> Float16 {
    // Float16 is simpler than Float or Double, because the range of
    // "interesting" exponents is pretty small; anything outside of
    // -22707 ... 34061 simply overflows or underflows for every
    // x that isn't zero or one. This whole range is representable
    // as Float, so we can just use powf as long as we're a little
    // bit (get it?) careful to preserve parity.
    let clamped = min(max(n, -0x10000), 0x10000) | (n & 1)
    return Float16(libm_powf(Float(x), Float(clamped)))
  }
  
  @_transparent
  public static func root(_ x: Float16, _ n: Int) -> Float16 {
    Float16(.root(Float(x), n))
  }
  
  @_transparent
  public static func atan2(y: Float16, x: Float16) -> Float16 {
    Float16(.atan2(y: Float(y), x: Float(x)))
  }
  
  #if !os(Windows)
  @_transparent
  public static func logGamma(_ x: Float16) -> Float16 {
    Float16(.logGamma(Float(x)))
  }
  #endif
  
  #if !arch(wasm32)
  // WASM doesn't have _Float16 on the C side, so we can't define the C hooks
  // that these use. TODO: implement these as Swift builtins instead.
  
  @_transparent
  public static func _relaxedAdd(_ a: Float16, _ b: Float16) -> Float16 {
    _numerics_relaxed_addf16(a, b)
  }
  
  @_transparent
  public static func _relaxedMul(_ a: Float16, _ b: Float16) -> Float16 {
    _numerics_relaxed_mulf16(a, b)
  }
  #endif
}

#endif
