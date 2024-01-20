//===--- AppleBigIntDivTests.swift ----------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import BigIntModule

// swiftlint:disable line_length

private typealias TestCase = (x: String, y: String, quotient: String, remainder: String)

/// Additional tests for `div` operation
/// Based on: https://github.com/apple/swift/blob/master/test/Prototypes/BigInt.swift
class AppleBigIntDivTests: XCTestCase {

  private let testCases: [TestCase] = [
    ("3GFWFN54YXNBS6K2ST8K9B89Q2AMRWCNYP4JAS5ZOPPZ1WU09MXXTIT27ZPVEG2Y",
     "9Y1QXS4XYYDSBMU4N3LW7R3R1WKK",
     "CIFJIVHV0K4MSX44QEX2US0MFFEAWJVQ8PJZ",
     "26HILZ7GZQN8MB4O17NSPO5XN1JI"),
    ("7PM82EHP7ZN3ZL7KOPB7B8KYDD1R7EEOYWB6M4SEION47EMS6SMBEA0FNR6U9VAM70HPY4WKXBM8DCF1QOR1LE38NJAVOPOZEBLIU1M05",
     "-202WEEIRRLRA9FULGA15RYROVW69ZPDHW0FMYSURBNWB93RNMSLRMIFUPDLP5YOO307XUNEFLU49FV12MI22MLCVZ5JH",
     "-3UNIZHA6PAL30Y",
     "1Y13W1HYB0QV2Z5RDV9Z7QXEGPLZ6SAA2906T3UKA46E6M4S6O9RMUF5ETYBR2QT15FJZP87JE0W06FA17RYOCZ3AYM3"),
    ("-ICT39SS0ONER9Z7EAPVXS3BNZDD6WJA791CV5LT8I4POLF6QYXBQGUQG0LVGPVLT0L5Z53BX6WVHWLCI5J9CHCROCKH3B381CCLZ4XAALLMD",
     "6T1XIVCPIPXODRK8312KVMCDPBMC7J4K0RWB7PM2V4VMBMODQ8STMYSLIXFN9ORRXCTERWS5U4BLUNA4H6NG8O01IM510NJ5STE",
     "-2P2RVZ11QF",
     "-3YSI67CCOD8OI1HFF7VF5AWEQ34WK6B8AAFV95U7C04GBXN0R6W5GM5OGOO22HY0KADIUBXSY13435TW4VLHCKLM76VS51W5Z9J"),
    ("-326JY57SJVC",
     "-8H98AQ1OY7CGAOOSG",
     "0",
     "-326JY57SJVC"),
    ("-XIYY0P3X9JIDF20ZQG2CN5D2Q5CD9WFDDXRLFZRDKZ8V4TSLE2EHRA31XL3YOHPYLE0I0ZAV2V9RF8AGPCYPVWEIYWWWZ3HVDR64M08VZTBL85PR66Z2F0W5AIDPXIAVLS9VVNLNA6I0PKM87YW4T98P0K",
     "-BUBZEC4NTOSCO0XHCTETN4ROPSXIJBTEFYMZ7O4Q1REOZO2SFU62KM3L8D45Z2K4NN3EC4BSRNEE",
     "2TX1KWYGAW9LAXUYRXZQENY5P3DSVXJJXK4Y9DWGNZHOWCL5QD5PLLZCE6D0G7VBNP9YGFC0Z9XIPCB",
     "-3LNPZ9JK5PUXRZ2Y1EJ4E3QRMAMPKZNI90ZFOBQJM5GZUJ84VMF8EILRGCHZGXJX4AXZF0Z00YA"),
    ("AZZBGH7AH3S7TVRHDJPJ2DR81H4FY5VJW2JH7O4U7CH0GG2DSDDOSTD06S4UM0HP1HAQ68B2LKKWD73UU0FV5M0H0D0NSXUJI7C2HW3P51H1JM5BHGXK98NNNSHMUB0674VKJ57GVVGY4",
     "1LYN8LRN3PY24V0YNHGCW47WUWPLKAE4685LP0J74NZYAIMIBZTAF71",
     "6TXVE5E9DXTPTHLEAG7HGFTT0B3XIXVM8IGVRONGSSH1UC0HUASRTZX8TVM2VOK9N9NATPWG09G7MDL6CE9LBKN",
     "WY37RSPBTEPQUA23AXB3B5AJRIUL76N3LXLP3KQWKFFSR7PR4E1JWH"),
    ("1000000000000000000000000000000000000000000000",
     "1000000000000000000000000000000000000",
     "1000000000",
     "0")
  ]

  func test_run() {
    for testCaseStrings in self.testCases {
      guard let values = self.parseTestCase(case: testCaseStrings) else {
        continue
      }

      let x = values.x
      let y = values.y
      let result = x.quotientAndRemainder(dividingBy: y)

      let msg = "\(testCaseStrings.x) / \(testCaseStrings.y)"
      XCTAssertEqual(result.quotient, values.quotient, msg)
      XCTAssertEqual(result.remainder, values.remainder, msg)

      let mulResult = result.quotient * y + result.remainder
      XCTAssertEqual(mulResult, x, msg)
    }
  }

  private struct TestCaseValues {
    fileprivate let x: BigInt
    fileprivate let y: BigInt
    fileprivate let quotient: BigInt
    fileprivate let remainder: BigInt
  }

  private func parseTestCase(case c: TestCase,
                             file: StaticString = #file,
                             line: UInt = #line) -> TestCaseValues? {
    let radix = 36

    guard let x = BigInt(c.x, radix: radix) else {
      XCTFail("Unable to parse x: \(c.x)", file: file, line: line)
      return nil
    }

    guard let y = BigInt(c.y, radix: radix) else {
      XCTFail("Unable to parse y: \(c.y)", file: file, line: line)
      return nil
    }

    guard let quotient = BigInt(c.quotient, radix: radix) else {
      XCTFail("Unable to parse quotient: \(c.quotient)", file: file, line: line)
      return nil
    }

    guard let remainder = BigInt(c.remainder, radix: radix) else {
      XCTFail("Unable to parse remainder: \(c.remainder)", file: file, line: line)
      return nil
    }

    return TestCaseValues(
      x: x,
      y: y,
      quotient: quotient,
      remainder: remainder
    )
  }
}
