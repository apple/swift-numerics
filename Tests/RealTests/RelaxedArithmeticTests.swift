//===--- RelaxedArithmeticTests.swift -------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import RealModule
import _TestSupport
#if canImport(Accelerate)
import Accelerate
#endif

#if !DEBUG
func strictSum<T: Real>(_ array: [T]) -> T {
  array.reduce(0, +)
}

func relaxedSum<T: Real>(_ array: [T]) -> T {
  array.reduce(0, Relaxed.sum)
}

func strictSumOfSquares<T: Real>(_ array: [T]) -> T {
  array.reduce(0) { $0 + $1*$1 }
}

func relaxedSumOfSquares<T: Real>(_ array: [T]) -> T {
  array.reduce(0) { Relaxed.multiplyAdd($1, $1, $0) }
}

// TODO: not a great harness, but making it better bumps up against the
// limitations of what XCT measure { } lets us do easily. Good enough for now.
func benchmarkReduction(_ data: [Float], _ reduction: ([Float]) -> Float) {
  var accum: Float = 0
  let iters = 100_000
  for _ in 0 ..< iters {
    accum += reduction(data)
  }
  blackHole(accum)
}

final class RelaxedArithmeticTests: XCTestCase {
  
  var floatData: [Float] = []
  
  override func setUp() {
    super.setUp()
    floatData = (0 ..< 1024).map { _ in .random(in: .sqrt(1/2) ..< .sqrt(2)) }
  }
  
  func testStrictSumPerformance() {
    measure { benchmarkReduction(floatData, strictSum) }
  }
  
  func testRelaxedSumPerformance() {
    // Performance of this should be closer to vDSP.sum than to
    // strict sum
    measure { benchmarkReduction(floatData, relaxedSum) }
  }
  
#if canImport(Accelerate)
  func testvDSPSumPerformance() {
    measure { benchmarkReduction(floatData, vDSP.sum) }
  }
#endif
  
  func testStrictDotPerformance() {
    measure { benchmarkReduction(floatData, strictSumOfSquares) }
  }
  
  func testRelaxedDotPerformance() {
    // Performance of this should be closer to vDSP.sumOfSquares than to
    // strict sumOfSquares
    measure { benchmarkReduction(floatData, relaxedSumOfSquares) }
  }
  
#if canImport(Accelerate)
  func testvDSPDotPerformance() {
    measure { benchmarkReduction(floatData, vDSP.sumOfSquares) }
  }
#endif
  
  func testRelaxedArithmetic<T: FixedWidthFloatingPoint & Real>(_ type: T.Type) {
    // Relaxed add is still an add; it's just permitted to reorder relative
    // to other adds or form FMAs. So if we do one in isolation, it has to
    // produce the same result as a normal addition.
    let a = T.random(in: -1 ... 1)
    let b = T.random(in: -1 ... 1)
    XCTAssertEqual(a + b, Relaxed.sum(a, b))
    // Same is true for mul.
    XCTAssertEqual(a * b, Relaxed.product(a, b))
    // add + mul must be either two operations or an FMA:
    let unfused = a + 1.5 * b
    let fused = a.addingProduct(1.5, b)
    let relaxed = Relaxed.multiplyAdd(1.5, b, a)
    XCTAssert(relaxed == unfused || relaxed == fused)
    // Summing all values in an array can be associated however we want, but
    // has to satisfy the usual error bound of 0.5 * sum.ulp * numberOfElements.
    // We don't have a golden reference, but we can compare two sums with twice
    // the bound for a basic check.
    let array = (0 ..< 128).map { _ in T.random(in: 1 ..< 2) }
    var ref = strictSum(array)
    var tst = relaxedSum(array)
    var bound = max(ref, tst).ulp * T(array.count)
    XCTAssertLessThanOrEqual(abs(ref - tst), bound)
    // Similarly for sum of squares ...
    ref = strictSumOfSquares(array)
    tst = relaxedSumOfSquares(array)
    bound = 2 * max(ref, tst).ulp * T(array.count)
    XCTAssertLessThanOrEqual(abs(ref - tst), bound)
  }
  
  func testRelaxedArithmetic() {
#if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
    testRelaxedArithmetic(Float16.self)
#endif
    testRelaxedArithmetic(Float.self)
    testRelaxedArithmetic(Double.self)
#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    testRelaxedArithmetic(Float80.self)
#endif
  }
}
#endif
