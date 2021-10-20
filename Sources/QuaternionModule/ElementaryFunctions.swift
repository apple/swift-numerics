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

// (r + xi + yj + zk) is a common representation that is often seen for
// quaternions. However, when we want to expand the elementary functions of
// quaternions in terms of real operations it is almost always easier to view
// them as real part (r) and imaginary vector part (v),
// i.e: r + xi + yj + zk = r + v; and so we diverge a little from the
// representation that is used in the documentation in other files and use this
// notation of quaternions in the comments of the following functions.
//
// Quaternionic elementary functions have many similarities with elementary
// functions of complex numbers and their definition in terms of real
// operations. Therefore, if you make a modification to one of the following
// functions, you should almost surely make a parallel modification to the same
// elementary function of complex numbers.

import RealModule

extension Quaternion/*: ElementaryFunctions */ {

  // MARK: - exp-like functions
  @inlinable
  public static func exp(_ q: Quaternion) -> Quaternion {
    // Mathematically, this operation can be expanded in terms of the `Real`
    // operations `exp`, `cos` and `sin` as follows (`let θ = ||v||`):
    //
    // ```
    // exp(r + v) = exp(r) exp(v)
    //            = exp(r) (cos(θ) + (v/θ) sin(θ))
    // ```
    //
    // Note that naive evaluation of this expression in floating-point would be
    // prone to premature overflow, since `cos` and `sin` both have magnitude
    // less than 1 for most inputs (i.e. `exp(r)` may be infinity when
    // `exp(r) cos(||v||)` would not be.
    guard q.isFinite else { return q }
    let (â, θ) = q.imaginary.unitAxisAndLength
    let rotation = Quaternion(halfAngle: θ, unitAxis: â)
    // If real < log(greatestFiniteMagnitude), then exp(real) does not overflow.
    // To protect ourselves against sketchy log or exp implementations in
    // an unknown host library, or slight rounding disagreements between
    // the two, subtract one from the bound for a little safety margin.
    guard q.real < RealType.log(.greatestFiniteMagnitude) - 1 else {
      let halfScale = RealType.exp(q.real/2)
      return rotation.multiplied(by: halfScale).multiplied(by: halfScale)
    }
    return rotation.multiplied(by: .exp(q.real))
  }

  @inlinable
  public static func expMinusOne(_ q: Quaternion) -> Quaternion {
    // Mathematically, this operation can be expanded in terms of the `Real`
    // operations `exp`, `cos` and `sin` as follows (`let θ = ||v||`):
    //
    // ```
    // exp(r + v) - 1 = exp(r) exp(v) - 1
    //                = exp(r) (cos(θ) + (v/θ) sin(θ)) - 1
    //                = exp(r) cos(θ) + exp(r) (v/θ) sin(θ) - 1
    //                = (exp(r) cos(θ) - 1) + exp(r) (v/θ) sin(θ)
    //                  -------- u --------
    // ```
    //
    // Note that the imaginary part is just the usual exp(x) sin(y);
    // the only trick is computing the real part ("u"):
    //
    // ```
    // u = exp(r) cos(θ) - 1
    //   = exp(r) cos(θ) - cos(θ) + cos(θ) - 1
    //   = (exp(r) - 1) cos(θ) + (cos(θ) - 1)
    //   = expMinusOne(r) cos(θ) + cosMinusOne(θ)
    // ```
    //
    // See `expMinusOne` on complex numbers for error bounds.
    guard q.isFinite else { return q }
    let (â, θ) = q.imaginary.unitAxisAndLength
    // If exp(q) is close to the overflow boundary, we don't need to
    // worry about the "MinusOne" part of this function; we're just
    // computing exp(q). (Even when θ is near a multiple of π/2,
    // it can't be close enough to overcome the scaling from exp(r),
    // so the -1 term is _always_ negligable).
    guard q.real < RealType.log(.greatestFiniteMagnitude) - 1 else {
      let halfScale = RealType.exp(q.real/2)
      let rotation = Quaternion(halfAngle: θ, unitAxis: â)
      return rotation.multiplied(by: halfScale).multiplied(by: halfScale)
    }
    return Quaternion(
      real: RealType._mulAdd(.cos(θ), .expMinusOne(q.real), .cosMinusOne(θ)),
      imaginary: â * .exp(q.real) * .sin(θ)
    )
  }

