//===--- DoubleWidthTests.swift -------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2017-2021 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import _TestSupport
import XCTest

final class DoubleWidthTests: XCTestCase {

  typealias _Int16 = DoubleWidth<Int8>
  typealias _Int128 = DoubleWidth<Int64>
  typealias _Int256 = DoubleWidth<_Int128>
  typealias _Int512 = DoubleWidth<_Int256>
  typealias _Int1024 = DoubleWidth<_Int512>

  typealias _UInt16 = DoubleWidth<UInt8>
  typealias _UInt128 = DoubleWidth<UInt64>
  typealias _UInt256 = DoubleWidth<_UInt128>
  typealias _UInt512 = DoubleWidth<_UInt256>
  typealias _UInt1024 = DoubleWidth<_UInt512>

  // <https://bugs.swift.org/browse/SR-6947>
  // Swift 4.x took over 15 minutes to compile this test code.
  // Swift 5.5 takes less than one second (`-Onone` or `-O` or `-Osize`).
  func testCompileTime_SR_6947() {
    typealias _Int32 = DoubleWidth<DoubleWidth<Int8>>
    typealias _Int64 = DoubleWidth<DoubleWidth<DoubleWidth<Int8>>>

    var sum = 0
    let (q, r) = (_Int128(Int64.max) * 16).quotientAndRemainder(dividingBy: 16)
    sum += Int(q * r)
    XCTAssertEqual(sum, 0)

    let x = _Int64(Int64.max / 4)
    let y = _Int32(Int32.max)
    let xx = _Int1024(x)
    let yy = _Int512(y)
    let (q3, r3) = yy.dividingFullWidth((xx.high, xx.low))
    sum -= Int(q3 - r3)
    XCTAssertEqual(sum, -1)
  }

  func testLiterals() {
    let w: _UInt16 = 100
    XCTAssertTrue(w == 100 as Int)

    let x: _UInt16 = 1000
    XCTAssertTrue(x == 1000 as Int)

    let y: _Int16 = 1000
    XCTAssertTrue(y == 1000 as Int)

    let z: _Int16 = -1000
    XCTAssertTrue(z == -1000 as Int)
  }

  func testLiterals_Underflow() {
    // TODO: expectCrashLater()
    // _ = -1 as _UInt16
  }

#if false // TODO: _ExpressibleByBuiltinIntegerLiteral

  func testLiterals_LargeSigned() {
    let a: _Int256 =
    0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    let b: _Int256 =
    -0x8000000000000000000000000000000000000000000000000000000000000000
    XCTAssertEqual(a, _Int256.max)
    XCTAssertEqual(b, _Int256.min)
  }

  func testLiterals_LargeSigned_Underflow() {
    // TODO: expectCrashLater()
    // _ = -0x8000000000000000000000000000000000000000000000000000000000000001
    // as _Int256
  }

  func testLiterals_LargeSigned_Overflow() {
    // TODO: expectCrashLater()
    // _ = 0x8000000000000000000000000000000000000000000000000000000000000000
    // as _Int256
  }

  func testLiterals_LargeUnsigned() {
    let a: _UInt256 =
    0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    let b: _UInt256 = 0
    XCTAssertEqual(a, _UInt256.max)
    XCTAssertEqual(b, _UInt256.min)
  }

  func testLiterals_LargeUnsigned_Underflow() {
    // TODO: expectCrashLater()
    // _ = -1 as _UInt256
  }

  func testLiterals_LargeUnsigned_Overflow() {
    // TODO: expectCrashLater()
    // _ = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0
    // as _UInt256
  }

#endif // TODO: _ExpressibleByBuiltinIntegerLiteral

  func testArithmetic_Unsigned() {
    let x: _UInt16 = 1000
    let y: _UInt16 = 1111
    XCTAssertEqual(x + 1, 1001)
    XCTAssertEqual(x + x, 2000)
    XCTAssertEqual(x - (1 as _UInt16), 999)
    XCTAssertEqual(x - x, 0)
    XCTAssertEqual(y - x, 111)

    XCTAssertEqual(x * 7, 7000)
    XCTAssertEqual(y * 7, 7777)

    XCTAssertEqual(x / 3, 333)
    XCTAssertEqual(x / x, 1)
    XCTAssertEqual(x / y, 0)
    XCTAssertEqual(y / x, 1)

    XCTAssertEqual(x % 3, 1)
    XCTAssertEqual(x % y, x)
  }

