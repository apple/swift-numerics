//===--- WindowsMain.swift ------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2021 Apple Inc. and the Swift Numerics project authors
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

@testable
import IntegerUtilitiesTests

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

#if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
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

extension IntegerUtilitiesDivideTests {
  static var all = testCase([
    ("testDivideInt8", IntegerUtilitiesDivideTests.testDivideInt8),
    ("testDivideInt", IntegerUtilitiesDivideTests.testDivideInt),
    ("testDivideUInt8", IntegerUtilitiesDivideTests.testDivideUInt8),
    ("testDivideStochasticInt8", IntegerUtilitiesDivideTests.testDivideStochasticInt8),
    ("testDivideStochasticUInt32", IntegerUtilitiesDivideTests.testDivideStochasticUInt32),
    ("testRemainderByMinusOne", IntegerUtilitiesDivideTests.testRemainderByMinusOne),
  ])
}

extension IntegerUtilitiesGCDTests {
  static var all = testCase([
    ("testGCDInt", IntegerUtilitiesGCDTests.testGCDInt),
  ])
}

extension IntegerUtilitiesRotateTests {
  static var all = testCase([
    ("testRotateUInt8", IntegerUtilitiesRotateTests.testRotateUInt8),
    ("testRotateInt16", IntegerUtilitiesRotateTests.testRotateInt16),
  ])
}

extension IntegerUtilitiesShiftTests {
  static var all = testCase([
    ("testRoundingShifts", IntegerUtilitiesShiftTests.testRoundingShifts),
    ("testStochasticShifts", IntegerUtilitiesShiftTests.testStochasticShifts),
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

var testCases = [
  ComplexTests.ApproximateEqualityTests.all,
  RealTests.ApproximateEqualityTests.all,
  ElementaryFunctionChecks.all,
  IntegerExponentTests.all,
  ArithmeticTests.all,
  PropertyTests.all,
  IntegerUtilitiesDivideTests.all,
  IntegerUtilitiesGCDTests.all,
  IntegerUtilitiesRotateTests.all,
  IntegerUtilitiesShiftTests.all,
  IntegerUtilitiesTests.DoubleWidthTests.all,
]

XCTMain(testCases)

#endif
