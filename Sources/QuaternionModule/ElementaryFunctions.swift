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
  // `exp(r) cos(θ)` would not be).
  @inlinable
  public static func exp(_ q: Quaternion) -> Quaternion {
    guard q.isFinite else { return q }
    // For real quaternions we can skip phase and axis calculations
    // TODO: Replace q.imaginary == .zero with `q.isReal`
    let θ = q.imaginary == .zero ? .zero : q.imaginary.length // θ = ||v||
    let n̂ = q.imaginary == .zero ? .zero : (q.imaginary / θ)  // n̂ = v / ||v||
    // If real < log(greatestFiniteMagnitude), then exp(q.real) does not overflow.
    // To protect ourselves against sketchy log or exp implementations in
    // an unknown host library, or slight rounding disagreements between
    // the two, subtract one from the bound for a little safety margin.
    guard q.real < RealType.log(.greatestFiniteMagnitude) - 1 else {
      let halfScale = RealType.exp(q.real/2)
      let rotation = Quaternion(halfAngle: θ, unitAxis: n̂)
      return rotation.multiplied(by: halfScale).multiplied(by: halfScale)
    }
    return Quaternion(halfAngle: θ, unitAxis: n̂).multiplied(by: .exp(q.real))
  }

  @inlinable
  public static func expMinusOne(_ q: Quaternion) -> Quaternion {
    // Note that the imaginary part is just the usual exp(r) sin(θ);
    // the only trick is computing the real part, which allows us to borrow
    // the derivative of real part for this function from complex numbers.
    // See `expMinusOne` in the ComplexModule for implementation details.
    guard q.isFinite else { return q }
    // TODO: Replace q.imaginary == .zero with `q.isReal`
    let θ = q.imaginary == .zero ? .zero : q.imaginary.length // θ = ||v||
    let n̂ = q.imaginary == .zero ? .zero : (q.imaginary / θ)  // n̂ = v / ||v||
    // If exp(q) is close to the overflow boundary, we don't need to
    // worry about the "MinusOne" part of this function; we're just
    // computing exp(q). (Even when q.y is near a multiple of π/2,
    // it can't be close enough to overcome the scaling from exp(q.x),
    // so the -1 term is _always_ negligable). So we simply handle
    // these cases exactly the same as exp(q).
    guard q.real < RealType.log(.greatestFiniteMagnitude) - 1 else {
      let halfScale = RealType.exp(q.real/2)
      let rotation = Quaternion(halfAngle: θ, unitAxis: n̂)
      return rotation.multiplied(by: halfScale).multiplied(by: halfScale)
    }
    return Quaternion(
      real: RealType._mulAdd(.cos(θ), .expMinusOne(q.real), .cosMinusOne(θ)),
      imaginary: n̂ * .exp(q.real) * .sin(θ)
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
    let θ = q.imaginary == .zero ? .zero : q.imaginary.length // θ = ||v||
    let n̂ = q.imaginary == .zero ? .zero : (q.imaginary / θ)  // n̂ = v / ||v||
    guard q.real.magnitude < -RealType.log(.ulpOfOne) else {
      let rotation = Quaternion(halfAngle: θ, unitAxis: n̂)
      let firstScale = RealType.exp(q.real.magnitude/2)
      let secondScale = firstScale/2
      return rotation.multiplied(by: firstScale).multiplied(by: secondScale)
    }
    return Quaternion(
      real: .cosh(q.real) * .cos(θ),
      imaginary: n̂ * .sinh(q.real) * .sin(θ)
    )
  }

  // sinh(r + xi + yj + zk) = sinh(r + v)
  // sinh(r + v) = sinh(r) cos(||v||) + (v/||v||) cosh(r) sin(||v||)
  //
  // See cosh on complex numbers for algorithm details.
  @inlinable
  public static func sinh(_ q: Quaternion) -> Quaternion {
    guard q.isFinite else { return q }
    // TODO: Replace q.imaginary == .zero with `q.isReal`
    let θ = q.imaginary == .zero ? .zero : q.imaginary.length // θ = ||v||
    let n̂ = q.imaginary == .zero ? .zero : (q.imaginary / θ)  // n̂ = v / ||v||
    guard q.real.magnitude < -RealType.log(.ulpOfOne) else {
      let rotation = Quaternion(halfAngle: θ, unitAxis: n̂)
      let firstScale = RealType.exp(q.real.magnitude/2)
      let secondScale = RealType(signOf: q.real, magnitudeOf: firstScale/2)
      return rotation.multiplied(by: firstScale).multiplied(by: secondScale)
    }
    return Quaternion(
      real: .sinh(q.real) * .cos(θ),
      imaginary: n̂ * .cosh(q.real) * .sin(θ)
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

  }
}