  func testArithmetic_Signed() {
    let x: _Int16 = 1000
    let y: _Int16 = -1111
    XCTAssertEqual(x + 1, 1001)
    XCTAssertEqual(x + x, 2000)
    XCTAssertEqual(x - (1 as _Int16), 999)
    XCTAssertEqual(x - x, 0)
    XCTAssertEqual(0 - x, -1000)
    XCTAssertEqual(x + y, -111)
    XCTAssertEqual(x - y, 2111)

    XCTAssertEqual(x * 7, 7000)
    XCTAssertEqual(y * 7, -7777)
    XCTAssertEqual(x * -7, -7000)
    XCTAssertEqual(y * -7, 7777)

    XCTAssertEqual(x / 3, 333)
    XCTAssertEqual(x / -3, -333)
    XCTAssertEqual(x / x, 1)
    XCTAssertEqual(x / y, 0)
    XCTAssertEqual(y / x, -1)
    XCTAssertEqual(y / y, 1)

    XCTAssertEqual(x % 3, 1)
    XCTAssertEqual(x % -3, 1)
    XCTAssertEqual(y % 3, -1)
    XCTAssertEqual(y % -3, -1)

    XCTAssertEqual(-y, 1111)
    XCTAssertEqual(-x, -1000)
  }

  func testNested() {
    do {
      let x = _UInt1024.max
      let (y, o) = x.addingReportingOverflow(1)
      XCTAssertEqual(y, 0)
      XCTAssertTrue(y == (0 as Int))
      XCTAssertTrue(o)
    }

    do {
      let x = _Int1024.max
      let (y, o) = x.addingReportingOverflow(1)
      XCTAssertEqual(y, _Int1024.min)
      XCTAssertLessThan(y, 0)
      XCTAssertTrue(y < (0 as Int))
      XCTAssertTrue(y < (0 as UInt))
      XCTAssertTrue(o)
    }

    XCTAssertFalse(_UInt1024.isSigned)
    XCTAssertEqual(_UInt1024.bitWidth, 1024)
    XCTAssertTrue(_Int1024.isSigned)
    XCTAssertEqual(_Int1024.bitWidth, 1024)

    XCTAssertTrue(
      _UInt1024.max.words.elementsEqual(
        repeatElement(UInt.max, count: 1024 / UInt.bitWidth)
      )
    )
  }

  func testInitialization() {
    XCTAssertTrue(_UInt16(UInt16.max) == UInt16.max)
    XCTAssertNil(_UInt16(exactly: UInt32.max))
    XCTAssertEqual(_UInt16(truncatingIfNeeded: UInt64.max), _UInt16.max)
  }

  func testInitialization_Overflow() {
    // TODO: expectCrashLater()
    // _ = _UInt16(UInt32.max)
  }

  func testMagnitude() {
    XCTAssertTrue(_UInt16.min.magnitude == UInt16.min.magnitude)
    XCTAssertTrue((42 as _UInt16).magnitude == (42 as UInt16).magnitude)
    XCTAssertTrue(_UInt16.max.magnitude == UInt16.max.magnitude)

    XCTAssertTrue(_Int16.min.magnitude == Int16.min.magnitude)
    XCTAssertTrue((-42 as _Int16).magnitude == (-42 as Int16).magnitude)
    XCTAssertTrue(_Int16().magnitude == Int16(0).magnitude) // See SR-6602.
    XCTAssertTrue((42 as _Int16).magnitude == (42 as Int16).magnitude)
    XCTAssertTrue(_Int16.max.magnitude == Int16.max.magnitude)
  }

  func testTwoWords() {
    typealias DW = DoubleWidth<Int>

    XCTAssertEqual(-1 as DW, DW(truncatingIfNeeded: -1 as Int8))

    XCTAssertNil(Int(exactly: DW(Int.min) - 1))
    XCTAssertNil(Int(exactly: DW(Int.max) + 1))

    XCTAssertTrue(DW(Int.min) - 1 < Int.min)
    XCTAssertTrue(DW(Int.max) + 1 > Int.max)
  }

  func testBitwise_LeftAndRightShifts() {
    typealias _UInt64 = DoubleWidth<DoubleWidth<DoubleWidth<UInt8>>>
    typealias _Int64 = DoubleWidth<DoubleWidth<DoubleWidth<Int8>>>

    func f<T: FixedWidthInteger, U: FixedWidthInteger>(_ x: T, type: U.Type) {
      let y = U(x)
      XCTAssertEqual(T.bitWidth, U.bitWidth)
      for i in -(T.bitWidth + 1)...(T.bitWidth + 1) {
        XCTAssertTrue(x << i == y << i)
        XCTAssertTrue(x >> i == y >> i)

        XCTAssertTrue(x &<< i == y &<< i)
        XCTAssertTrue(x &>> i == y &>> i)
      }
    }

    f(1 as UInt64, type: _UInt64.self)
    f(~(~0 as UInt64 >> 1), type: _UInt64.self)
    f(UInt64.max, type: _UInt64.self)
    // 0b01010101_10100101_11110000_10100101_11110000_10100101_11110000_10100101
    f(17340530535757639845 as UInt64, type: _UInt64.self)

    f(1 as Int64, type: _Int64.self)
    f(Int64.min, type: _Int64.self)
    f(Int64.max, type: _Int64.self)
    // 0b01010101_10100101_11110000_10100101_11110000_10100101_11110000_10100101
    f(6171603459878809765 as Int64, type: _Int64.self)
  }

