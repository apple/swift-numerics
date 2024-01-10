//===--- BigUIntTests.swift -----------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import BigIntModule
import XCTest

extension BigUInt {

  static func fac(_ n: BigUInt) -> BigUInt {
    return stride(from: n, to: 1, by: -1).reduce(into: 1, { $0 *= $1 })
  }

  // inspired by https://eli.thegreenplace.net/2009/03/21/efficient-integer-exponentiation-algorithms
  static func pow(_ lhs: BigUInt, _ rhs: BigUInt) -> BigUInt {
    let bits_of_n = { (n: BigUInt) -> [Int] in
      var bits: [Int] = []
      var n = n
      while n != 0 {
        bits.append(Int(n % 2))
        n /= 2
      }

      return bits
    }

    var r: BigUInt = 1
    for bit in bits_of_n(rhs).reversed() {
      r *= r
      if bit == 1 {
        r *= lhs
      }
    }

    return r
  }
}

final class BigUIntTests: XCTestCase {

  /// Python: `bitWidth = 1024; -(2 ** (bitWidth - 1))`
  static let descriptionInt1024Min: String =
    """
    -89884656743115795386465259539451236680898848947115328636715040578866337902\
    750481566354238661203768010560056939935696678829394884407208311246423715319\
    737062188883946712432742638151109800623047059726541476042502884419075341171\
    231440736956555270413618581675255342293149119973622969239858152417678164812\
    112068608
    """

  /// Python: `bitWidth = 1024; (2 ** (bitWidth - 1)) - 1`
  static let descriptionInt1024Max: String =
    """
    89884656743115795386465259539451236680898848947115328636715040578866337902\
    750481566354238661203768010560056939935696678829394884407208311246423715319\
    737062188883946712432742638151109800623047059726541476042502884419075341171\
    231440736956555270413618581675255342293149119973622969239858152417678164812\
    112068607
    """

  /// Python: `numpy.base_repr(math.factorial(512), base=36)`
  static let descriptionFactorial512_radix36: String =
    """
    7FA5Y7EHR9XHMQ519MBHGYOF8XDYMUX8OZHO9WF1KCM0SSPXV2V45UA73BAFRYM2PFB8CZLTODV\
    OS3QWA7PYFJ7WAFBI4VF371E27N6XZ4LGWHMFDS4ZH1O3DGNFG4YABUE1G90ORGRTIOGSQVZLSQ\
    4TKHKHIQ262JVQ0J6LSKAPN5I65AJD33XODVHRNWJ1VSO0Q2FBOUNCPGQG2SFQKR17XHF1OLTV2\
    MVNJVTDAIYWVJ9ZH7KXT0EPS00IGIVC7MNCU25HFWE37KNMSJQUL5ALUCE5XZVPFQCQGEVEB93B\
    GA8LKG67PVZ7Q9QMQKIVNIMPT2973MVDTD1D1A0A4QT6NBZYR0TGSZXBV1PD0CHW4SKZJSLBS4Z\
    W5WCKDY8BCQCE17KKADVLCTVSQL1BZ2PL52DDPB8S5L0ZEG2ZAZF9V4TNJJNO1D9U9JU7B264QZ\
    5GLHC3Q0Y3BTECGTI8GRENQ2FV4HSEZKPM9OG302KLSY9MBCSOO0FN229AST84TT87LYWOOS71C\
    54RPJ9RTO9875Z9DE3HPH89EW5I3SV219O04UU09A4KME7DD7IH49ABO79NR4EXFX1VLL4YOHSA\
    7AHD1LS5YKZ66F4UPG0RCBGG000000000000000000000000000000000000000000000000000\
    000000000000000000000000000000000000000000000000000000000000000000000000000
    """

  // MARK: - Basic arithmetic

