//===--- TransformationTests.swift ----------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import RealModule

@testable import QuaternionModule

final class TransformationTests: XCTestCase {

  // MARK: Angle/Axis

  func testAngleAxis<T: Real & SIMDScalar>(_ type: T.Type) {
    let xAxis = SIMD3<T>(1,0,0)
    // Positive angle, positive axis
    XCTAssertEqual(Quaternion<T>(angle: .pi, axis: xAxis).angle, .pi)
    XCTAssertEqual(Quaternion<T>(angle: .pi, axis: xAxis).axis, xAxis)
    // Negative angle, positive axis
    XCTAssertEqual(Quaternion<T>(angle: -.pi, axis: xAxis).angle, .pi)
    XCTAssertEqual(Quaternion<T>(angle: -.pi, axis: xAxis).axis, -xAxis)
    // Positive angle, negative axis
    XCTAssertEqual(Quaternion<T>(angle: .pi, axis: -xAxis).angle, .pi)
    XCTAssertEqual(Quaternion<T>(angle: .pi, axis: -xAxis).axis, -xAxis)
    // Negative angle, negative axis
    XCTAssertEqual(Quaternion<T>.init(angle: -.pi, axis: -xAxis).angle, .pi)
    XCTAssertEqual(Quaternion<T>.init(angle: -.pi, axis: -xAxis).axis, xAxis)
  }

  func testAngleAxis() {
    testAngleAxis(Float32.self)
    testAngleAxis(Float64.self)
  }

  func testAngleAxisMultipleOfPi<T: Real & SIMDScalar>(_ type: T.Type) {
    let xAxis = SIMD3<T>(1,0,0)
    // 2π
    let pi2 = Quaternion<T>(angle: .pi * 2, axis: xAxis)
    XCTAssertEqual(pi2.angle, .pi * 2)
    XCTAssertEqual(pi2.axis, xAxis)
    // 3π - axis inverted
    let pi3 = Quaternion<T>(angle: .pi * 3, axis: xAxis)
    XCTAssertTrue(closeEnough(pi3.angle, .pi, ulps: 1))
    XCTAssertEqual(pi3.axis, -xAxis)
    // 5π - axis restored
    let pi5 = Quaternion<T>(angle: .pi * 5, axis: xAxis)
    XCTAssertTrue(closeEnough(pi5.angle, .pi, ulps: 5))
    XCTAssertEqual(pi5.axis, xAxis)
  }

  func testAngleAxisMultipleOfPi() {
    testAngleAxisMultipleOfPi(Float32.self)
    testAngleAxisMultipleOfPi(Float64.self)
  }