  func testRemainder_ByZero() {
    func f(_ x: _Int1024, _ y: _Int1024) -> _Int1024 {
      return x % y
    }
    // TODO: expectCrashLater()
    // _ = f(42, 0)
  }

  func testRemainder_ByMinusOne() {
    func f(_ x: _Int256, _ y: _Int256) -> _Int256 {
      return x.remainderReportingOverflow(dividingBy: y).partialValue
    }
    XCTAssertEqual(f(.max, -1), 0)
    XCTAssertEqual(f(.min, -1), 0)
  }

  func testDivision_ByZero() {
    func f(_ x: _Int1024, _ y: _Int1024) -> _Int1024 {
      return x / y
    }
    // TODO: expectCrashLater()
    // _ = f(42, 0)
  }

  func testDivision_ByMinusOne() {
    func f(_ x: _Int1024) -> _Int1024 {
      return x / -1
    }
    // TODO: expectCrashLater()
    // _ = f(_Int1024.min)
  }

  func testMultipleOf() {
    func isMultipleTest<T: FixedWidthInteger>(type: T.Type) {
      XCTAssertTrue(T.min.isMultiple(of: 2))
      XCTAssertFalse(T.max.isMultiple(of: 10))
      // Test that these do not crash.
      XCTAssertTrue((0 as T).isMultiple(of: 0))
      XCTAssertFalse((1 as T).isMultiple(of: 0))
      XCTAssertTrue(T.min.isMultiple(of: 0 &- 1))
    }
    isMultipleTest(type: _Int128.self)
    isMultipleTest(type: _UInt128.self)
  }

  func testMultiplication_ByMinusOne() {
    func f(_ x: _Int1024) -> _Int1024 {
      return x * -1
    }
    // TODO: expectCrashLater()
    // _ = f(_Int1024.min)
  }

  func testConversions() {
    XCTAssertTrue(_Int16(1 << 15 - 1) == Int(1 << 15 - 1))
    XCTAssertTrue(_Int16(-1 << 15) == Int(-1 << 15))
    XCTAssertTrue(_UInt16(1 << 16 - 1) == Int(1 << 16 - 1))
    XCTAssertTrue(_UInt16(0) == Int(0))

    XCTAssertTrue(_Int16(Double(1 << 15 - 1)) == Int(1 << 15 - 1))
    XCTAssertTrue(_Int16(Double(-1 << 15)) == Int(-1 << 15))
    XCTAssertTrue(_UInt16(Double(1 << 16 - 1)) == Int(1 << 16 - 1))
    XCTAssertTrue(_UInt16(Double(0)) == Int(0))

    XCTAssertTrue(_Int16(Double(1 << 15 - 1) + 0.9) == Int(1 << 15 - 1))
    XCTAssertTrue(_Int16(Double(-1 << 15) - 0.9) == Int(-1 << 15))
    XCTAssertTrue(_UInt16(Double(1 << 16 - 1) + 0.9) == Int(1 << 16 - 1))
    XCTAssertTrue(_UInt16(Double(0) - 0.9) == Int(0))

    XCTAssertEqual(_Int16(0.00001), 0)
    XCTAssertEqual(_UInt16(0.00001), 0)
  }

  func testConversions_Exact() {
    XCTAssertEqual(
      _Int16(Double(1 << 15 - 1)),
      _Int16(exactly: Double(1 << 15 - 1))
    )
    XCTAssertEqual(
      _Int16(Double(-1 << 15)),
      _Int16(exactly: Double(-1 << 15))
    )
    XCTAssertEqual(
      _UInt16(Double(1 << 16 - 1)),
      _UInt16(exactly: Double(1 << 16 - 1))
    )
    XCTAssertEqual(
      _UInt16(Double(0)),
      _UInt16(exactly: Double(0))
    )

    XCTAssertNil(_Int16(exactly: Double(1 << 15 - 1) + 0.9))
    XCTAssertNil(_Int16(exactly: Double(-1 << 15) - 0.9))
    XCTAssertNil(_UInt16(exactly: Double(1 << 16 - 1) + 0.9))
    XCTAssertNil(_UInt16(exactly: Double(0) - 0.9))

    XCTAssertNil(_Int16(exactly: Double(1 << 15)))
    XCTAssertNil(_Int16(exactly: Double(-1 << 15) - 1))
    XCTAssertNil(_UInt16(exactly: Double(1 << 16)))
    XCTAssertNil(_UInt16(exactly: Double(-1)))

    XCTAssertNil(_Int16(exactly: 0.00001))
    XCTAssertNil(_UInt16(exactly: 0.00001))

    XCTAssertNil(_UInt16(exactly: Double.nan))
    XCTAssertNil(_UInt16(exactly: Float.nan))
    XCTAssertNil(_UInt16(exactly: Double.infinity))
    XCTAssertNil(_UInt16(exactly: Float.infinity))
  }

