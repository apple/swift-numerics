//===--- RoundingTests.swift ----------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import IntegerUtilities
import _TestSupport
import XCTest

final class IntegerUtilitiesRoundingTests: XCTestCase {
  func testRoundingDirected<T: BinaryFloatingPoint>(_ type: T.Type) {
    let inf = T.infinity
    let gfm = T.greatestFiniteMagnitude
    let big: T = 1 / .ulpOfOne
    let two: T = 2
    let threeHalves: T = 1.5
    let one: T = 1
    let half: T = 0.5
    let nrm = T.leastNormalMagnitude
    let lnm = T.leastNonzeroMagnitude
    let vectors: [(input: T, down: T, up: T, zero: T, away: T)] = [
      (-inf,                  -inf,   -inf,   -inf,   -inf),
      (-gfm,                  -gfm,   -gfm,   -gfm,   -gfm),
      (-big.nextUp,           -big-1, -big-1, -big-1, -big-1),
      (-big,                  -big,   -big,   -big,   -big),
      (-big.nextDown,         -big,   -big+1, -big+1, -big),
      (-two,                  -two,   -two,   -two,   -two),
      (-two.nextDown,         -two,   -one,   -one,   -two),
      (-threeHalves.nextUp,   -two,   -one,   -one,   -two),
      (-threeHalves,          -two,   -one,   -one,   -two),
      (-threeHalves.nextDown, -two,   -one,   -one,   -two),
      (-one.nextUp,           -two,   -one,   -one,   -two),
      (-one,                  -one,   -one,   -one,   -one),
      (-one.nextDown,         -one,    0,      0,     -one),
      (-half.nextUp,          -one,    0,      0,     -one),
      (-half,                 -one,    0,      0,     -one),
      (-half.nextDown,        -one,    0,      0,     -one),
      (-nrm,                  -one,    0,      0,     -one),
      (-lnm,                  -one,    0,      0,     -one),
      (-.zero,                 0,      0,      0,      0),
      ( .zero,                 0,      0,      0,      0),
      ( lnm,                   0,      one,    0,      one),
      ( nrm,                   0,      one,    0,      one),
      ( half.nextDown,         0,      one,    0,      one),
      ( half,                  0,      one,    0,      one),
      ( half.nextUp,           0,      one,    0,      one),
      ( one.nextDown,          0,      one,    0,      one),
      ( one,                   one,    one,    one,    one),
      ( one.nextUp,            one,    two,    one,    two),
      ( threeHalves.nextDown,  one,    two,    one,    two),
      ( threeHalves,           one,    two,    one,    two),
      ( threeHalves.nextUp,    one,    two,    one,    two),
      ( two.nextDown,          one,    two,    one,    two),
      ( two,                   two,    two,    two,    two),
      ( big.nextDown,          big-1,  big,    big-1,  big),
      ( big,                   big,    big,    big,    big),
      ( big.nextUp,            big+1,  big+1,  big+1,  big+1),
      ( gfm,                   gfm,    gfm,    gfm,    gfm),
      ( inf,                   inf,    inf,    inf,    inf),
    ]
    for vector in vectors {
      
      XCTAssertEqual(vector.input.rounding(.down), vector.down)
      if vector.down == 0 {
        XCTAssertEqual(vector.input.rounding(.down).sign, vector.input.sign)
      }
      
      XCTAssertEqual(vector.input.rounding(.up), vector.up)
      if vector.up == 0 {
        XCTAssertEqual(vector.input.rounding(.up).sign, vector.input.sign)
      }
      
      XCTAssertEqual(vector.input.rounding(.towardZero), vector.zero)
      if vector.zero == 0 {
        XCTAssertEqual(vector.input.rounding(.towardZero).sign, vector.input.sign)
      }
      
      XCTAssertEqual(vector.input.rounding(.awayFromZero), vector.away)
      if vector.away == 0 {
        XCTAssertEqual(vector.input.rounding(.awayFromZero).sign, vector.input.sign)
      }
    }
  }
  
