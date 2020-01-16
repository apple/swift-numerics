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

  func testExample() {
    let bar = BigInt(exactly: -100)
    XCTAssertNotNil(bar)
    if let bar = bar {
      XCTAssertLessThan(bar, 0)
      XCTAssertGreaterThan(-bar, 0)
      XCTAssertEqual(-bar, BigInt(100))
    }
    XCTAssertEqual(-BigInt("-1234567890123456789012345678901234567890")!,
                   +BigInt("+1234567890123456789012345678901234567890")!)
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

  func testCustomStringConvertible() {
    XCTAssertEqual("\(BigInt(UInt64.min) - 2)", "-2")
    XCTAssertEqual("\(BigInt(UInt64.min) - 1)", "-1")
    XCTAssertEqual("\(BigInt(UInt64.min) + 0)", "0")
    XCTAssertEqual("\(BigInt(UInt64.min) + 1)", "1")
    XCTAssertEqual("\(BigInt(UInt64.min) + 2)", "2")

    XCTAssertEqual("\(BigInt(UInt64.max) - 2)", "18446744073709551613")
    XCTAssertEqual("\(BigInt(UInt64.max) - 1)", "18446744073709551614")
    XCTAssertEqual("\(BigInt(UInt64.max) + 0)", "18446744073709551615")
    XCTAssertEqual("\(BigInt(UInt64.max) + 1)", "18446744073709551616")
    XCTAssertEqual("\(BigInt(UInt64.max) + 2)", "18446744073709551617")

    XCTAssertEqual("\(BigInt(Int64.min) - 2)", "-9223372036854775810")
    XCTAssertEqual("\(BigInt(Int64.min) - 1)", "-9223372036854775809")
    XCTAssertEqual("\(BigInt(Int64.min) + 0)", "-9223372036854775808")
    XCTAssertEqual("\(BigInt(Int64.min) + 1)", "-9223372036854775807")
    XCTAssertEqual("\(BigInt(Int64.min) + 2)", "-9223372036854775806")

    XCTAssertEqual("\(BigInt(Int64.max) - 2)", "9223372036854775805")
    XCTAssertEqual("\(BigInt(Int64.max) - 1)", "9223372036854775806")
    XCTAssertEqual("\(BigInt(Int64.max) + 0)", "9223372036854775807")
    XCTAssertEqual("\(BigInt(Int64.max) + 1)", "9223372036854775808")
    XCTAssertEqual("\(BigInt(Int64.max) + 2)", "9223372036854775809")
  }

  func testLosslessStringConvertible() {
    XCTAssertEqual(BigInt(UInt64.min) - 2, BigInt("-2"))
    XCTAssertEqual(BigInt(UInt64.min) - 1, BigInt("-1"))
    XCTAssertEqual(BigInt(UInt64.min) + 0, BigInt("0"))
    XCTAssertEqual(BigInt(UInt64.min) + 1, BigInt("1"))
    XCTAssertEqual(BigInt(UInt64.min) + 2, BigInt("2"))

    XCTAssertEqual(BigInt(UInt64.max) - 2, BigInt("18446744073709551613"))
    XCTAssertEqual(BigInt(UInt64.max) - 1, BigInt("18446744073709551614"))
    XCTAssertEqual(BigInt(UInt64.max) + 0, BigInt("18446744073709551615"))
    XCTAssertEqual(BigInt(UInt64.max) + 1, BigInt("18446744073709551616"))
    XCTAssertEqual(BigInt(UInt64.max) + 2, BigInt("18446744073709551617"))

    XCTAssertEqual(BigInt(Int64.min) - 2, BigInt("-9223372036854775810"))
    XCTAssertEqual(BigInt(Int64.min) - 1, BigInt("-9223372036854775809"))
    XCTAssertEqual(BigInt(Int64.min) + 0, BigInt("-9223372036854775808"))
    XCTAssertEqual(BigInt(Int64.min) + 1, BigInt("-9223372036854775807"))
    XCTAssertEqual(BigInt(Int64.min) + 2, BigInt("-9223372036854775806"))

    XCTAssertEqual(BigInt(Int64.max) - 2, BigInt("9223372036854775805"))
    XCTAssertEqual(BigInt(Int64.max) - 1, BigInt("9223372036854775806"))
    XCTAssertEqual(BigInt(Int64.max) + 0, BigInt("9223372036854775807"))
    XCTAssertEqual(BigInt(Int64.max) + 1, BigInt("9223372036854775808"))
    XCTAssertEqual(BigInt(Int64.max) + 2, BigInt("9223372036854775809"))
  }

  func testRadicesAndNumerals() {
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
            XCTAssertEqual(actualNumber, expectedNumber)
            if radix == 10 {
              XCTAssertEqual(actualNumber.description, expectedString)
            }
          }
        }
      }
    }
  }
  
  func testDivision() {
    let foo = BigInt("12345678901234567890123456789012345678901234567890123456789012345678901234567890")!
    let bar = BigInt("351235231535161613134135135135")!
    let baz = foo / bar
    XCTAssertEqual(baz, BigInt("35149318157164029155780432046477458820396117503007")!)
  }
}
