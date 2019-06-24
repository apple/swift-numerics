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

protocol FixedWidthBinaryFloatingPoint: BinaryFloatingPoint, Real where
RawSignificand: FixedWidthInteger, Exponent: FixedWidthInteger { }

extension Float: FixedWidthBinaryFloatingPoint { }
extension Double: FixedWidthBinaryFloatingPoint { }
extension Float80: FixedWidthBinaryFloatingPoint { }

func mapProduct<T, R>(_ a: [T], _ b: [T], _ f: (T,T) -> R) -> [R] {
  return a.flatMap { a in b.map { b in f(a,b) } }
}

func testAllPairs<C>(_ values: C, _ test: (C.Element, C.Element) -> Void)
where C: Collection {
  for i in values.indices {
    var j = values.startIndex
    while j != i {
      test(values[i], values[j])
      values.formIndex(after: &j)
    }
  }
}

final class ComplexTests: XCTestCase {
  
  func zeros<RealType>(_ type: RealType.Type) -> [Complex<RealType>] {
    let reals: [RealType] = [0, -0]
    return mapProduct(reals, reals, Complex.init)
  }
  
  func subnormals<RealType>(_ type: RealType.Type) -> [Complex<RealType>]
  where RealType: FixedWidthBinaryFloatingPoint {
    let exponents = stride(from: RealType.leastNonzeroMagnitude.exponent,
                           to: RealType.leastNormalMagnitude.exponent, by: 1)
    let reals = exponents.map {
      RealType(sign: Bool.random() ? .plus : .minus,
               exponent: $0,
               significand: RealType.random(in: 1 ..< 2))
    }
    print(reals)
    return mapProduct(reals, reals, Complex.init)
  }
  
  func normals<RealType>(_ type: RealType.Type) -> [Complex<RealType>]
  where RealType: FixedWidthBinaryFloatingPoint {
    let exponentRange = RealType.leastNormalMagnitude.exponent ... RealType.greatestFiniteMagnitude.exponent
    let reals = (0..<100).map { _ in
      RealType(sign: Bool.random() ? .minus : .plus,
               exponent: RealType.Exponent.random(in: exponentRange),
               significand: RealType.random(in: 1 ..< 2))
    }
    return mapProduct(reals, reals, Complex.init)
  }
  
  func nonFinites<RealType>(_ type: RealType.Type) -> [Complex<RealType>] {
    let reals: [RealType] = [-.nan, -.infinity, .infinity, .nan]
    return mapProduct(reals, reals, Complex.init)
  }
  
  func testEquality<RealType>(_ type: RealType.Type)
  where RealType: FixedWidthBinaryFloatingPoint {
    let zeros = self.zeros(type)
    let subnormals = self.subnormals(type)
    let normals = self.normals(type)
    let nonFinites = self.nonFinites(type)
    // We test both == and != on these to detect failures if someone tries
    // to be clever and customize != and breaks it.
    // All zeros and infinites are equal to each other
    testAllPairs(zeros) {
      if !($0 == $1) { XCTFail("\($0) == \($1) was false, but should be true.") }
      if $0 != $1 { XCTFail("\($0) != \($1) was true, but should be false.") }
    }
    testAllPairs(nonFinites) {
      if !($0 == $1) { XCTFail("\($0) == \($1) was false, but should be true.") }
      if $0 != $1 { XCTFail("\($0) != \($1) was true, but should be false.") }
    }
    // By construction, the subnormals and normals should be unequal
    testAllPairs(subnormals + normals) {
      if !($0 != $1) { XCTFail("\($0) != \($1) was false, but should be true.") }
      if $0 == $1 { XCTFail("\($0) == \($1) was true, but should be false.") }
    }
  }
  
  func testEquality() {
    testEquality(Float.self)
    testEquality(Double.self)
  }
  
  static var allTests = [
  //  ("testInits", testInits),
    ("testEquality", testEquality),
  ]
}

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
  return [
    testCase(ComplexTests.allTests),
  ]
}
#endif
