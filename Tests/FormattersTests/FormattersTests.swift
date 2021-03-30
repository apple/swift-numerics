//===--- FormattersTest.swift ---------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import FormattersModule


final class FrmattersTest: XCTestCase {
  public func testIntegerFormatting() {
    // TODO: More exhaustive programmatic tests using the formatter structs
  }

  // Some quick ad-hoc tests
  public func testIntegerFormattingAdHoc() {
    var buffer = ""
    func put(_ s: String) {
      buffer += s
    }
    func expect(_ s: String) {
      XCTAssertEqual(buffer, s)
      buffer = ""
    }

    put("""
      \(12345678, format: .decimal(minDigits: 2), align: .right(columns: 9, fill: " "))
      """)
    expect(" 12345678")

    put("\(54321, format: .hex)")
    expect("0xd431")

    put("\(54321, format: .hex(includePrefix: false, uppercase: true))")
    expect("D431")

    put("\(1234567890, format: .hex(includePrefix: true, minDigits: 12), align: .right(columns: 20))")
    expect("      0x0000499602d2")

    put("\(9876543210, format: .hex(explicitPositiveSign: true), align: .right(columns: 20, fill: "-"))")
    expect("--------+0x24cb016ea")

    put("\("Hi there", align: .left(columns: 20))!")
    expect("Hi there            !")

    put("\(-1234567890, format: .hex(includePrefix: true, minDigits: 12), align: .right(columns: 20))")
    expect("     -0x0000499602d2")

    put("\(-1234567890, format: .hex(minDigits: 12, separator: .every(2, separator: "_")), align: .right(columns: 22))")
    expect("  -0x00_00_49_96_02_d2")

    put("\(-1234567890, format: .hex(minDigits: 10, separator: .every(4, separator: "_")), align: .right(columns: 22))")
    expect("       -0x00_4996_02d2")

    put("\(1234567890, format: .decimal(separator: .thousands(separator: "⌟")))")
    expect("1⌟234⌟567⌟890")

    put("\(98765, format: .hex(includePrefix: true, minDigits: 8, separator: .every(2, separator: "_")))")
    expect("0x00_01_81_cd")

    put("\(12345, format: .hex(minDigits: 5))")
    expect("0x03039")

  }

}
