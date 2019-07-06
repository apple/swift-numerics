//===--- ComplexTests.swift -----------------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import XCTest
import Complex

final class ComplexTests: XCTestCase {
  
  // Double-precision test cases from Baudin & Smith's "A Robust Complex Division in Scilab".
  func testDivide_BaudinSmith() {
    XCTAssertEqual(Complex(1,1)/Complex(1, 0x1p1023),
                   Complex(0x1p-1023, -0x1p-1023))
    XCTAssertEqual(Complex(1,1)/Complex(0x1p-1023, 0x1p-1023),
                   Complex(0x1p1023))
    XCTAssertEqual(Complex(0x1p1023, 0x1p1023)/Complex(1,1),
                   Complex(0x1.0p1023))
    XCTAssertEqual(Complex(0x1p-347, 0x1p-54)/Complex(0x1p-1037, 0x1p-1058),
                   Complex(3.8981256045591133e289, 8.174961907852353577e295))
    XCTAssertEqual(Complex(0x1p-1074, 0x1p-1074)/Complex(0x1p-1073, 0x1p-1074),
                   Complex(0.6, 0.2))
    XCTAssertEqual(Complex(0x1p1015, 0x1p-989)/Complex(0x1p1023, 0x1p1023),
                   Complex(0.001953125, -0.001953125))
    XCTAssertEqual(Complex(0x1p-622, 0x1p-1071)/Complex(0x1p-343, 0x1p-798),
                   Complex(1.02951151789360578e-84, 6.97145987515076231e-220))
  }
  
  func testDivide_BaudinSmithApprox() {
    // Policy: we deliberately do not try to get these cases from Baudin and
    // Smith "right"; instead we simply want an answer that's as accurate
    // (in the complex norm) as can be expected. We don't care what happens
    // to the tiny component of the result.
    func closeEnough(_ a: Complex<Double>, _ b: Complex<Double>) -> Bool {
      return (a - b).magnitude < max(a.magnitude, b.magnitude) * 0x1p-50
    }
    XCTAssert(closeEnough(Complex(0x1p1023, 0x1p-1023)/Complex(0x1p677, 0x1p-677),
                          Complex(0x1p346, -0x1p-1008)))
    XCTAssert(closeEnough(Complex(0x1p1020, 0x1p-844)/Complex(0x1p656, 0x1p-780),
                          Complex(0x1p364, -0x1p-1072)))
    XCTAssert(closeEnough(Complex(0x1p-71, 0x1p1021)/Complex(0x1p1001, 0x1p-323),
                          Complex(0x1p-1072, 0x1p20)))
  }
    
  static var allTests = [
    ("testDivide_BaudinSmith", testDivide_BaudinSmith),
    ("testDivide_BaudinSmithApprox", testDivide_BaudinSmithApprox),
  ]
}

#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
public func allTests() -> [XCTestCaseEntry] {
  return [
    testCase(ComplexTests.allTests),
  ]
}
#endif