  func testDivision() {
    let num1 = BigUInt("18446744073709551616")!
    let den1 = BigUInt(123)
    let expected1 = BigUInt(UInt64(149973529054549200))
    XCTAssertEqual(num1 / den1, expected1)
    
    let num2 = BigUInt.pow(BigUInt(10), 100)
    let den2: BigUInt = 3
    let expected2: BigUInt = BigUInt(String(repeating: "3", count: 100))!
    let actual2 = num2 / den2
    XCTAssertEqual(actual2, expected2)
    
    let num3 = BigUInt.pow(BigUInt(10), 97)
    let den3: BigUInt = BigUInt("33333333333333333333")!
    let expected3: BigUInt = BigUInt("300000000000000000003000000000000000000030000000000000000000300000000000000000")!
    let actual3 = num3 / den3
    XCTAssertEqual(actual3, expected3)
    
    let foo = BigUInt("12345678901234567890123456789012345678901234567890123456789012345678901234567890")!
    let bar = BigUInt("351235231535161613134135135135")!
    let baz = foo / bar
    XCTAssertEqual(baz, BigUInt("35149318157164029153358504918339691272847595997760")!)

    XCTAssertNotNil(BigUInt(exactly: 2.4e39))
    XCTAssertNotNil(BigUInt(exactly: 1e38))
    XCTAssertEqual(BigUInt(2.4e39) / BigUInt(1e38), BigUInt(24))
    
    for _ in 0 ..< 100 {
      let expected = BigUInt(Float64.random(in: 0x1p64 ... 0x1p255))
      let divisor  = BigUInt(Float64.random(in: 0x1p64 ... 0x1p128))
      let (quotient, remainder) = expected.quotientAndRemainder(dividingBy: divisor)
      let actual = divisor * quotient + remainder
      XCTAssertEqual(quotient,  expected / divisor)
      XCTAssertEqual(remainder, expected % divisor)
      XCTAssertEqual(
        actual, expected,
        """
        ## FAILURE ##
        ~~~~~~~~~~~~~
              actual: \(actual)
         != expected: \(expected)
        ~~~~~~~~~~~~~
             divisor: \(divisor)
          * quotient: \(quotient)
         + remainder: \(remainder)
        ~~~~~~~~~~~~~
        """)
    }
  }

  func testFactorial() {
    var expectedNumber: BigUInt?
    var actualNumber: BigUInt!
    var actualString: String!

    measure {
      expectedNumber = BigUInt(Self.descriptionFactorial512_radix36, radix: 36)
      actualNumber = BigUInt.fac(512)
      actualString = String(actualNumber, radix: 36, uppercase: true)
    }

    XCTAssertEqual(actualNumber, expectedNumber)
    XCTAssertEqual(actualString, Self.descriptionFactorial512_radix36)

    XCTAssertEqual(BigUInt.fac(0), 1)
    XCTAssertEqual(BigUInt.fac(1), 1)
    XCTAssertEqual(BigUInt.fac(2), 2)
    XCTAssertEqual(BigUInt.fac(3), 6)
    XCTAssertEqual(BigUInt.fac(4), 24)
    XCTAssertEqual(BigUInt.fac(5), 120)
    XCTAssertEqual(BigUInt.fac(6), 720)
    XCTAssertEqual(BigUInt.fac(7), 5040)
    XCTAssertEqual(BigUInt.fac(8), 40320)
    XCTAssertEqual(BigUInt.fac(9), 362880)
  }

  func testMath() {
    let foo = BigUInt.pow(10, 20)
    let bar = BigUInt("1234567890123456789012345678901234567890")!

    let baz = foo + bar

    XCTAssertEqual(baz, BigUInt("1234567890123456789112345678901234567890")!)

    let fooz = foo >> BigUInt(10)
    XCTAssertEqual(fooz, foo / 1024)

    let barz = BigUInt(1) << 64
    XCTAssertEqual(barz, BigUInt(UInt64.max) + 1)
  }

  func testTrailingZeroCount() {
    let foo = BigUInt(1) << 300
    XCTAssertEqual(foo.trailingZeroBitCount, 300)
    
    let bar = (BigUInt(1) << 300) + 0b101000
    XCTAssertEqual(bar.trailingZeroBitCount, 3)
  }

  // MARK: - Comparing and hashing

