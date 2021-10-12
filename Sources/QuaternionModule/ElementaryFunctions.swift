//===--- ElementaryFunctions.swift ----------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2019-2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import RealModule

// As the following elementary functions algorithms are adoptions of the
// elementary functions of complex numbers: If you make a modification to either
// of the following functions, you should almost surely make a parallel
// modification to the same elementary function of complex numbers (See
// ElementaryFunctions.swift in ComplexModule).
extension Quaternion/*: ElementaryFunctions */ {

  // MARK: - exp-like functions

  // Mathematically, this operation can be expanded in terms of the `Real`
  // operations `exp`, `cos` and `sin` as follows:
  // ```
  // exp(r + xi + yj + zk) = exp(r + v) = exp(r) exp(v)
  //                       = exp(r) (cos(||v||) + (v/||v||) sin(||v||))
  // ```
  // Note that naive evaluation of this expression in floating-point would be
  // prone to premature overflow, since `cos` and `sin` both have magnitude
  // less than 1 for most inputs (i.e. `exp(r)` may be infinity when
  // `exp(r) cos(arg)` would not be).
  @inlinable
  public static func exp(_ q: Quaternion) -> Quaternion {
    guard q.isFinite else { return q }
    // For real quaternions we can skip phase and axis calculations
    // TODO: Replace q.imaginary == .zero with `q.isReal`
    let argument = q.imaginary == .zero ? .zero : q.imaginary.length
    let axis = q.imaginary == .zero ? .zero : (q.imaginary / argument)
    // If real < log(greatestFiniteMagnitude), then exp(q.real) does not overflow.
    // To protect ourselves against sketchy log or exp implementations in
    // an unknown host library, or slight rounding disagreements between
    // the two, subtract one from the bound for a little safety margin.
    guard q.real < RealType.log(.greatestFiniteMagnitude) - 1 else {
      let halfScale = RealType.exp(q.real/2)
      let rotation = Quaternion(halfAngle: argument, unitAxis: axis)
      return rotation.multiplied(by: halfScale).multiplied(by: halfScale)
    }
    return Quaternion(halfAngle: argument, unitAxis: axis).multiplied(by: .exp(q.real))
  }

  @inlinable
  public static func expMinusOne(_ q: Quaternion) -> Quaternion {
    // Note that the imaginary part is just the usual exp(r) sin(argument);
    // the only trick is computing the real part, which allows us to borrow
    // the derivative of real part for this function from complex numbers.
    // See `expMinusOne` in the ComplexModule for implementation details.
    guard q.isFinite else { return q }
    // TODO: Replace q.imaginary == .zero with `q.isReal`
    let argument = q.imaginary == .zero ? .zero : q.imaginary.length
    let axis = q.imaginary == .zero ? .zero : (q.imaginary / argument)
    // If exp(q) is close to the overflow boundary, we don't need to
    // worry about the "MinusOne" part of this function; we're just
    // computing exp(q). (Even when q.y is near a multiple of π/2,
    // it can't be close enough to overcome the scaling from exp(q.x),
    // so the -1 term is _always_ negligable). So we simply handle
    // these cases exactly the same as exp(q).
    guard q.real < RealType.log(.greatestFiniteMagnitude) - 1 else {
      let halfScale = RealType.exp(q.real/2)
      let rotation = Quaternion(halfAngle: argument, unitAxis: axis)
      return rotation.multiplied(by: halfScale).multiplied(by: halfScale)
    }
    return Quaternion(
      real: RealType._mulAdd(.cos(argument), .expMinusOne(q.real), .cosMinusOne(argument)),
      imaginary: axis * .exp(q.real) * .sin(argument)
    )
  }

  // cosh(r + xi + yj + zk) = cosh(r + v)
  // cosh(r + v) = cosh(r) cos(||v||) + (v/||v||) sinh(r) sin(||v||).
  //
  // See cosh on complex numbers for algorithm details.
  @inlinable
  public static func cosh(_ q: Quaternion) -> Quaternion {
    guard q.isFinite else { return q }
    // TODO: Replace q.imaginary == .zero with `q.isReal`
    let argument = q.imaginary == .zero ? .zero : q.imaginary.length
    let axis = q.imaginary == .zero ? .zero : (q.imaginary / argument)
    return cosh(q.real, argument, axis: axis)
  }

  // sinh(r + xi + yj + zk) = sinh(r + v)
  // sinh(r + v) = sinh(r) cos(||v||) + (v/||v||) cosh(r) sin(||v||)
  //
  // See cosh on complex numbers for algorithm details.
  @inlinable
  public static func sinh(_ q: Quaternion) -> Quaternion {
    guard q.isFinite else { return q }
    // TODO: Replace q.imaginary == .zero with `q.isReal`
    let argument = q.imaginary == .zero ? .zero : q.imaginary.length
    let axis = q.imaginary == .zero ? .zero : (q.imaginary / argument)
    guard q.real.magnitude < -RealType.log(.ulpOfOne) else {
      let rotation = Quaternion(halfAngle: argument, unitAxis: axis)
      let firstScale = RealType.exp(q.real.magnitude/2)
      let secondScale = RealType(signOf: q.real, magnitudeOf: firstScale/2)
      return rotation.multiplied(by: firstScale).multiplied(by: secondScale)
    }
    return Quaternion(
      real: .sinh(q.real) * .cos(argument),
      imaginary: axis * .cosh(q.real) * .sin(argument)
    )
  }

