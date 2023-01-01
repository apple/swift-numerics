//===--- WindowsMain.swift ------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//
// This file can be automatically generated with the command:
// swift package --allow-writing-to-package-directory generate-windows-main
//===----------------------------------------------------------------------===//

#if os(Windows)

import XCTest

@testable import ComplexTests
@testable import IntegerUtilitiesTests
@testable import RealTests

extension ComplexTests.ApproximateEqualityTests {
  static var all = testCase([
    ("testDouble", ComplexTests.ApproximateEqualityTests.testDouble),
    ("testFloat", ComplexTests.ApproximateEqualityTests.testFloat),
    ("testFloat80", ComplexTests.ApproximateEqualityTests.testFloat80),
  ])
}

extension ComplexTests.ArithmeticTests {
  static var all = testCase([
    ("testBaudinSmith", ComplexTests.ArithmeticTests.testBaudinSmith),
    ("testDivisionByZero", ComplexTests.ArithmeticTests.testDivisionByZero),
    ("testPolar", ComplexTests.ArithmeticTests.testPolar),
  ])
}

extension ComplexTests.ElementaryFunctionTests {
  static var all = testCase([
    ("testDouble", ComplexTests.ElementaryFunctionTests.testDouble),
    ("testFloat", ComplexTests.ElementaryFunctionTests.testFloat),
    ("testFloat80", ComplexTests.ElementaryFunctionTests.testFloat80),
  ])
}

extension ComplexTests.PropertyTests {
  static var all = testCase([
    ("testCodable", ComplexTests.PropertyTests.testCodable),
    ("testEquatableHashable", ComplexTests.PropertyTests.testEquatableHashable),
    ("testProperties", ComplexTests.PropertyTests.testProperties),
  ])
}

extension IntegerUtilitiesTests.DoubleWidthTests {
  static var all = testCase([
    ("testArithmetic_Signed", IntegerUtilitiesTests.DoubleWidthTests.testArithmetic_Signed),
    ("testArithmetic_Unsigned", IntegerUtilitiesTests.DoubleWidthTests.testArithmetic_Unsigned),
    ("testBitwise_LeftAndRightShifts", IntegerUtilitiesTests.DoubleWidthTests.testBitwise_LeftAndRightShifts),
    ("testCompileTime_SR_6947", IntegerUtilitiesTests.DoubleWidthTests.testCompileTime_SR_6947),
    ("testConditionalConformance", IntegerUtilitiesTests.DoubleWidthTests.testConditionalConformance),
    ("testConversions", IntegerUtilitiesTests.DoubleWidthTests.testConversions),
    ("testConversions_Exact", IntegerUtilitiesTests.DoubleWidthTests.testConversions_Exact),
    ("testConversions_SignedMax", IntegerUtilitiesTests.DoubleWidthTests.testConversions_SignedMax),
    ("testConversions_SignedMin", IntegerUtilitiesTests.DoubleWidthTests.testConversions_SignedMin),
    ("testConversions_ToAndFromString_Binary", IntegerUtilitiesTests.DoubleWidthTests.testConversions_ToAndFromString_Binary),
    ("testConversions_ToAndFromString_Decimal", IntegerUtilitiesTests.DoubleWidthTests.testConversions_ToAndFromString_Decimal),
    ("testConversions_ToAndFromString_Hexadecimal", IntegerUtilitiesTests.DoubleWidthTests.testConversions_ToAndFromString_Hexadecimal),
    ("testConversions_UnsignedMax", IntegerUtilitiesTests.DoubleWidthTests.testConversions_UnsignedMax),
    ("testConversions_UnsignedMin", IntegerUtilitiesTests.DoubleWidthTests.testConversions_UnsignedMin),
    ("testDivision_ByMinusOne", IntegerUtilitiesTests.DoubleWidthTests.testDivision_ByMinusOne),
    ("testDivision_ByZero", IntegerUtilitiesTests.DoubleWidthTests.testDivision_ByZero),
    ("testInitialization", IntegerUtilitiesTests.DoubleWidthTests.testInitialization),
    ("testInitialization_Overflow", IntegerUtilitiesTests.DoubleWidthTests.testInitialization_Overflow),
    ("testLiterals", IntegerUtilitiesTests.DoubleWidthTests.testLiterals),
    ("testLiterals_Underflow", IntegerUtilitiesTests.DoubleWidthTests.testLiterals_Underflow),
    ("testMagnitude", IntegerUtilitiesTests.DoubleWidthTests.testMagnitude),
    ("testMultipleOf", IntegerUtilitiesTests.DoubleWidthTests.testMultipleOf),
    ("testMultiplication_ByMinusOne", IntegerUtilitiesTests.DoubleWidthTests.testMultiplication_ByMinusOne),
    ("testNested", IntegerUtilitiesTests.DoubleWidthTests.testNested),
    ("testRemainder_ByMinusOne", IntegerUtilitiesTests.DoubleWidthTests.testRemainder_ByMinusOne),
    ("testRemainder_ByZero", IntegerUtilitiesTests.DoubleWidthTests.testRemainder_ByZero),
    ("testTwoWords", IntegerUtilitiesTests.DoubleWidthTests.testTwoWords),
    ("testWords", IntegerUtilitiesTests.DoubleWidthTests.testWords),
  ])
}