  func testComparable() {
    let foo = BigUInt("1234567890123456789012345678901234567890")!
    let bar = foo * foo

    XCTAssertLessThan(foo, bar)
    XCTAssertFalse(foo < foo)
    XCTAssertFalse(bar < bar)
    XCTAssertFalse(foo > foo)
    XCTAssertFalse(bar > bar)
    XCTAssertGreaterThan(bar, foo)
  }

  func testHashable() {
    let foo = BigInt("1234567890123456789012345678901234567890")!
    let bar = BigInt("1234567890123456789112345678901234567890")!
    let baz: BigInt = 153

    let dict = [foo: "Hello", bar: "World", baz: "!"]
    let hash = foo.hashValue
    print(hash)

    XCTAssertEqual(dict[foo]!, "Hello")
    XCTAssertEqual(dict[bar]!, "World")
  }
  
  func testClampingConversion() {
    XCTAssertEqual(BigUInt(clamping: UInt64.max), BigUInt(UInt64(18446744073709551615)))
  }

  // MARK: - Converting to/from textual representations

  func testCodable() throws {
    let lowerBound = BigUInt("0")!
    let upperBound = BigUInt("+1234567890123456789012345678901234567890")!
    let expectedRange: Range<BigUInt> = lowerBound ..< upperBound

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let data = try encoder.encode(expectedRange)
    let actualRange = try decoder.decode(Range<BigUInt>.self, from: data)

    XCTAssertEqual(actualRange, expectedRange)
  }

  func testCustomStringConvertible() {
    XCTAssertEqual("\(BigUInt(UInt64.min) + 0)", "0")
    XCTAssertEqual("\(BigUInt(UInt64.min) + 1)", "1")
    XCTAssertEqual("\(BigUInt(UInt64.min) + 2)", "2")

    XCTAssertEqual("\(BigUInt(UInt64.max) - 2)", "18446744073709551613")
    XCTAssertEqual("\(BigUInt(UInt64.max) - 1)", "18446744073709551614")
    XCTAssertEqual("\(BigUInt(UInt64.max) + 0)", "18446744073709551615")
    XCTAssertEqual("\(BigUInt(UInt64.max) + 1)", "18446744073709551616")
    XCTAssertEqual("\(BigUInt(UInt64.max) + 2)", "18446744073709551617")

    XCTAssertEqual("\(BigUInt(Int64.max) - 2)", "9223372036854775805")
    XCTAssertEqual("\(BigUInt(Int64.max) - 1)", "9223372036854775806")
    XCTAssertEqual("\(BigUInt(Int64.max) + 0)", "9223372036854775807")
    XCTAssertEqual("\(BigUInt(Int64.max) + 1)", "9223372036854775808")
    XCTAssertEqual("\(BigUInt(Int64.max) + 2)", "9223372036854775809")

    XCTAssertEqual("\(+(BigUInt(1) << 1023) - 1)", Self.descriptionInt1024Max)
  }

  func testLosslessStringConvertible() {
    XCTAssertNil(BigUInt(""))
    XCTAssertNil(BigUInt("+"))
    XCTAssertNil(BigUInt("A"))
    XCTAssertNil(BigUInt(" 0"))
    XCTAssertNil(BigUInt("0 "))

    XCTAssertEqual(BigUInt(UInt64.min) + 0, BigUInt("0"))
    XCTAssertEqual(BigUInt(UInt64.min) + 1, BigUInt("1"))
    XCTAssertEqual(BigUInt(UInt64.min) + 2, BigUInt("2"))

    XCTAssertEqual(BigUInt(UInt64.max) - 2, BigUInt("18446744073709551613"))
    XCTAssertEqual(BigUInt(UInt64.max) - 1, BigUInt("18446744073709551614"))
    XCTAssertEqual(BigUInt(UInt64.max) + 0, BigUInt("18446744073709551615"))
    XCTAssertEqual(BigUInt(UInt64.max) + 1, BigUInt("18446744073709551616"))
    XCTAssertEqual(BigUInt(UInt64.max) + 2, BigUInt("18446744073709551617"))

    XCTAssertEqual(BigUInt(Int64.max) - 2, BigUInt("9223372036854775805"))
    XCTAssertEqual(BigUInt(Int64.max) - 1, BigUInt("9223372036854775806"))
    XCTAssertEqual(BigUInt(Int64.max) + 0, BigUInt("9223372036854775807"))
    XCTAssertEqual(BigUInt(Int64.max) + 1, BigUInt("9223372036854775808"))
    XCTAssertEqual(BigUInt(Int64.max) + 2, BigUInt("9223372036854775809"))

    XCTAssertEqual(+(BigUInt(1) << 1023) - 1, BigUInt(Self.descriptionInt1024Max))
  }