  func testRoundingDirected() {
    testRoundingDirected(Float.self)
    testRoundingDirected(Double.self)
  }
  
  func testRoundingNearest<T: BinaryFloatingPoint>(_ type: T.Type) {
    let inf = T.infinity
    let gfm = T.greatestFiniteMagnitude
    let big: T = 1 / .ulpOfOne
    let two: T = 2
    let threeHalves: T = 1.5
    let one: T = 1
    let half: T = 0.5
    let nrm = T.leastNormalMagnitude
    let lnm = T.leastNonzeroMagnitude
    let vectors: [(input: T, down: T, up: T, zero: T, away: T, even: T)] = [
      (-inf,                  -inf,   -inf,   -inf,   -inf,   -inf),
      (-gfm,                  -gfm,   -gfm,   -gfm,   -gfm,   -gfm),
      (-big.nextUp,           -big-1, -big-1, -big-1, -big-1, -big-1),
      (-big,                  -big,   -big,   -big,   -big,   -big),
      (-big.nextDown,         -big,   -big+1, -big+1, -big,   -big),
      (-two,                  -two,   -two,   -two,   -two,   -two),
      (-two.nextDown,         -two,   -two,   -two,   -two,   -two),
      (-threeHalves.nextUp,   -two,   -two,   -two,   -two,   -two),
      (-threeHalves,          -two,   -one,   -one,   -two,   -two),
      (-threeHalves.nextDown, -one,   -one,   -one,   -one,   -one),
      (-one.nextUp,           -one,   -one,   -one,   -one,   -one),
      (-one,                  -one,   -one,   -one,   -one,   -one),
      (-one.nextDown,         -one,   -one,   -one,   -one,   -one),
      (-half.nextUp,          -one,   -one,   -one,   -one,   -one),
      (-half,                 -one,    0,      0,     -one,    0),
      (-half.nextDown,         0,      0,      0,      0,      0),
      (-nrm,                   0,      0,      0,      0,      0),
      (-lnm,                   0,      0,      0,      0,      0),
      (-.zero,                 0,      0,      0,      0,      0),
      ( .zero,                 0,      0,      0,      0,      0),
      ( lnm,                   0,      0,      0,      0,      0),
      ( nrm,                   0,      0,      0,      0,      0),
      ( half.nextDown,         0,      0,      0,      0,      0),
      ( half,                  0,      one,    0,      one,    0),
      ( half.nextUp,           one,    one,    one,    one,    one),
      ( one.nextDown,          one,    one,    one,    one,    one),
      ( one,                   one,    one,    one,    one,    one),
      ( one.nextUp,            one,    one,    one,    one,    one),
      ( threeHalves.nextDown,  one,    one,    one,    one,    one),
      ( threeHalves,           one,    two,    one,    two,    two),
      ( threeHalves.nextUp,    two,    two,    two,    two,    two),
      ( two.nextDown,          two,    two,    two,    two,    two),
      ( two,                   two,    two,    two,    two,    two),
      ( big.nextDown,          big-1,  big,    big-1,  big,    big),
      ( big,                   big,    big,    big,    big,    big),
      ( big.nextUp,            big+1,  big+1,  big+1,  big+1,  big+1),
      ( gfm,                   gfm,    gfm,    gfm,    gfm,    gfm),
      ( inf,                   inf,    inf,    inf,    inf,    inf),
    ]
    for vector in vectors {
      
      XCTAssertEqual(vector.input.rounding(.toNearestOrDown), vector.down, "\(vector.input).rounding(.toNearestOrDown)")
      if vector.down == 0 {
        XCTAssertEqual(vector.input.rounding(.toNearestOrDown).sign, vector.input.sign, "\(vector.input).rounding(.toNearestOrDown)")
      }
      
      XCTAssertEqual(vector.input.rounding(.toNearestOrUp), vector.up, "\(vector.input).rounding(.toNearestOrUp)")
      if vector.up == 0 {
        XCTAssertEqual(vector.input.rounding(.toNearestOrUp).sign, vector.input.sign, "\(vector.input).rounding(.toNearestOrUp)")
      }
      
      XCTAssertEqual(vector.input.rounding(.toNearestOrZero), vector.zero, "\(vector.input).rounding(.toNearestOrZero)")
      if vector.zero == 0 {
        XCTAssertEqual(vector.input.rounding(.toNearestOrZero).sign, vector.input.sign, "\(vector.input).rounding(.toNearestOrZero)")
      }
      
      XCTAssertEqual(vector.input.rounding(.toNearestOrAway), vector.away, "\(vector.input).rounding(.toNearestOrAway)")
      if vector.away == 0 {
        XCTAssertEqual(vector.input.rounding(.toNearestOrAway).sign, vector.input.sign, "\(vector.input).rounding(.toNearestOrAway)")
      }
      
      XCTAssertEqual(vector.input.rounding(.toNearestOrEven), vector.even, "\(vector.input).rounding(.toNearestOrEven)")
      if vector.even == 0 {
        XCTAssertEqual(vector.input.rounding(.toNearestOrEven).sign, vector.input.sign, "\(vector.input).rounding(.toNearestOrEven)")
      }
    }
  }
  