extension IntegerUtilitiesTests.IntegerUtilitiesDivideTests {
  static var all = testCase([
    ("testDivideInt", IntegerUtilitiesTests.IntegerUtilitiesDivideTests.testDivideInt),
    ("testDivideInt8", IntegerUtilitiesTests.IntegerUtilitiesDivideTests.testDivideInt8),
    ("testDivideStochasticInt8", IntegerUtilitiesTests.IntegerUtilitiesDivideTests.testDivideStochasticInt8),
    ("testDivideStochasticUInt32", IntegerUtilitiesTests.IntegerUtilitiesDivideTests.testDivideStochasticUInt32),
    ("testDivideUInt8", IntegerUtilitiesTests.IntegerUtilitiesDivideTests.testDivideUInt8),
    ("testRemainderByMinusOne", IntegerUtilitiesTests.IntegerUtilitiesDivideTests.testRemainderByMinusOne),
  ])
}

extension IntegerUtilitiesTests.IntegerUtilitiesGCDTests {
  static var all = testCase([
    ("testGCDInt", IntegerUtilitiesTests.IntegerUtilitiesGCDTests.testGCDInt),
  ])
}

extension IntegerUtilitiesTests.IntegerUtilitiesRotateTests {
  static var all = testCase([
    ("testRotateInt16", IntegerUtilitiesTests.IntegerUtilitiesRotateTests.testRotateInt16),
    ("testRotateUInt8", IntegerUtilitiesTests.IntegerUtilitiesRotateTests.testRotateUInt8),
  ])
}

extension IntegerUtilitiesTests.IntegerUtilitiesShiftTests {
  static var all = testCase([
    ("testRoundingShifts", IntegerUtilitiesTests.IntegerUtilitiesShiftTests.testRoundingShifts),
    ("testStochasticShifts", IntegerUtilitiesTests.IntegerUtilitiesShiftTests.testStochasticShifts),
  ])
}

extension RealTests.ApproximateEqualityTests {
  static var all = testCase([
    ("testDouble", RealTests.ApproximateEqualityTests.testDouble),
    ("testFloat", RealTests.ApproximateEqualityTests.testFloat),
    ("testFloat80", RealTests.ApproximateEqualityTests.testFloat80),
  ])
}

extension RealTests.AugmentedArithmeticTests {
  static var all = testCase([
    ("testTwoSum", RealTests.AugmentedArithmeticTests.testTwoSum),
  ])
}

extension RealTests.ElementaryFunctionChecks {
  static var all = testCase([
    ("testDouble", RealTests.ElementaryFunctionChecks.testDouble),
    ("testFloat", RealTests.ElementaryFunctionChecks.testFloat),
    ("testFloat16", RealTests.ElementaryFunctionChecks.testFloat16),
    ("testFloat80", RealTests.ElementaryFunctionChecks.testFloat80),
  ])
}

extension RealTests.IntegerExponentTests {
  static var all = testCase([
    ("testDouble", RealTests.IntegerExponentTests.testDouble),
    ("testFloat", RealTests.IntegerExponentTests.testFloat),
    ("testFloat16", RealTests.IntegerExponentTests.testFloat16),
    ("testFloat80", RealTests.IntegerExponentTests.testFloat80),
  ])
}

var testCases = [
  ComplexTests.ApproximateEqualityTests.all,
  ComplexTests.ArithmeticTests.all,
  ComplexTests.ElementaryFunctionTests.all,
  ComplexTests.PropertyTests.all,
  IntegerUtilitiesTests.DoubleWidthTests.all,
  IntegerUtilitiesTests.IntegerUtilitiesDivideTests.all,
  IntegerUtilitiesTests.IntegerUtilitiesGCDTests.all,
  IntegerUtilitiesTests.IntegerUtilitiesRotateTests.all,
  IntegerUtilitiesTests.IntegerUtilitiesShiftTests.all,
  RealTests.ApproximateEqualityTests.all,
  RealTests.AugmentedArithmeticTests.all,
  RealTests.ElementaryFunctionChecks.all,
  RealTests.IntegerExponentTests.all,
]

XCTMain(testCases)

#endif
