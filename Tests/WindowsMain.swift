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

extension ComplexTests.ApproximateEqualityTests {
  static var all = testCase([
    ("testFloat", ComplexTests.ApproximateEqualityTests.testFloat),
    ("testDouble", ComplexTests.ApproximateEqualityTests.testDouble),
  ])
}

extension RealTests.ApproximateEqualityTests {
  static var all = testCase([
    ("testFloat", RealTests.ApproximateEqualityTests.testFloat),
    ("testDouble", RealTests.ApproximateEqualityTests.testDouble),
  ])
}

#if swift(>=5.4) && !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
extension ElementaryFunctionChecks {
  static var all = testCase([
    ("testFloat16", ElementaryFunctionChecks.testFloat16),
    ("testFloat", ElementaryFunctionChecks.testFloat),
    ("testDouble", ElementaryFunctionChecks.testDouble),
  ])
}

extension IntegerExponentTests {
  static var all = testCase([
    ("testFloat16", IntegerExponentTests.testFloat16),
    ("testFloat", IntegerExponentTests.testFloat),
    ("testDouble", IntegerExponentTests.testDouble),
  ])
}
#else
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
#endif

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
  ComplexTests.ApproximateEqualityTests.all,
  RealTests.ApproximateEqualityTests.all,
  ElementaryFunctionChecks.all,
  IntegerExponentTests.all,
  ArithmeticTests.all,
  PropertyTests.all,
]

#if swift(>=5.3) && canImport(_Differentiation)
extension DifferentiableTests {
  static var all = testCase([
    ("testComponentGetter", DifferentiableTests.testComponentGetter),
    ("testInitializer", DifferentiableTests.testInitializer),
    ("testConjugate",  DifferentiableTests.testConjugate),
    ("testArithmetics", DifferentiableTests.testArithmetics),
  ])
}

testCases += [
  DifferentiableTests.all
]
#endif

XCTMain(testCases)

#endif