  func testRoundingNearest() {
    testRoundingNearest(Float.self)
    testRoundingNearest(Double.self)
  }
  
  func testRoundingOdd<T: BinaryFloatingPoint>(_ type: T.Type) {
    let inf = T.infinity
    let gfm = T.greatestFiniteMagnitude
    let big: T = 1 / .ulpOfOne
    let two: T = 2
    let threeHalves: T = 1.5
    let one: T = 1
    let half: T = 0.5
    let nrm = T.leastNormalMagnitude
    let lnm = T.leastNonzeroMagnitude
    let vectors: [(input: T, odd: T)] = [
      (-inf,                  -inf),
      (-gfm,                  -gfm),
      (-big.nextUp,           -big-1),
      (-big,                  -big),
      (-big.nextDown,         -big+1),
      (-two,                  -two),
      (-two.nextDown,         -one),
      (-threeHalves.nextUp,   -one),
      (-threeHalves,          -one),
      (-threeHalves.nextDown, -one),
      (-one.nextUp,           -one),
      (-one,                  -one),
      (-one.nextDown,         -one),
      (-half.nextUp,          -one),
      (-half,                 -one),
      (-half.nextDown,        -one),
      (-nrm,                  -one),
      (-lnm,                  -one),
      (-.zero,                 0),
      ( .zero,                 0),
      ( lnm,                   one),
      ( nrm,                   one),
      ( half.nextDown,         one),
      ( half,                  one),
      ( half.nextUp,           one),
      ( one.nextDown,          one),
      ( one,                   one),
      ( one.nextUp,            one),
      ( threeHalves.nextDown,  one),
      ( threeHalves,           one),
      ( threeHalves.nextUp,    one),
      ( two.nextDown,          one),
      ( two,                   two),
      ( big.nextDown,          big-1),
      ( big,                   big),
      ( big.nextUp,            big+1),
      ( gfm,                   gfm),
      ( inf,                   inf)
    ]
    for vector in vectors {
      XCTAssertEqual(vector.input.rounding(.toOdd), vector.odd, "\(vector.input).rounding(.toOdd)")
      if vector.odd == 0 {
        XCTAssertEqual(vector.input.rounding(.toOdd).sign, vector.input.sign, "\(vector.input).rounding(.toOdd)")
      }
    }
  }
  
  func testRoundingOdd() {
    testRoundingOdd(Float.self)
    testRoundingOdd(Double.self)
  }
}
