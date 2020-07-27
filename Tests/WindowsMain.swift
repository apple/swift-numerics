//===--- WindowsMain.swift ------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

#if os(Windows)
import XCTest

@testable
import RealTests

@testable
import ComplexTests

extension ElementaryFunctionChecks {
  static var all = testCase([
    ("testFloat", ElementaryFunctionChecks.testFloat),
    ("testDouble", ElementaryFunctionChecks.testDouble),
  ])
}

extension IntegerExponentTests {
  static var all = testCase([
    ("testFloat", IntegerExponentTests.testFloat),
    ("testDouble", IntegerExponentTests.testDouble),
  ])
}

extension ArithmeticTests {
  static var all = testCase([
    ("testPolar", ArithmeticTests.testPolar),
    ("testBaudinSmith", ArithmeticTests.testBaudinSmith),
    ("testDivisionByZero", ArithmeticTests.testDivisionByZero),
  ])
}

extension PropertyTests {
  static var all = testCase([
    ("testProperties", PropertyTests.testProperties),
    ("testEquatableHashable", PropertyTests.testEquatableHashable),
    ("testCodable", PropertyTests.testCodable),
  ])
}

var testCases = [
  ElementaryFunctionChecks.all,
  IntegerExponentTests.all,
  ArithmeticTests.all,
  PropertyTests.all,
]

XCTMain(testCases)

#endif