  func testAngleAxisEdgeCases<T: Real & SIMDScalar>(_ type: T.Type) {
    // Zero/Zero
    XCTAssertTrue(Quaternion<T>(angle: .zero, axis: .zero).axis.isNaN)
    XCTAssertTrue(Quaternion<T>(angle: .zero, axis: .zero).angle.isNaN)
    XCTAssertEqual(Quaternion<T>(angle: .zero, axis: .zero), .zero)
    // Inf/Zero
    XCTAssertTrue(Quaternion<T>(angle: .infinity, axis: .zero).axis.isNaN)
    XCTAssertTrue(Quaternion<T>(angle: .infinity, axis: .zero).angle.isNaN)
    XCTAssertEqual(Quaternion<T>(angle: .infinity, axis: .zero), .zero)
    // -Inf/Zero
    XCTAssertTrue(Quaternion<T>(angle: -.infinity, axis: .zero).axis.isNaN)
    XCTAssertTrue(Quaternion<T>(angle: -.infinity, axis: .zero).angle.isNaN)
    XCTAssertEqual(Quaternion<T>(angle: -.infinity, axis: .zero), .zero)
    // NaN/Zero
    XCTAssertTrue(Quaternion<T>(angle: .nan, axis: .zero).axis.isNaN)
    XCTAssertTrue(Quaternion<T>(angle: .nan, axis: .zero).angle.isNaN)
    XCTAssertEqual(Quaternion<T>(angle: .nan, axis: .zero), .zero)
    // Zero/Inf
    XCTAssertTrue(Quaternion<T>(angle: .zero, axis: .infinity).axis.isNaN)
    XCTAssertTrue(Quaternion<T>(angle: .zero, axis: .infinity).angle.isNaN)
    XCTAssertEqual(Quaternion<T>(angle: .zero, axis: .infinity), .infinity)
    // Inf/Inf
    XCTAssertTrue(Quaternion<T>(angle: .infinity, axis: .infinity).axis.isNaN)
    XCTAssertTrue(Quaternion<T>(angle: .infinity, axis: .infinity).angle.isNaN)
    XCTAssertEqual(Quaternion<T>(angle: .infinity, axis: .infinity), .infinity)
    // -Inf/Inf
    XCTAssertTrue(Quaternion<T>(angle: -.infinity, axis: .infinity).axis.isNaN)
    XCTAssertTrue(Quaternion<T>(angle: -.infinity, axis: .infinity).angle.isNaN)
    XCTAssertEqual(Quaternion<T>(angle: -.infinity, axis: .infinity), .infinity)
    // NaN/Inf
    XCTAssertTrue(Quaternion<T>(angle: .nan, axis: .infinity).axis.isNaN)
    XCTAssertTrue(Quaternion<T>(angle: .nan, axis: .infinity).angle.isNaN)
    XCTAssertEqual(Quaternion<T>(angle: .nan, axis: .infinity), .infinity)
    // Zero/-Inf
    XCTAssertTrue(Quaternion<T>(angle: .zero, axis: -.infinity).axis.isNaN)
    XCTAssertTrue(Quaternion<T>(angle: .zero, axis: -.infinity).angle.isNaN)
    XCTAssertEqual(Quaternion<T>(angle: .zero, axis: -.infinity), .infinity)
    // Inf/-Inf
    XCTAssertTrue(Quaternion<T>(angle: .infinity, axis: -.infinity).axis.isNaN)
    XCTAssertTrue(Quaternion<T>(angle: .infinity, axis: -.infinity).angle.isNaN)
    XCTAssertEqual(Quaternion<T>(angle: .infinity, axis: -.infinity), .infinity)
    // -Inf/-Inf
    XCTAssertTrue(Quaternion<T>(angle: -.infinity, axis: -.infinity).axis.isNaN)
    XCTAssertTrue(Quaternion<T>(angle: -.infinity, axis: -.infinity).angle.isNaN)
    XCTAssertEqual(Quaternion<T>(angle: -.infinity, axis: -.infinity), .infinity)
    // NaN/-Inf
    XCTAssertTrue(Quaternion<T>(angle: .nan, axis: -.infinity).axis.isNaN)
    XCTAssertTrue(Quaternion<T>(angle: .nan, axis: -.infinity).angle.isNaN)
    XCTAssertEqual(Quaternion<T>(angle: .nan, axis: -.infinity), .infinity)
  }

  func testAngleAxisEdgeCases() {
    testAngleAxisEdgeCases(Float32.self)
    testAngleAxisEdgeCases(Float64.self)
  }

  // MARK: Rotation Vector

  func testRotationVector<T: Real & SIMDScalar>(_ type: T.Type) {
    let vector = SIMD3<T>(0,-1,0) * .pi
    XCTAssertEqual(Quaternion<T>(rotation: vector).rotationVector.x,  .zero)
    XCTAssertEqual(Quaternion<T>(rotation: vector).rotationVector.y, -.pi)
    XCTAssertEqual(Quaternion<T>(rotation: vector).rotationVector.z,  .zero)

    XCTAssertEqual(Quaternion<T>(rotation: vector).axis, SIMD3(0,-1,0))
    XCTAssertEqual(Quaternion<T>(rotation: vector).angle, .pi)
  }

  func testRotationVector() {
    testRotationVector(Float32.self)
    testRotationVector(Float64.self)
  }

  func testRotationVectorEdgeCases<T: Real & SIMDScalar>(_ type: T.Type) {
    XCTAssertEqual(Quaternion<T>(rotation: .zero), .zero)
    XCTAssertEqual(Quaternion<T>(rotation: .infinity), .infinity)
    XCTAssertEqual(Quaternion<T>(rotation: -.infinity), .infinity)
    XCTAssertTrue(Quaternion<T>(rotation: .nan).real.isNaN)
    XCTAssertTrue(Quaternion<T>(rotation: .nan).imaginary.isNaN)
  }

  func testRotationVectorEdgeCases() {
    testRotationVectorEdgeCases(Float32.self)
    testRotationVectorEdgeCases(Float64.self)
  }

  // MARK: Polar Decomposition

  func testPolarDecomposition<T: Real & SIMDScalar>(_ type: T.Type) {
    let axis = SIMD3<T>(0,-1,0)

    let q = Quaternion<T>(length: 5, halfAngle: .pi, axis: axis)
    XCTAssertEqual(q.axis, axis)
    XCTAssertEqual(q.angle, .pi * 2)

    XCTAssertEqual(q.polar.length, 5)
    XCTAssertEqual(q.polar.halfAngle, .pi)
    XCTAssertEqual(q.polar.axis, axis)
  }