  // tanh(q) = sinh(q) / cosh(q)
  //
  // See tanh on complex numbers for algorithm details.
  @inlinable
  public static func tanh(_ q: Quaternion) -> Quaternion {
    guard q.isFinite else { return q }
    // Note that when |r| is larger than -log(.ulpOfOne),
    // sinh(r + v) == ±cosh(r + v), so tanh(r + v) is just ±1.
    guard q.real.magnitude < -RealType.log(.ulpOfOne) else {
      return Quaternion(
        real: RealType(signOf: q.real, magnitudeOf: 1),
        imaginary:
          RealType(signOf: q.imaginary.x, magnitudeOf: 0),
          RealType(signOf: q.imaginary.y, magnitudeOf: 0),
          RealType(signOf: q.imaginary.z, magnitudeOf: 0)
      )
    }
    return sinh(q) / cosh(q)
  }

  // cos(r + xi + yj + zk) = cos(r + v)
  // cos(r + v) = cos(r) cosh(||v||) - (v/||v||) sin(r) sinh(||v||).
  //
  // See cosh for algorithm details.
  @inlinable
  public static func cos(_ q: Quaternion) -> Quaternion {
    guard q.isFinite else { return q }
    // TODO: Replace q.imaginary == .zero with `q.isReal`
    let argument = q.imaginary == .zero ? .zero : q.imaginary.length
    let axis = q.imaginary == .zero ? .zero : (q.imaginary / argument)
    return cosh(-argument, q.real, axis: axis)
  }

  // See sinh on complex numbers for algorithm details.
  @inlinable
  public static func sin(_ q: Quaternion) -> Quaternion {
    guard q.isFinite else { return q }
    // TODO: Replace q.imaginary == .zero with `q.isReal`
    let argument = q.imaginary == .zero ? .zero : q.imaginary.length
    let axis = q.imaginary == .zero ? .zero : (q.imaginary / argument)
    let (x, y) = sinh(-argument, q.real)
    return Quaternion(real: y, imaginary: axis * -x)
  }

  // tan(q) = sin(q) / cos(q)
  //
  // See tanh for algorithm details.
  @inlinable
  public static func tan(_ q: Quaternion) -> Quaternion {
    return sin(q) / cos(q)
  }

  // MARK: - log-like functions
  @inlinable
  public static func log(_ q: Quaternion) -> Quaternion {
    // If q is zero or infinite, the phase is undefined, so the result is
    // the single exceptional value.
    guard q.isFinite && !q.isZero else { return .infinity }

    let vectorLength = q.imaginary.length
    let scale = q.halfAngle / vectorLength

    // We deliberatly choose log(length) over the (faster)
    // log(lengthSquared) / 2 which is used for complex numbers; as
    // the squared length of quaternions is more prone to overflows than the
    // squared length of complex numbers.
    return Quaternion(real: .log(q.length), imaginary: q.imaginary * scale)
  }

  // MARK: - pow-like functions
  @inlinable
  public static func pow(_ q: Quaternion, _ p: Quaternion) -> Quaternion {
    // pow(q, p) = exp(log(q^p)) = exp(p * log(q))
    return exp(p * log(q))
  }

  @inlinable
  public static func pow(_ q: Quaternion, _ n: Int) -> Quaternion {
    if q.isZero { return .zero }
    // TODO: this implementation is not quite correct, because n may be
    // rounded in conversion to RealType. This only effects very extreme
    // cases, so we'll leave it alone for now.
    //
    // Note that this does not have the same problems that a similar
    // implementation for a real type would have, because there's no
    // parity/sign interaction in the complex plane.
    return exp(log(q).multiplied(by: RealType(n)))
  }

  @inlinable
  public static func sqrt(_ q: Quaternion) -> Quaternion<RealType> {
    if q.isZero { return .zero }
    // TODO: This is not the fastest implementation available
    return exp(log(q).divided(by: 2))
  }

  @inlinable
  public static func root(_ q: Quaternion, _ n: Int) -> Quaternion {
    if q.isZero { return .zero }
    // TODO: this implementation is not quite correct, because n may be
    // rounded in conversion to RealType. This only effects very extreme
    // cases, so we'll leave it alone for now.
    //
    // Note that this does not have the same problems that a similar
    // implementation for a real type would have, because there's no
    // parity/sign interaction in the complex plane.
    return exp(log(q).divided(by: RealType(n)))
  }
}

// MARK: - Hyperbolic trigonometric function helper
extension Quaternion {

  // See cosh of complex numbers for algorithm details.
  @usableFromInline @_transparent
  internal static func cosh(
    _ x: RealType,
    _ y: RealType,
    axis: SIMD3<RealType>
  ) -> Quaternion {
    guard x.magnitude < -RealType.log(.ulpOfOne) else {
      let rotation = Quaternion(halfAngle: y, unitAxis: axis)
      let firstScale = RealType.exp(x.magnitude/2)
      let secondScale = firstScale/2
      return rotation.multiplied(by: firstScale).multiplied(by: secondScale)
    }
    return Quaternion(
      real: .cosh(x) * .cos(y),
      imaginary: axis * .sinh(x) * .sin(y)
    )
  }

   // See sinh of complex numbers for algorithm details.
  @usableFromInline @_transparent
  internal static func sinh(
    _ x: RealType,
    _ y: RealType
  ) -> (RealType, RealType) {
    guard x.magnitude < -RealType.log(.ulpOfOne) else {
      var (x, y) = (RealType.cos(y), RealType.sin(y))
      let firstScale = RealType.exp(x.magnitude/2)
      (x, y) = (x * firstScale, y * firstScale)
      let secondScale = RealType(signOf: x, magnitudeOf: firstScale/2)
      return (x * secondScale, y * secondScale)
    }
    return (.sinh(x) * .cos(y), .cosh(x) * .sin(y))
  }
}