  @inlinable
  public static func cosh(_ q: Quaternion) -> Quaternion {
    // Mathematically, this operation can be expanded in terms of
    // trigonometric `Real` operations as follows (`let θ = ||v||`):
    //
    // ```
    // cosh(q) = (exp(q) + exp(-q)) / 2
    //         = cosh(r) cos(θ) + (v/θ) sinh(r) sin(θ)
    // ```
    //
    // Like exp, cosh is entire, so we do not need to worry about where
    // branch cuts fall. Also like exp, cancellation never occurs in the
    // evaluation of the naive expression, so all we need to be careful
    // about is the behavior near the overflow boundary.
    //
    // Fortunately, if |r| >= -log(ulpOfOne), cosh(r) and sinh(r) are
    // both just exp(|r|)/2, and we already know how to compute that.
    //
    // This function and sinh should stay in sync; if you make a
    // modification here, you should almost surely make a parallel
    // modification to sinh below.
    guard q.isFinite else { return q }
    let (â, θ) = q.imaginary.unitAxisAndLength
    guard q.real.magnitude < -RealType.log(.ulpOfOne) else {
      let rotation = Quaternion(halfAngle: θ, unitAxis: â)
      let firstScale = RealType.exp(q.real.magnitude/2)
      return rotation.multiplied(by: firstScale).multiplied(by: firstScale/2)
    }
    return Quaternion(
      real: .cosh(q.real) * .cos(θ),
      imaginary: â * .sinh(q.real) * .sin(θ)
    )
  }

  @inlinable
  public static func sinh(_ q: Quaternion) -> Quaternion {
    // Mathematically, this operation can be expanded in terms of
    // trigonometric `Real` operations as follows (`let θ = ||v||`):
    //
    // ```
    // sinh(q) = (exp(q) - exp(-q)) / 2
    //         = sinh(r) cos(θ) + (v/θ) cosh(r) sin(θ)
    // ```
    guard q.isFinite else { return q }
    let (â, θ) = q.imaginary.unitAxisAndLength
    guard q.real.magnitude < -RealType.log(.ulpOfOne) else {
      let rotation = Quaternion(halfAngle: θ, unitAxis: â)
      let firstScale = RealType.exp(q.real.magnitude/2)
      let secondScale = RealType(signOf: q.real, magnitudeOf: firstScale/2)
      return rotation.multiplied(by: firstScale).multiplied(by: secondScale)
    }
    return Quaternion(
      real: .sinh(q.real) * .cos(θ),
      imaginary: â * .cosh(q.real) * .sin(θ)
    )
  }

  @inlinable
  public static func tanh(_ q: Quaternion) -> Quaternion {
    // Mathematically, this operation can be expanded in terms of
    // trigonometric `Real` operations as follows (`let θ = ||v||`):
    //
    // ```
    // tanh(q) = sinh(q) / cosh(q)
    // ```
    guard q.isFinite else { return q }
    // Note that when |r| is larger than -log(.ulpOfOne),
    // sinh(r + v) == ±cosh(r + v), so tanh(r + v) is just ±1.
    guard q.real.magnitude < -RealType.log(.ulpOfOne) else {
      return Quaternion(
        real: RealType(signOf: q.real, magnitudeOf: 1),
        imaginary:
          RealType(signOf: q.components.x, magnitudeOf: 0),
          RealType(signOf: q.components.y, magnitudeOf: 0),
          RealType(signOf: q.components.z, magnitudeOf: 0)
      )
    }
    return sinh(q) / cosh(q)
  }

  @inlinable
  public static func cos(_ q: Quaternion) -> Quaternion {
    // cos(q) = cosh(q * (v/θ)))
    let (â,_) = q.imaginary.unitAxisAndLength
    let p = Quaternion(imaginary: â)
    return cosh(q * p)
  }

  @inlinable
  public static func sin(_ q: Quaternion) -> Quaternion {
    // sin(q) = -(v/θ) * sinh(q * (v/θ)))
    let (â,_) = q.imaginary.unitAxisAndLength
    let p = Quaternion(imaginary: â)
    return -p * sinh(q * p)
  }

  @inlinable
  public static func tan(_ q: Quaternion) -> Quaternion {
    // tan(q) = -(v/θ) * tanh(q * (v/θ)))
    let (â,_) = q.imaginary.unitAxisAndLength
    let p = Quaternion(imaginary: â)
    return -p * tanh(q * p)
  }
}

extension SIMD3 where Scalar: FloatingPoint {

  /// Returns the normalized axis and the length of this vector.
  @usableFromInline @inline(__always)
  internal var unitAxisAndLength: (Self, Scalar) {
    if self == .zero {
      return (SIMD3(
        Scalar(signOf: x, magnitudeOf: 0),
        Scalar(signOf: y, magnitudeOf: 0),
        Scalar(signOf: z, magnitudeOf: 0)
      ), .zero)
    }
    return (self/length, length)
  }
}
