//===--- BigIntTests.swift ------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import BigInt
import XCTest

func fac(_ n: BigInt) -> BigInt {
  var result: BigInt = 1
  var count = n
  while count >= 1 {
    result *= count
    count -= 1
  }

  return result
}

final class BigIntTests: XCTestCase {

  func testExample() throws {
    let bar = BigInt(exactly: -100)
    XCTAssertNotNil(bar)
    XCTAssert(bar! < 0)

    XCTAssert(-(bar!) > 0)
    XCTAssertEqual(-(bar!), BigInt(100))

    XCTAssertEqual(-BigInt("-1234567890123456789012345678901234567890")!,
                   BigInt("1234567890123456789012345678901234567890")!)
  }

  func testFloatingConversion() {
    let bar = BigInt(3.14159)
    XCTAssertEqual(bar, BigInt(3))
    let foo = BigInt(exactly: 3.14159)
    XCTAssertNil(foo)

    let baz = BigInt(exactly: 2.4e39)
    XCTAssertNotNil(baz)
    let equal = (baz ?? 0) / BigInt(1e38) == BigInt(24)
    XCTAssertEqual(equal, true)

    let infinite = BigInt(exactly: Double.infinity)
    XCTAssertNil(infinite)
  }

  func testUIntConversion() {
    let foo = BigInt(UInt.max)
    XCTAssertNotEqual(foo, BigInt(-1))

    let bar = BigInt(bitPattern: UInt.max)
    XCTAssertEqual(bar, BigInt(-1))
  }

  func testComparison() {
    let foo = BigInt(-10)
    let bar = BigInt(-20)

    XCTAssert(foo > bar)
    XCTAssert(bar < foo)
    XCTAssert(foo == BigInt(-10))

    let baz = pow(foo, -bar)
    XCTAssertEqual(baz, BigInt("100000000000000000000")!)
  }

  func testMath() {
    let foo = pow(BigInt(10), 20)
    let bar = BigInt("1234567890123456789012345678901234567890")!

    let baz = foo + bar

    XCTAssertEqual(baz, BigInt("1234567890123456789112345678901234567890")!)

    let fooz = foo >> BigInt(10)
    XCTAssertEqual(fooz, foo / 1024)

    let barz = BigInt(1) << 64
    XCTAssertEqual(barz, BigInt(UInt.max) + 1)
  }

  func testHashable() {
    let foo = BigInt("1234567890123456789012345678901234567890")!
    let bar = BigInt("1234567890123456789112345678901234567890")!
    let baz: BigInt = 153

    let dict = [ foo: "Hello", bar: "World", baz: "!" ]

    let hash = foo.hashValue
    print(hash)

    XCTAssertEqual(dict[foo]!, "Hello")
    XCTAssertEqual(dict[bar]!, "World")
  }

  func testNegation() {
    let foo = BigInt("1234567890123456789012345678901234567890")!
    let bar = BigInt(0) - foo

    XCTAssertEqual(-foo, bar)

    var baz = foo
    baz.negate()
    XCTAssertEqual(baz, bar)
  }

  func testCodable() throws {
    let lowerBound = BigInt("-1234567890123456789012345678901234567890")!
    let upperBound = BigInt("+1234567890123456789012345678901234567890")!
    let expectedRange: Range<BigInt> = lowerBound ..< upperBound

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let data = try encoder.encode(expectedRange)
    let actualRange = try decoder.decode(Range<BigInt>.self, from: data)

    XCTAssertEqual(actualRange, expectedRange)
  }

  func testMinMaxDescriptions() {
    let keyValuePairs: KeyValuePairs<BigInt, [String]> = [
      BigInt(UInt64.min): [
        "-2",
        "-1",
        "0",
        "1",
        "2"
      ],
      BigInt(UInt64.max): [
        "18446744073709551613",
        "18446744073709551614",
        "18446744073709551615",
        "18446744073709551616",
        "18446744073709551617",
      ],
      BigInt(Int64.min): [
        "-9223372036854775810",
        "-9223372036854775809",
        "-9223372036854775808",
        "-9223372036854775807",
        "-9223372036854775806",
      ],
      BigInt(Int64.max): [
        "9223372036854775805",
        "9223372036854775806",
        "9223372036854775807",
        "9223372036854775808",
        "9223372036854775809",
      ],
    ]
    for (expectedNumber, expectedStrings) in keyValuePairs {
      let expectedNumbers: [BigInt] = (-2 ... 2).map({ expectedNumber + $0 })
      let actualNumbers: [BigInt] = expectedStrings.compactMap({ BigInt($0) })
      let actualStrings: [String] = actualNumbers.map({ $0.description })
      XCTAssertEqual(actualNumbers, expectedNumbers, "Numbers: actual, expected")
      XCTAssertEqual(actualStrings, expectedStrings, "Strings: actual, expected")
    }
  }

  func testRandomDescriptions() {
    for _ in 0 ..< 100 {
      let expectedNumber = BigInt(Int.random(in: .min ... .max))
      for radix in 2 ... 36 {
        for uppercase in [false, true] {
          let expectedString = String(expectedNumber,
                                      radix: radix,
                                      uppercase: uppercase)
          let actualNumber = BigInt(expectedString, radix: radix)
          XCTAssertNotNil(actualNumber)
          if let actualNumber = actualNumber {
            XCTAssertEqual(actualNumber, expectedNumber,
                           "Numbers: actual, expected")
            if radix == 10 {
              XCTAssertEqual(actualNumber.description, expectedString,
                             "Strings: actual, expected")
            }
          }
        }
      }
    }
  }
}
