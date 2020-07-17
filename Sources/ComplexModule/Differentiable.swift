//===--- Differentiable.swift ---------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

#if canImport(_Differentiation)
import _Differentiation

extension Complex: Differentiable
where RealType: Differentiable, RealType.TangentVector == RealType {
  public typealias TangentVector = Self

  @inlinable
  public var zeroTangentVectorInitializer: () -> Self {
    { Complex.zero }
  }
}

extension Complex
where RealType: Differentiable, RealType.TangentVector == RealType {

  @derivative(of: real)
  @usableFromInline
  func _vjpDerivativeReal() -> (value: RealType, pullback: (RealType) -> Complex) {
    (value: real, pullback: { v in
      Complex(v, .zero)
    })
  }

  @derivative(of: real)
  @usableFromInline
  func _jvpDerivativeReal() -> (value: RealType, differential: (Complex) -> RealType) {
    (value: real, differential: { $0.real })
  }

  @derivative(of: imaginary)
  @usableFromInline
  func _vjpDerivativeImaginary() -> (
    value: RealType,
    pullback: (RealType) -> Complex
  ) {
    (value: real, pullback: { v in
      Complex(.zero, v)
    })
  }

  @derivative(of: imaginary)
  @usableFromInline
  func _jvpDerivativeImaginary() -> (
    value: RealType,
    differential: (Complex) -> RealType
  ) {
    (value: real, differential: { $0.imaginary })
  }

  @derivative(of: +)
  @usableFromInline
  static func _vjpDerivativeAdd(lhs: Complex, rhs: Complex)
    -> (value: Complex, pullback: (Complex) -> (Complex, Complex))
  {
    (lhs + rhs, { v in (v, v) })
  }

  @derivative(of: +)
  @usableFromInline
  static func _jvpDerivativeAdd(lhs: Complex, rhs: Complex)
    -> (value: Complex, differential: (Complex, Complex) -> Complex)
  {
    (lhs + rhs, { $0 + $1 })
  }

  @derivative(of: -)
  @usableFromInline
  static func _vjpDerivativeSubtract(lhs: Complex, rhs: Complex)
    -> (value: Complex, pullback: (Complex) -> (Complex, Complex))
  {
    (lhs - rhs, { v in (v, -v) })
  }

  @derivative(of: -)
  @usableFromInline
  static func _jvpDerivativeSubtract(lhs: Complex, rhs: Complex)
    -> (value: Complex, differential: (Complex, Complex) -> Complex)
  {
    (lhs - rhs, { $0 - $1 })
  }

  @derivative(of: *)
  @usableFromInline
  static func _vjpDerivativeMultiply(lhs: Complex, rhs: Complex)
    -> (value: Complex, pullback: (Complex) -> (Complex, Complex))
  {
    (lhs * rhs, { v in (rhs * v, lhs * v) })
  }

  @derivative(of: *)
  @usableFromInline
  static func _jvpDerivativeMultiply(lhs: Complex, rhs: Complex)
    -> (value: Complex, differential: (Complex, Complex) -> Complex)
  {
    (lhs * rhs, { ltan, rtan in lhs * rtan + ltan * rhs })
  }

  @derivative(of: /)
  @usableFromInline
  static func _vjpDerivativeDivide(lhs: Complex, rhs: Complex)
    -> (value: Complex, pullback: (Complex) -> (Complex, Complex))
  {
    (lhs / rhs, { v in (v / rhs, -lhs / (rhs * rhs) * v) })
  }

  @derivative(of: /)
  @usableFromInline
  static func _jvpDerivativeDivide(lhs: Complex, rhs: Complex)
    -> (value: Complex, differential: (Complex, Complex) -> Complex)
  {
    (lhs / rhs, { ltan, rtan in (ltan * rhs - lhs * rtan) / (rhs * rhs) })
  }

  @derivative(of: conjugate)
  @usableFromInline
  func _vjpDerivativeConjugate() -> (
    value: Complex,
    pullback: (Complex) -> Complex
  ) {
    (conjugate, { v in v.conjugate })
  }

  @derivative(of: conjugate)
  @usableFromInline
  func _jvpDerivativeConjugate() -> (
    value: Complex,
    differential: (Complex) -> Complex
  ) {
    (conjugate, { v in v.conjugate })
  }
}

#endif
