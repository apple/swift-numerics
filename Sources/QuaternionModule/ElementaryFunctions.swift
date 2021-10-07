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

extension Quaternion/*: ElementaryFunctions */ {

  // MARK: - exp-like functions

  /// The quaternion exponential function e^q whose base `e` is the base of the
  /// natural logarithm.
  ///
  /// Mathematically, this operation can be expanded in terms of the `Real`
  /// operations `exp`, `cos` and `sin` as follows:
  /// ```
  /// exp(r + xi + yj + zk) = exp(r + v) = exp(r) exp(v)
  ///                       = exp(r) (cos(θ) + (v/θ) sin(θ)) where θ = ||v||
  /// ```
  /// Note that naive evaluation of this expression in floating-point would be
  /// prone to premature overflow, since `cos` and `sin` both have magnitude
  /// less than 1 for most inputs (i.e. `exp(r)` may be infinity when
  /// `exp(r) cos(θ)` would not be).
  public static func exp(_ q: Quaternion<RealType>) -> Quaternion<RealType> {
    guard q.isFinite else { return q }
    // Firstly evaluate θ and v/θ where θ = ||v|| (as discussed above)
    // There are 2 special cases for ||v|| that we need to take care of:
    // The value of ||v|| may be invalid due to an overflow in `.lengthSquared`.
    // As the internal `SIMD3.length` helper functions deals with overflow and
    // underflow of `.lengthSquared`, we can safely ignore this case here.
    // However, we still have to check for ||v|| = 0 before evaluating v/θ
    // as it would incorrectly yield a division by zero.
    let phase = q.imaginary.length
    let unitAxis = !phase.isZero ? (q.imaginary / phase) : .zero
    // If real < log(greatestFiniteMagnitude), then exp(q.real) does not overflow.
    // To protect ourselves against sketchy log or exp implementations in
    // an unknown host library, or slight rounding disagreements between
    // the two, subtract one from the bound for a little safety margin.
    guard q.real < RealType.log(.greatestFiniteMagnitude) - 1 else {
      let halfScale = RealType.exp(q.real/2)
      let rotation = Quaternion(
        halfAngle: phase,
        unitAxis: unitAxis
      )
      return rotation.multiplied(by: halfScale).multiplied(by: halfScale)
    }
    return Quaternion(
      halfAngle: phase,
      unitAxis: unitAxis
    ).multiplied(by: .exp(q.real))
  }
}
