//===--- ComplexArithmetic.swift ------------------------------*- swift -*-===//
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

// MARK: - Vector space structure
extension Complex: AdditiveArithmetic {
  @_transparent
  public static func +(z: Complex, w: Complex) -> Complex {
    return Complex(z.x + w.x, z.y + w.y)
  }
  
  @_transparent
  public static func -(z: Complex, w: Complex) -> Complex {
    return Complex(z.x - w.x, z.y - w.y)
  }
  
  @_transparent
  public static func *(z: Complex, a: RealType) -> Complex {
    return Complex(z.x*a, z.y*a)
  }
  
  @_transparent
  public static func /(z: Complex, a: RealType) -> Complex {
    return Complex(z.x/a, z.y/a)
  }
  
  @_transparent
  public static func +=(z: inout Complex, w: Complex) {
    z = z + w
  }
  
  @_transparent
  public static func -=(z: inout Complex, w: Complex) {
    z = z - w
  }
  
  @_transparent
  public static func *(a: RealType, z: Complex) -> Complex {
    return z*a
  }
  
  @_transparent
  public static func *=(z: inout Complex, a: RealType) {
    z = a * z
  }
  
  @_transparent
  public static func /=(z: inout Complex, a: RealType) {
    z = z / a
  }
}

// MARK: - Multiplicative structure
extension Complex: Numeric {
  public typealias IntegerLiteralType = Int
  
  public init(integerLiteral value: Int) {
    self.init(RealType(value))
  }
  
  @inlinable
  public static func *(z: Complex, w: Complex) -> Complex {
    return Complex(z.x*w.x - z.y*w.y, z.x*w.y + z.y*w.x)
  }
  
  @inlinable
  public static func /(z: Complex, w: Complex) -> Complex {
    // Try the naive expression z/w = z*conj(w) / |w|^2; if the result is
    // normal, then everything was fine, and we can simply return the result.
    let naive = z * (w.conjugate / w.unsafeMagnitudeSquared)
    guard naive.isNormal else { return carefulDivide(z, w) }
    return naive
  }
  
  @inlinable
  public static func /(a: RealType, w: Complex) -> Complex {
    let naive = a * w.conjugate / w.unsafeMagnitudeSquared
    guard naive.isNormal else { return carefulDivide(Complex(a), w) }
    return naive
  }
  
  @usableFromInline
  internal static func carefulDivide(_ z: Complex, _ w: Complex) -> Complex {
    if z.isZero || !w.isFinite { return .zero }
    let zScale = max(abs(z.x), abs(z.y))
    let wScale = max(abs(w.x), abs(w.y))
    let zNorm = z / zScale
    let wNorm = w / wScale
    let rNorm = zNorm * wNorm.conjugate / wNorm.unsafeMagnitudeSquared
    if zScale >= wScale { return rNorm / wScale * zScale }
    return rNorm * zScale / wScale
  }
  
  public static func *=(z: inout Complex, w: Complex) {
    z = z * w
  }
  
  public static func /=(z: inout Complex, w: Complex) {
    z = z / w
  }
  
  /// A normalized complex number with the same phase as this value.
  ///
  /// If such a value cannot be produced (because the phase of zero and infinity is undefined),
  /// `nil` is returned.
  public var normalized: Complex? {
    let norm = magnitude
    if magnitude.isNormal { return self / norm }
    if isZero || !isFinite { return nil }
    let large = RealType.maximumMagnitude(x, y)
    return (self/large).normalized
  }
}