  func testPolarDecomposition() {
    testPolarDecomposition(Float32.self)
    testPolarDecomposition(Float64.self)
  }

  func testPolarDecompositionEdgeCases<T: Real & SIMDScalar>(_ type: T.Type) {
    XCTAssertEqual(Quaternion<T>(length: .zero, halfAngle: .infinity, axis:  .infinity), .zero)
    XCTAssertEqual(Quaternion<T>(length: .zero, halfAngle:-.infinity, axis: -.infinity), .zero)
    XCTAssertEqual(Quaternion<T>(length: .zero, halfAngle: .nan     , axis:  .nan     ), .zero)
    XCTAssertEqual(Quaternion<T>(length: .infinity, halfAngle: .infinity, axis:  .infinity), .infinity)
    XCTAssertEqual(Quaternion<T>(length: .infinity, halfAngle:-.infinity, axis: -.infinity), .infinity)
    XCTAssertEqual(Quaternion<T>(length: .infinity, halfAngle: .nan     , axis:  .infinity), .infinity)
    XCTAssertEqual(Quaternion<T>(length:-.infinity, halfAngle: .infinity, axis:  .infinity), .infinity)
    XCTAssertEqual(Quaternion<T>(length:-.infinity, halfAngle:-.infinity, axis: -.infinity), .infinity)
    XCTAssertEqual(Quaternion<T>(length:-.infinity, halfAngle: .nan     , axis:  .infinity), .infinity)
  }

  func testPolarDecompositionEdgeCases() {
    testPolarDecompositionEdgeCases(Float32.self)
    testPolarDecompositionEdgeCases(Float64.self)
  }

  // MARK: Act on Vector

  func testActOnVector<T: Real & SIMDScalar>(_ type: T.Type) {
    let vector = SIMD3<T>(1,1,1)
    let xAxis = SIMD3<T>(1,0,0)

    let piHalf = Quaternion<T>(angle: .pi/2, axis: xAxis)
    XCTAssertTrue(closeEnough(piHalf.act(on: vector).x,  1, ulps: 0))
    XCTAssertTrue(closeEnough(piHalf.act(on: vector).y, -1, ulps: 1))
    XCTAssertTrue(closeEnough(piHalf.act(on: vector).z,  1, ulps: 1))

    let pi = Quaternion<T>(angle: .pi, axis: xAxis)
    XCTAssertTrue(closeEnough(pi.act(on: vector).x,  1, ulps: 0))
    XCTAssertTrue(closeEnough(pi.act(on: vector).y, -1, ulps: 2))
    XCTAssertTrue(closeEnough(pi.act(on: vector).z, -1, ulps: 2))

    let twoPi = Quaternion<T>(angle: .pi * 2, axis: xAxis)
    XCTAssertTrue(closeEnough(twoPi.act(on: vector).x,  1, ulps: 0))
    XCTAssertTrue(closeEnough(twoPi.act(on: vector).y,  1, ulps: 3))
    XCTAssertTrue(closeEnough(twoPi.act(on: vector).z,  1, ulps: 3))
  }

  func testActOnVector() {
    testActOnVector(Float32.self)
    testActOnVector(Float64.self)
  }

  func testActOnVectorRandom<T>(_ type: T.Type)
    where T: Real, T: BinaryFloatingPoint, T: SIMDScalar,
    T.Exponent: FixedWidthInteger, T.RawSignificand: FixedWidthInteger
  {
    // Generate random angles, axis and vector to test rotation properties
    // - angle are selected from range -π to π
    // - axis values are selected from -1 to 1; axis length is unity
    // - vector values are selected from 10 to 10000
    let inputs: [(angle: T, axis: SIMD3<T>, vector: SIMD3<T>)] = (0..<100).map { _ in
      let angle = T.random(in: -.pi ... .pi)
      var axis = SIMD3<T>.random(in: -1 ... 1)
      axis /= .sqrt((axis * axis).sum()) // Normalize
      var vector = SIMD3<T>.random(in: -1 ... 1)
      vector /= .sqrt((vector * vector).sum()) // Normalize
      vector *= T.random(in: 10 ... 10000)     // Scale
      return (angle, axis, vector)
    }

    for (angle, axis, vector) in inputs {
      let q = Quaternion(angle: angle, axis: axis)
      // The following equation in the form of v' = qvq⁻¹ is the mathmatical
      // definition for how a quaternion rotates a vector (by promoting it to
      // a quaternion) and goes "the full and long way" to calculate the
      // rotation of vector by a quaternion. The result is used to test the
      // rotation properties of "act(on:)"
      let vrot = (q                     // q
        * Quaternion(imaginary: vector) // v   (pure quaternion)
        * q.conjugate                   // q⁻¹ (as q is of unit length, q⁻¹ == q*)
      ).imaginary // the result is a pure quaternion with v' == imaginary

      XCTAssertTrue(q.act(on: vector).x.isFinite)
      XCTAssertTrue(q.act(on: vector).y.isFinite)
      XCTAssertTrue(q.act(on: vector).z.isFinite)
      // Test for sign equality on the components to see if the vector rotated
      // to the correct quadrant and if the vector is of equal length, instead
      // of testing component equality – as they are hard to compare with
      // proper tolerance
      XCTAssertEqual(q.act(on: vector).x.sign, vrot.x.sign)
      XCTAssertEqual(q.act(on: vector).y.sign, vrot.y.sign)
      XCTAssertEqual(q.act(on: vector).z.sign, vrot.z.sign)
      XCTAssertTrue(closeEnough(q.act(on: vector).lengthSquared, vrot.lengthSquared, ulps: 16))
    }
  }

