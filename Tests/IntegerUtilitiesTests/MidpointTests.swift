//===--- MidpointTests.swift ----------------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import IntegerUtilities
import XCTest

final class IntegerUtilitiesMidpointTests: XCTestCase {
  func testMidpoint() {
    for rule in [
      RoundingRule.down,
      .up,
      .towardZero,
      .awayFromZero,
      .toNearestOrEven,
      .toNearestOrAwayFromZero,
      .toOdd
    ] {
      for a in -128 ... 127 {
        for b in -128 ... 127 {
          let ref = (a + b).shifted(rightBy: 1, rounding: rule)
          let tst = midpoint(Int8(a), Int8(b), rounding: rule)
          if ref != tst {
            print(rule, a, b, ref, tst, separator: "\t")
            return
          }
        }
      }
    }
  }
}