  func testConversions_SignedMax() {
    // TODO: expectCrashLater()
    // _ = _Int16(1 << 15)
  }

  func testConversions_SignedMin() {
    // TODO: expectCrashLater()
    // _ = _Int16(-1 << 15 - 1)
  }

  func testConversions_UnsignedMax() {
    // TODO: expectCrashLater()
    // _ = _UInt16(1 << 16)
  }

  func testConversions_UnsignedMin() {
    // TODO: expectCrashLater()
    // _ = _UInt16(-1)
  }

  func testConversions_ToAndFromString<Number: FixedWidthInteger>(
    _ expectedNumber: Number,
    _ expectedString: String,
    radix: Int,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    let actualString = String(expectedNumber, radix: radix)
    XCTAssertEqual(expectedString, actualString, file: file, line: line)
    let actualNumber = Number(expectedString, radix: radix)
    XCTAssertEqual(expectedNumber, actualNumber, file: file, line: line)
  }

  func testConversions_ToAndFromString_Binary() {
    testConversions_ToAndFromString(
      _Int128.max,
      """
      111111111111111111111111111111111111111111111111111111111111111\
      1111111111111111111111111111111111111111111111111111111111111111
      """,
      radix: 2
    )
    testConversions_ToAndFromString(
      _Int128.min,
      """
      -1000000000000000000000000000000000000000000000000000000000000000\
      0000000000000000000000000000000000000000000000000000000000000000
      """,
      radix: 2
    )
  }

  func testConversions_ToAndFromString_Decimal() {
    testConversions_ToAndFromString(
      _Int256.max,
      """
      5789604461865809771178549250434395392663\
      4992332820282019728792003956564819967
      """,
      radix: 10
    )
    testConversions_ToAndFromString(
      _Int256.min,
      """
      -5789604461865809771178549250434395392663\
      4992332820282019728792003956564819968
      """,
      radix: 10
    )
  }

  func testConversions_ToAndFromString_Hexadecimal() {
    testConversions_ToAndFromString(
      _Int512.max,
      """
      7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff\
      ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
      """,
      radix: 16
    )
    testConversions_ToAndFromString(
      _Int512.min,
      """
      -8000000000000000000000000000000000000000000000000000000000000000\
      0000000000000000000000000000000000000000000000000000000000000000
      """,
      radix: 16
    )
  }

  func testWords() {
    XCTAssertTrue(_Int16(0).words.elementsEqual([0]))
    XCTAssertTrue(_Int16(1).words.elementsEqual([1]))
    XCTAssertTrue(_Int16(-1).words.elementsEqual([UInt.max]))
    XCTAssertTrue(_Int16(256).words.elementsEqual([256]))
    XCTAssertTrue(_Int16(-256).words.elementsEqual([UInt.max - 255]))
    XCTAssertTrue(_Int16.max.words.elementsEqual([32767]))
    XCTAssertTrue(_Int16.min.words.elementsEqual([UInt.max - 32767]))

    XCTAssertTrue(
      (0 as _Int1024).words.elementsEqual(
        repeatElement(0 as UInt, count: 1024 / UInt.bitWidth)
      )
    )
    XCTAssertTrue(
      (-1 as _Int1024).words.elementsEqual(
        repeatElement(UInt.max, count: 1024 / UInt.bitWidth)
      )
    )
    XCTAssertTrue(
      (1 as _Int1024).words.elementsEqual(
        [1] + Array(repeating: 0, count: 1024 / UInt.bitWidth - 1)
      )
    )
  }

  func testConditionalConformance() {
    func checkSignedIntegerConformance<T: SignedInteger>(_: T) {}
    func checkUnsignedIntegerConformance<T: UnsignedInteger>(_: T) {}

    checkSignedIntegerConformance(0 as _Int128)
    checkSignedIntegerConformance(0 as _Int1024)

    checkUnsignedIntegerConformance(0 as _UInt128)
    checkUnsignedIntegerConformance(0 as _UInt1024)
  }
}