  func testRadicesAndNumerals() {
    for radix in 2 ... 36 {
      for uppercase in [false, true] {
        for _ in 0 ..< 100 {
          let expectedNumber = BigUInt(UInt.random(in: .min ... .max))
          let expectedString = String(expectedNumber,
                                      radix: radix,
                                      uppercase: uppercase)
          let actualNumber = BigUInt(expectedString, radix: radix)
          XCTAssertEqual(actualNumber, expectedNumber)
          if radix == 10 {
            let actualString = expectedNumber.description
            XCTAssertEqual(actualString, expectedString)
          }
        }
      }
    }
  }

  // MARK: - Converting from floating-point binary types

  func testBinaryFloatingPoint<T>(_ type: T.Type) where T: BinaryFloatingPoint {
    var expected = BigUInt(T.greatestFiniteMagnitude.significandBitPattern)
    expected |= BigUInt(1) << T.significandBitCount
    expected <<= T.greatestFiniteMagnitude.exponent
    expected >>= T.significandBitCount

    XCTAssertEqual(BigUInt(exactly: +T.greatestFiniteMagnitude), +expected)
    XCTAssertEqual(BigUInt(+T.greatestFiniteMagnitude), +expected)

    XCTAssertNil(BigUInt(exactly: +T.infinity))

    XCTAssertNil(BigUInt(exactly: +T.leastNonzeroMagnitude))
    XCTAssertEqual(BigUInt(+T.leastNonzeroMagnitude), 0)

    XCTAssertNil(BigUInt(exactly: +T.leastNormalMagnitude))
    XCTAssertEqual(BigUInt(+T.leastNormalMagnitude), 0)

    XCTAssertNil(BigUInt(exactly: T.nan))
    XCTAssertNil(BigUInt(exactly: T.signalingNaN))

    XCTAssertNil(BigUInt(exactly: +T.pi))
    XCTAssertEqual(BigUInt(+T.pi), +3)

    XCTAssertNil(BigUInt(exactly: +T.ulpOfOne))
    XCTAssertEqual(BigUInt(+T.ulpOfOne), 0)

    XCTAssertEqual(BigUInt(exactly: +T.zero), 0)
    XCTAssertEqual(BigUInt(+T.zero), 0)
  }

  func testBinaryFloatingPoint() {
    testBinaryFloatingPoint(Float32.self)
    testBinaryFloatingPoint(Float64.self)
    #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    testBinaryFloatingPoint(Float80.self)
    #endif

    for _ in 0 ..< 100 {
      let small = Float32.random(in: 0 ... +10)
      XCTAssertEqual(BigUInt(small), BigUInt(Int64(small)))

      let large = Float32.random(in: 0 ... +0x1p23)
      XCTAssertEqual(BigUInt(large), BigUInt(Int64(large)))
    }

    for _ in 0 ..< 100 {
      let small = Float64.random(in: 0 ... +10)
      XCTAssertEqual(BigUInt(small), BigUInt(Int64(small)))

      let large = Float64.random(in: -0x1p52 ... +0x1p52)
      XCTAssertEqual(BigInt(large), BigInt(Int64(large)))
    }

    #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    for _ in 0 ..< 100 {
      let small = Float80.random(in: 0 ... +10)
      XCTAssertEqual(BigUInt(small), BigUInt(Int64(small)))

      let large = Float80.random(in: 0 ..< +0x1p63)
      XCTAssertEqual(BigUInt(large), BigUInt(Int64(large)))
    }
    #endif
  }
}
