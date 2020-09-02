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

#if swift(>=5.3) && canImport(_Differentiation)
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
  @derivative(of: init(_:_:))
  @usableFromInline
  static func _derivativeInit(
    _ real: RealType,
    _ imaginary: RealType
  ) -> (value: Complex, pullback: (Complex) -> (RealType, RealType)) {
    (value: .init(real, imaginary), pullback: { v in
      (v.real, v.imaginary)
    })
  }

  @derivative(of: real)
  @usableFromInline
  func _derivativeReal() -> (value: RealType, pullback: (RealType) -> Complex) {
    (value: real, pullback: { v in
      Complex(v, .zero)
    })
  }

  @derivative(of: imaginary)
  @usableFromInline
  func _derivativeImaginary() -> (
    value: RealType,
    pullback: (RealType) -> Complex
  ) {
    (value: real, pullback: { v in
      Complex(.zero, v)
    })
  }

  @derivative(of: +)
  @usableFromInline
  static func _derivativeAdd(lhs: Complex, rhs: Complex)
    -> (value: Complex, pullback: (Complex) -> (Complex, Complex))
  {
    (lhs + rhs, { v in (v, v) })
  }

  @derivative(of: -)
  @usableFromInline
  static func _derivativeSubtract(lhs: Complex, rhs: Complex)
    -> (value: Complex, pullback: (Complex) -> (Complex, Complex))
  {
    (lhs - rhs, { v in (v, -v) })
  }

  @derivative(of: *)
  @usableFromInline
  static func _derivativeMultiply(lhs: Complex, rhs: Complex)
    -> (value: Complex, pullback: (Complex) -> (Complex, Complex))
  {
    (lhs * rhs, { v in (rhs * v, lhs * v) })
  }

  @derivative(of: /)
  @usableFromInline
  static func _derivativeDivide(lhs: Complex, rhs: Complex)
    -> (value: Complex, pullback: (Complex) -> (Complex, Complex))
  {
    (lhs / rhs, { v in (v / rhs, -lhs / (rhs * rhs) * v) })
  }

  @derivative(of: conjugate)
  @usableFromInline
  func _derivativeConjugate() -> (
    value: Complex,
    pullback: (Complex) -> Complex
  ) {
    (conjugate, { v in v.conjugate })
  }
}

#endif
