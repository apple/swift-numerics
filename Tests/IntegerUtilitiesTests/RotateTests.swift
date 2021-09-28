//===--- RotateTests.swift ------------------------------------*- swift -*-===//
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

final class IntegerUtilitiesRotateTests: XCTestCase {
  func testRotateUInt8() {
    let x: UInt8 = 0b10011100
    XCTAssertEqual(0b01001110, x.rotated(right:-7))
    XCTAssertEqual(0b00100111, x.rotated(right:-6))
    XCTAssertEqual(0b10010011, x.rotated(right:-5))
    XCTAssertEqual(0b11001001, x.rotated(right:-4))
    XCTAssertEqual(0b11100100, x.rotated(right:-3))
    XCTAssertEqual(0b01110010, x.rotated(right:-2))
    XCTAssertEqual(0b00111001, x.rotated(right:-1))
    XCTAssertEqual(0b10011100, x.rotated(right: 0))
    XCTAssertEqual(0b01001110, x.rotated(right: 1))
    XCTAssertEqual(0b00100111, x.rotated(right: 2))
    XCTAssertEqual(0b10010011, x.rotated(right: 3))
    XCTAssertEqual(0b11001001, x.rotated(right: 4))
    XCTAssertEqual(0b11100100, x.rotated(right: 5))
    XCTAssertEqual(0b01110010, x.rotated(right: 6))
    XCTAssertEqual(0b00111001, x.rotated(right: 7))
    XCTAssertEqual(0b10011100, x.rotated(right: 8))
  }
  
  func testRotateInt16() {
    let x = Int16(bitPattern: 0b1001110000111110)
    XCTAssertEqual(Int16(bitPattern: 0b1001110000111110), x.rotated(left:-16))
    XCTAssertEqual(Int16(bitPattern: 0b0011100001111101), x.rotated(left:-15))
    XCTAssertEqual(Int16(bitPattern: 0b0111000011111010), x.rotated(left:-14))
    XCTAssertEqual(Int16(bitPattern: 0b1110000111110100), x.rotated(left:-13))
    XCTAssertEqual(Int16(bitPattern: 0b1100001111101001), x.rotated(left:-12))
    XCTAssertEqual(Int16(bitPattern: 0b1000011111010011), x.rotated(left:-11))
    XCTAssertEqual(Int16(bitPattern: 0b0000111110100111), x.rotated(left:-10))
    XCTAssertEqual(Int16(bitPattern: 0b0001111101001110), x.rotated(left:-9))
    XCTAssertEqual(Int16(bitPattern: 0b0011111010011100), x.rotated(left:-8))
    XCTAssertEqual(Int16(bitPattern: 0b0111110100111000), x.rotated(left:-7))
    XCTAssertEqual(Int16(bitPattern: 0b1111101001110000), x.rotated(left:-6))
    XCTAssertEqual(Int16(bitPattern: 0b1111010011100001), x.rotated(left:-5))
    XCTAssertEqual(Int16(bitPattern: 0b1110100111000011), x.rotated(left:-4))
    XCTAssertEqual(Int16(bitPattern: 0b1101001110000111), x.rotated(left:-3))
    XCTAssertEqual(Int16(bitPattern: 0b1010011100001111), x.rotated(left:-2))
    XCTAssertEqual(Int16(bitPattern: 0b0100111000011111), x.rotated(left:-1))
    XCTAssertEqual(Int16(bitPattern: 0b1001110000111110), x.rotated(left: 0))
    XCTAssertEqual(Int16(bitPattern: 0b0011100001111101), x.rotated(left: 1))
    XCTAssertEqual(Int16(bitPattern: 0b0111000011111010), x.rotated(left: 2))
    XCTAssertEqual(Int16(bitPattern: 0b1110000111110100), x.rotated(left: 3))
    XCTAssertEqual(Int16(bitPattern: 0b1100001111101001), x.rotated(left: 4))
    XCTAssertEqual(Int16(bitPattern: 0b1000011111010011), x.rotated(left: 5))
    XCTAssertEqual(Int16(bitPattern: 0b0000111110100111), x.rotated(left: 6))
    XCTAssertEqual(Int16(bitPattern: 0b0001111101001110), x.rotated(left: 7))
    XCTAssertEqual(Int16(bitPattern: 0b0011111010011100), x.rotated(left: 8))
    XCTAssertEqual(Int16(bitPattern: 0b0111110100111000), x.rotated(left: 9))
    XCTAssertEqual(Int16(bitPattern: 0b1111101001110000), x.rotated(left: 10))
    XCTAssertEqual(Int16(bitPattern: 0b1111010011100001), x.rotated(left: 11))
    XCTAssertEqual(Int16(bitPattern: 0b1110100111000011), x.rotated(left: 12))
    XCTAssertEqual(Int16(bitPattern: 0b1101001110000111), x.rotated(left: 13))
    XCTAssertEqual(Int16(bitPattern: 0b1010011100001111), x.rotated(left: 14))
    XCTAssertEqual(Int16(bitPattern: 0b0100111000011111), x.rotated(left: 15))
    XCTAssertEqual(Int16(bitPattern: 0b1001110000111110), x.rotated(left: 16))
  }
}

