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

  // MARK: - log-like functions
  @inlinable
  public static func log(_ q: Quaternion) -> Quaternion {
    // If q is zero or infinite, the phase is undefined, so the result is
    // the single exceptional value.
    guard q.isFinite && !q.isZero else { return .infinity }

    let argument = q.imaginary.length
    let axis = q.imaginary / argument

    // We deliberatly choose log(length) over the (faster)
    // log(lengthSquared) / 2 which is used for complex numbers; as
    // the squared length of quaternions is more prone to overflows than the
    // squared length of complex numbers.
    return Quaternion(real: .log(q.length), imaginary: axis * q.halfAngle)
  }

  @inlinable
  public static func log(onePlus q: Quaternion) -> Quaternion {
    // If either |r| or ||v||₁ is bounded away from the origin, we don't need
    // any extra precision, and can just literally compute log(1+z). Note
    // that this includes part of the sphere |1+q| = 1 where log(onePlus:)
    // vanishes (where r <= -0.5), but on this portion of the sphere 1+r
    // is always exact by Sterbenz' lemma, so as long as log( ) produces
    // a good result, log(1+q) will too.
    guard 2*q.real.magnitude < 1 && q.imaginary.oneNorm < 1 else {
      return log(.one + q)
    }
    // q is in (±0.5, ±1), so we need to evaluate more carefully.
    // The imaginary part is straightforward:
    let argument = (.one + q).halfAngle
    let (â,_) = q.imaginary.unitAxisAndLength
    let imaginary = â * argument
    // For the real part, we _could_ use the same approach that we do for
    // log( ), but we'd need an extra-precise (1+r)², which can potentially
    // be quite painful to calculate. Instead, we can use an approach that
    // NevinBR suggested on the Swift forums for complex numbers:
    //
    //     Re(log 1+q) = (log 1+q + log 1+q̅)/2
    //                 = log((1+q)(1+q̅)/2
    //                 = log(1 + q + q̅ + qq̅)/2
    //                 = log1p((2+r)r + x² + y² + z²)/2
    //
    // So now we need to evaluate (2+r)r + x² + y² + z² accurately. To do this,
    // we employ augmented arithmetic;
    // (2+r)r + x² + y² + z²
    //  --↓--
    let rp2 = Augmented.fastTwoSum(2, q.real) // Known that 2 > |r|
    var (head, δ) = Augmented.twoProdFMA(q.real, rp2.head)
    var tail = δ
    // head + x² + y² + z²
    // ----↓----
    let x² = Augmented.twoProdFMA(q.imaginary.x, q.imaginary.x)
    (head, δ) = Augmented.twoSum(head, x².head)
    tail += (δ + x².tail)
    // head + y² + z²
    // ----↓----
    let y² = Augmented.twoProdFMA(q.imaginary.y, q.imaginary.y)
    (head, δ) = Augmented.twoSum(head, y².head)
    tail += (δ + y².tail)
    // head + z²
    // ----↓----
    let z² = Augmented.twoProdFMA(q.imaginary.z, q.imaginary.z)
    (head, δ) = Augmented.twoSum(head, z².head)
    tail += (δ + z².tail)

    let s = (head + tail).addingProduct(q.real, rp2.tail)
    return Quaternion(real: .log(onePlus: s)/2, imaginary: imaginary)
  }

  //
  // MARK: - pow-like functions

  @inlinable
  public static func pow(_ q: Quaternion, _ p: Quaternion) -> Quaternion {
    // Mathematically, this operation can be expanded in terms of the
    // quaternionic `exp` and `log` operations as follows:
    //
    // ```
    // pow(q, p) = exp(log(pow(q, p)))
    //           = exp(p * log(q))
    // ```
    exp(p * log(q))
  }

  @inlinable
  public static func pow(_ q: Quaternion, _ n: Int) -> Quaternion {
    // Mathematically, this operation can be expanded in terms of the
    // quaternionic `exp` and `log` operations as follows:
    //
    // ```
    // pow(q, n) = exp(log(pow(q, n)))
    //           = exp(log(q) * n)
    // ```
    guard !q.isZero else { return .zero }
    // TODO: this implementation is not quite correct, because n may be
    // rounded in conversion to RealType. This only effects very extreme
    // cases, so we'll leave it alone for now.
    return exp(log(q).multiplied(by: RealType(n)))
  }

  @inlinable
  public static func sqrt(_ q: Quaternion) -> Quaternion<RealType> {
    // Mathematically, this operation can be expanded in terms of the
    // quaternionic `exp` and `log` operations as follows:
    //
    // ```
    // sqrt(q) = q^(1/2) = exp(log(q^(1/2)))
    //                   = exp(log(q) * (1/2))
    // ```
    guard !q.isZero else { return .zero }
    return exp(log(q).divided(by: 2))
  }

  @inlinable
  public static func root(_ q: Quaternion, _ n: Int) -> Quaternion {
    // Mathematically, this operation can be expanded in terms of the
    // quaternionic `exp` and `log` operations as follows:
    //
    // ```
    // root(q, n) = exp(log(root(q, n)))
    //            = exp(log(q) / n)
    // ```
    guard !q.isZero else { return .zero }
    // TODO: this implementation is not quite correct, because n may be
    // rounded in conversion to RealType. This only effects very extreme
    // cases, so we'll leave it alone for now.
    return exp(log(q).divided(by: RealType(n)))
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

extension Augmented {

  // TODO: Move to Augmented.swift
  @usableFromInline @_transparent
  internal static func twoSum<T:Real>(_ a: T, _ b: T) -> (head: T, tail: T) {
    let head = a + b
    let x = head - b
    let y = head - x
    let ax = a - x
    let by = b - y
    let tail = ax + by
    return (head, tail)
  }
}