  func testActOnVectorRandom() {
    testActOnVectorRandom(Float32.self)
    testActOnVectorRandom(Float64.self)
  }

  func testActOnVectorEdgeCase<T: Real & ExpressibleByFloatLiteral & SIMDScalar>(_ type: T.Type) {

    /// Test for zero, infinity
    let q = Quaternion(angle: .pi, axis: SIMD3(1,0,0))
    XCTAssertEqual(q.act(on:  .zero), .zero)
    XCTAssertEqual(q.act(on: -.zero), .zero)
    XCTAssertEqual(q.act(on:  .infinity), SIMD3(repeating: .infinity))
    XCTAssertEqual(q.act(on: -.infinity), SIMD3(repeating: .infinity))

    // Rotate a vector with a value close to greatestFiniteMagnitude
    // in all lanes.
    // A vector this close to the bounds should not hit infinity when it
    // is rotate by a perpendicular axis with an angle that is a multiple of π

    // An axis perpendicular to the vector, so all lanes are changing equally
    let axis = SIMD3<T>(1/2,0,-1/2)
    // Create a value (somewhat) close to .greatestFiniteMagnitude
    let scalar = T(
      sign: .plus, exponent: T.greatestFiniteMagnitude.exponent,
      significand: 1.999999
    )

    let closeToBounds = SIMD3<T>(repeating: scalar)

    // Perform a 180° rotation on all components
    let pi = Quaternion(angle: .pi, axis: axis).act(on: closeToBounds)
    // Must be finite after the rotation
    XCTAssertTrue(pi.x.isFinite)
    XCTAssertTrue(pi.y.isFinite)
    XCTAssertTrue(pi.z.isFinite)
    XCTAssertTrue(closeEnough(pi.x, -scalar, ulps: 4))
    XCTAssertTrue(closeEnough(pi.y, -scalar, ulps: 4))
    XCTAssertTrue(closeEnough(pi.z, -scalar, ulps: 4))

    // Perform a 360° rotation on all components
    let twoPi = Quaternion(angle: 2 * .pi, axis: axis).act(on: closeToBounds)
    // Must still be finite after the process
    XCTAssertTrue(twoPi.x.isFinite)
    XCTAssertTrue(twoPi.y.isFinite)
    XCTAssertTrue(twoPi.z.isFinite)
    XCTAssertTrue(closeEnough(twoPi.x, scalar, ulps: 8))
    XCTAssertTrue(closeEnough(twoPi.y, scalar, ulps: 8))
    XCTAssertTrue(closeEnough(twoPi.z, scalar, ulps: 8))
  }

  func testActOnVectorEdgeCase() {
    testActOnVectorEdgeCase(Float32.self)
    testActOnVectorEdgeCase(Float64.self)
  }
}

// MARK: - Helper
extension SIMD3 where Scalar: FloatingPoint {
  fileprivate static var infinity: Self { SIMD3(.infinity,0,0) }
  fileprivate static var nan: Self { SIMD3(.nan,0,0) }
  fileprivate var isNaN: Bool { x.isNaN && y.isNaN && z.isNaN }
}

// TODO: replace with approximately equals
func closeEnough<T: Real>(_ a: T, _ b: T, ulps allowed: T) -> Bool {
  let scale = max(a.magnitude, b.magnitude, T.leastNormalMagnitude).ulp
  return (a - b).magnitude <= allowed * scale
}
