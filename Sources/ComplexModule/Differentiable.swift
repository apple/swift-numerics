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
  func _vjpReal() -> (value: RealType, pullback: (RealType) -> Complex) {
    (value: real, pullback: { v in
      Complex(v, .zero)
    })
  }

  @derivative(of: real)
  @usableFromInline
  func _jvpReal() -> (value: RealType, differential: (Complex) -> RealType) {
    (value: real, differential: { $0.real })
  }

  @derivative(of: imaginary)
  @usableFromInline
  func _vjpImaginary() -> (
    value: RealType,
    pullback: (RealType) -> Complex
  ) {
    (value: real, pullback: { v in
      Complex(.zero, v)
    })
  }

  @derivative(of: imaginary)
  @usableFromInline
  func _jvpImaginary() -> (
    value: RealType,
    differential: (Complex) -> RealType
  ) {
    (value: real, differential: { $0.imaginary })
  }

  @derivative(of: +)
  @usableFromInline
  static func _vjpAdd(lhs: Complex, rhs: Complex)
    -> (value: Complex, pullback: (Complex) -> (Complex, Complex))
  {
    (lhs + rhs, { v in (v, v) })
  }

  @derivative(of: +)
  @usableFromInline
  static func _jvpAdd(lhs: Complex, rhs: Complex)
    -> (value: Complex, differential: (Complex, Complex) -> Complex)
  {
    (lhs + rhs, { $0 + $1 })
  }

  @derivative(of: -)
  @usableFromInline
  static func _vjpSubtract(lhs: Complex, rhs: Complex)
    -> (value: Complex, pullback: (Complex) -> (Complex, Complex))
  {
    (lhs - rhs, { v in (v, -v) })
  }

  @derivative(of: -)
  @usableFromInline
  static func _jvpSubtract(lhs: Complex, rhs: Complex)
    -> (value: Complex, differential: (Complex, Complex) -> Complex)
  {
    (lhs - rhs, { $0 - $1 })
  }

  @derivative(of: *)
  @usableFromInline
  static func _vjpMultiply(lhs: Complex, rhs: Complex)
    -> (value: Complex, pullback: (Complex) -> (Complex, Complex))
  {
    (lhs * rhs, { v in (rhs * v, lhs * v) })
  }

  @derivative(of: *)
  @usableFromInline
  static func _jvpMultiply(lhs: Complex, rhs: Complex)
    -> (value: Complex, differential: (Complex, Complex) -> Complex)
  {
    (lhs * rhs, { ltan, rtan in lhs * rtan + ltan * rhs })
  }

  @derivative(of: /)
  @usableFromInline
  static func _vjpDivide(lhs: Complex, rhs: Complex)
    -> (value: Complex, pullback: (Complex) -> (Complex, Complex))
  {
    (lhs / rhs, { v in (v / rhs, -lhs / (rhs * rhs) * v) })
  }

  @derivative(of: /)
  @usableFromInline
  static func _jvpDivide(lhs: Complex, rhs: Complex)
    -> (value: Complex, differential: (Complex, Complex) -> Complex)
  {
    (lhs / rhs, { ltan, rtan in (ltan * rhs - lhs * rtan) / (rhs * rhs) })
  }

  @derivative(of: conjugate)
  @usableFromInline
  func _vjpConjugate() -> (
    value: Complex,
    pullback: (Complex) -> Complex
  ) {
    (conjugate, { v in v.conjugate })
  }

  @derivative(of: conjugate)
  @usableFromInline
  func _jvpConjugate() -> (
    value: Complex,
    differential: (Complex) -> Complex
  ) {
    (conjugate, { v in v.conjugate })
  }
}

#endif
