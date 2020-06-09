//===--- PolarTests.swift -------------------------------------*- swift -*-===//
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

  func testAngleAxisSpin<T: Real & SIMDScalar>(_ type: T.Type) {
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

  func testAngleAxisSpin() {
    testAngleAxisSpin(Float32.self)
    testAngleAxisSpin(Float64.self)
  }

  func testAngleMultipleOfPi<T: Real & SIMDScalar>(_ type: T.Type) {
    let xAxis = SIMD3<T>(1,0,0)
    // 2π
    let pi2 = Quaternion<T>(angle: .pi * 2, axis: xAxis)
    XCTAssertEqual(pi2.angle, .pi * 2)
    XCTAssertEqual(pi2.axis, xAxis)
    // 3π - axis inverted
    let pi3 = Quaternion<T>(angle: .pi * 3, axis: xAxis)
    XCTAssertEqual(pi3.angle, .pi, accuracy: .ulpOfOne * 2)
    XCTAssertEqual(pi3.axis, -xAxis)
    // 4π - axis inverted
    let pi4 = Quaternion<T>(angle: .pi * 4, axis: xAxis)
    XCTAssertEqual(pi4.angle, .zero, accuracy: .ulpOfOne * 6)
    XCTAssertEqual(pi4.axis, -xAxis)
    // 5π - axis restored
    let pi5 = Quaternion<T>(angle: .pi * 5, axis: xAxis)
    XCTAssertEqual(pi5.angle, .pi, accuracy: .ulpOfOne * 10)
    XCTAssertEqual(pi5.axis, xAxis)
  }

  func testAngleMultipleOfPi() {
    testAngleMultipleOfPi(Float32.self)
    testAngleMultipleOfPi(Float64.self)
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
}

// Helper
extension SIMD3 where Scalar: FloatingPoint {
  fileprivate static var infinity: Self { SIMD3(.infinity,0,0) }
  fileprivate static var nan: Self { SIMD3(.nan,0,0) }
  fileprivate var isNaN: Bool { x.isNaN && y.isNaN && z.isNaN }
}
