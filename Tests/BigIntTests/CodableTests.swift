//===--- CodableTests.swift -----------------------------------*- swift -*-===//
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

// The only property that we care about is that `encode -> decode` works.
// The transport format does not matter.
// Though as soon as we commit to 1 representation we have to keep it forever.
class CodableTests: XCTestCase {

  func test_equalsString_radix10() {
    let encoder = JSONEncoder()

    for p in generateBigInts(approximateCount: 100) {
      let big = p.create()

      do {
        let data = try encoder.encode(big)
        let json = String(bytes: data, encoding: .utf8)
        assert(json != nil)

        let expected = "\"" + String(big, radix: 10) + "\""
        XCTAssertEqual(json, expected)
      } catch {
        XCTFail("\(big)")
      }
    }
  }

  func test_int() {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    for int in generateInts(approximateCount: 1000) {
      let big = BigInt(int)

      do {
        let data = try encoder.encode(big)
        let restored = try decoder.decode(BigInt.self, from: data)
        XCTAssertEqual(big, restored)
      } catch {
        XCTFail("\(int)")
      }
    }
  }

  func test_big() {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    for p in generateBigInts(approximateCount: 1000) {
      let big = p.create()

      do {
        let data = try encoder.encode(big)
        let restored = try decoder.decode(BigInt.self, from: data)
        XCTAssertEqual(big, restored)
      } catch {
        XCTFail("\(big)")
      }
    }
  }
}
