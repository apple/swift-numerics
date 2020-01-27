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

extension BigInt {

  static func fac(_ n: BigInt) -> BigInt {
    precondition(n >= 0, "Factorial of a negative integer is undefined")
    return stride(from: n, to: 1, by: -1).reduce(into: 1, { $0 *= $1 })
  }

  // inspired by https://eli.thegreenplace.net/2009/03/21/efficient-integer-exponentiation-algorithms
  static func pow(_ lhs: BigInt, _ rhs: BigInt) -> BigInt {
    let bits_of_n = {
      (n: BigInt) -> [Int] in
      var bits: [Int] = []
      var n = n
      while n != 0 {
        bits.append(Int(n % 2))
        n /= 2
      }

      return bits
    }

    var r: BigInt = 1
    for bit in bits_of_n(rhs).reversed() {
      r *= r
      if bit == 1 {
        r *= lhs
      }
    }

    return r
  }
}

final class BigIntTests: XCTestCase {

  #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
  typealias FloatXX = Float80
  #else
  typealias FloatXX = Float64
  #endif

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

  /// Python: `hex(int(sys.float_info.max))`
  static let descriptionFloat64Max_radix16: String =
    """
    FFFFFFFFFFFFF80000000000000000000000000000000000000000000000000000000000000\
    000000000000000000000000000000000000000000000000000000000000000000000000000\
    000000000000000000000000000000000000000000000000000000000000000000000000000\
    0000000000000000000000000000000
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
    let num1 = BigInt("18446744073709551616")!
    let den1 = BigInt(123)
    let expected1 = BigInt(149973529054549200)
    XCTAssertEqual(num1 / den1, expected1)
    
    let num2 = BigInt.pow(BigInt(10), 100)
    let den2: BigInt = 3
    let expected2: BigInt = BigInt(String(repeating: "3", count: 100))!
    let actual2 = num2 / den2
    XCTAssertEqual(actual2, expected2)
    
    let num3 = BigInt.pow(BigInt(10), 97)
    let den3: BigInt = BigInt("33333333333333333333")!
    let expected3: BigInt = BigInt("300000000000000000003000000000000000000030000000000000000000300000000000000000")!
    let actual3 = num3 / den3
    XCTAssertEqual(actual3, expected3)
    
    let foo = BigInt("12345678901234567890123456789012345678901234567890123456789012345678901234567890")!
    let bar = BigInt("351235231535161613134135135135")!
    let baz = foo / bar
    XCTAssertEqual(baz, BigInt("35149318157164029153358504918339691272847595997760")!)

    XCTAssertNotNil(BigInt(exactly: 2.4e39))
    XCTAssertNotNil(BigInt(exactly: 1e38))
    XCTAssertEqual(BigInt(2.4e39) / BigInt(1e38), BigInt(24))
  }

  func testFactorial() {
    var expectedNumber: BigInt?
    var actualNumber: BigInt!
    var actualString: String!

    measure {
      expectedNumber = BigInt(Self.descriptionFactorial512_radix36, radix: 36)
      actualNumber = BigInt.fac(512)
      actualString = String(actualNumber, radix: 36, uppercase: true)
    }

    XCTAssertEqual(actualNumber, expectedNumber)
    XCTAssertEqual(actualString, Self.descriptionFactorial512_radix36)

    XCTAssertEqual(BigInt.fac(0), 1)
    XCTAssertEqual(BigInt.fac(1), 1)
    XCTAssertEqual(BigInt.fac(2), 2)
    XCTAssertEqual(BigInt.fac(3), 6)
    XCTAssertEqual(BigInt.fac(4), 24)
    XCTAssertEqual(BigInt.fac(5), 120)
    XCTAssertEqual(BigInt.fac(6), 720)
    XCTAssertEqual(BigInt.fac(7), 5040)
    XCTAssertEqual(BigInt.fac(8), 40320)
    XCTAssertEqual(BigInt.fac(9), 362880)
  }

  func testMath() {
    let foo = BigInt.pow(10, 20)
    let bar = BigInt("1234567890123456789012345678901234567890")!

    let baz = foo + bar

    XCTAssertEqual(baz, BigInt("1234567890123456789112345678901234567890")!)

    let fooz = foo >> BigInt(10)
    XCTAssertEqual(fooz, foo / 1024)

    let barz = BigInt(1) << 64
    XCTAssertEqual(barz, BigInt(UInt.max) + 1)
  }

  func testNegation() {
    let foo = BigInt("1234567890123456789012345678901234567890")!
    let bar = BigInt(0) - foo

    XCTAssertEqual(-foo, bar)

    var baz = foo
    baz.negate()
    XCTAssertEqual(baz, bar)
  }

  func testSignum() {
    XCTAssertEqual(BigInt(-0x1p1023).signum(), -1)
    XCTAssertEqual(BigInt(Int64.min).signum(), -1)
    XCTAssertEqual(BigInt(Int32.min).signum(), -1)
    XCTAssertEqual(BigInt(Int16.min).signum(), -1)
    XCTAssertEqual(BigInt(Int8.min).signum(), -1)
    XCTAssertEqual(BigInt(-1).signum(), -1)
    XCTAssertEqual(BigInt(0).signum(), 0)
    XCTAssertEqual(BigInt(+1).signum(), +1)
    XCTAssertEqual(BigInt(Int8.max).signum(), +1)
    XCTAssertEqual(BigInt(Int16.max).signum(), +1)
    XCTAssertEqual(BigInt(Int32.max).signum(), +1)
    XCTAssertEqual(BigInt(Int64.max).signum(), +1)
    XCTAssertEqual(BigInt(+0x1p1023).signum(), +1)
  }

  // MARK: - Comparing and hashing

  func testComparable() {
    let foo = BigInt("1234567890123456789012345678901234567890")!
    let bar = foo * foo

    XCTAssertLessThan(foo, bar)
    XCTAssertFalse(foo < foo)
    XCTAssertFalse(bar < bar)
    XCTAssertFalse(foo > foo)
    XCTAssertFalse(bar > bar)
    XCTAssertGreaterThan(bar, foo)

    let baz = bar * -1

    XCTAssertLessThan(baz, foo)
    XCTAssertNotEqual(bar, baz)
    XCTAssertFalse(baz < baz)
  }

  func testComparison() {
    let foo = BigInt(-10)
    let bar = BigInt(-20)

    XCTAssert(foo > bar)
    XCTAssert(bar < foo)
    XCTAssert(foo == BigInt(-10))

    let baz = BigInt.pow(foo, -bar)
    XCTAssertEqual(baz, BigInt("100000000000000000000")!)
  }

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
  
  func testClampingConversion() {
    XCTAssertEqual(BigInt(clamping: UInt.max), BigInt(UInt(18446744073709551615)))
  }

  func testUIntConversion() {
    let foo = BigInt(UInt.max)
    XCTAssertNotEqual(foo, BigInt(-1))

    let bar = BigInt(bitPattern: UInt.max)
    XCTAssertEqual(bar, BigInt(-1))
  }

  // MARK: - Converting to/from textual representations

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

    XCTAssertEqual("\(-(BigInt(1) << 1023))",     Self.descriptionInt1024Min)
    XCTAssertEqual("\(+(BigInt(1) << 1023) - 1)", Self.descriptionInt1024Max)
  }

  func testLosslessStringConvertible() {
    XCTAssertNil(BigInt(""))
    XCTAssertNil(BigInt("-"))
    XCTAssertNil(BigInt("+"))
    XCTAssertNil(BigInt("A"))
    XCTAssertNil(BigInt(" 0"))
    XCTAssertNil(BigInt("0 "))

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

    XCTAssertEqual(-(BigInt(1) << 1023),     BigInt(Self.descriptionInt1024Min))
    XCTAssertEqual(+(BigInt(1) << 1023) - 1, BigInt(Self.descriptionInt1024Max))
  }

  func testRadicesAndNumerals() {
    for radix in 2 ... 36 {
      for uppercase in [false, true] {
        for _ in 0 ..< 100 {
          let expectedNumber = BigInt(Int.random(in: .min ... .max))
          let expectedString = String(expectedNumber,
                                      radix: radix,
                                      uppercase: uppercase)
          let actualNumber = BigInt(expectedString, radix: radix)
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

  func testFloatingPoint_greatestFiniteMagnitude() {
    XCTAssertEqual(BigInt(exactly: -Float64.greatestFiniteMagnitude),
                   BigInt("-\(Self.descriptionFloat64Max_radix16)", radix: 16))
    XCTAssertEqual(BigInt(exactly: +Float64.greatestFiniteMagnitude),
                   BigInt("+\(Self.descriptionFloat64Max_radix16)", radix: 16))

    XCTAssertEqual(BigInt(-Float64.greatestFiniteMagnitude),
                   BigInt("-\(Self.descriptionFloat64Max_radix16)", radix: 16))
    XCTAssertEqual(BigInt(+Float64.greatestFiniteMagnitude),
                   BigInt("+\(Self.descriptionFloat64Max_radix16)", radix: 16))
  }

  func testFloatingPoint_infinity() {
    XCTAssertNil(BigInt(exactly: -Float32.infinity))
    XCTAssertNil(BigInt(exactly: -Float64.infinity))
    XCTAssertNil(BigInt(exactly: -FloatXX.infinity))

    XCTAssertNil(BigInt(exactly: +Float32.infinity))
    XCTAssertNil(BigInt(exactly: +Float64.infinity))
    XCTAssertNil(BigInt(exactly: +FloatXX.infinity))
  }

  func testFloatingPoint_leastNonzeroMagnitude() {
    XCTAssertNil(BigInt(exactly: -Float32.leastNonzeroMagnitude))
    XCTAssertNil(BigInt(exactly: -Float64.leastNonzeroMagnitude))
    XCTAssertNil(BigInt(exactly: -FloatXX.leastNonzeroMagnitude))

    XCTAssertNil(BigInt(exactly: +Float32.leastNonzeroMagnitude))
    XCTAssertNil(BigInt(exactly: +Float64.leastNonzeroMagnitude))
    XCTAssertNil(BigInt(exactly: +FloatXX.leastNonzeroMagnitude))

    XCTAssertEqual(BigInt(-Float32.leastNonzeroMagnitude), 0)
    XCTAssertEqual(BigInt(-Float64.leastNonzeroMagnitude), 0)
    XCTAssertEqual(BigInt(-FloatXX.leastNonzeroMagnitude), 0)

    XCTAssertEqual(BigInt(+Float32.leastNonzeroMagnitude), 0)
    XCTAssertEqual(BigInt(+Float64.leastNonzeroMagnitude), 0)
    XCTAssertEqual(BigInt(+FloatXX.leastNonzeroMagnitude), 0)
  }

  func testFloatingPoint_leastNormalMagnitude() {
    XCTAssertNil(BigInt(exactly: -Float32.leastNormalMagnitude))
    XCTAssertNil(BigInt(exactly: -Float64.leastNormalMagnitude))
    XCTAssertNil(BigInt(exactly: -FloatXX.leastNormalMagnitude))

    XCTAssertNil(BigInt(exactly: +Float32.leastNormalMagnitude))
    XCTAssertNil(BigInt(exactly: +Float64.leastNormalMagnitude))
    XCTAssertNil(BigInt(exactly: +FloatXX.leastNormalMagnitude))

    XCTAssertEqual(BigInt(-Float32.leastNormalMagnitude), 0)
    XCTAssertEqual(BigInt(-Float64.leastNormalMagnitude), 0)
    XCTAssertEqual(BigInt(-FloatXX.leastNormalMagnitude), 0)

    XCTAssertEqual(BigInt(+Float32.leastNormalMagnitude), 0)
    XCTAssertEqual(BigInt(+Float64.leastNormalMagnitude), 0)
    XCTAssertEqual(BigInt(+FloatXX.leastNormalMagnitude), 0)
  }

  func testFloatingPoint_nan() {
    XCTAssertNil(BigInt(exactly: Float32.nan))
    XCTAssertNil(BigInt(exactly: Float64.nan))
    XCTAssertNil(BigInt(exactly: FloatXX.nan))
  }

  func testFloatingPoint_pi() {
    XCTAssertNil(BigInt(exactly: -Float32.pi))
    XCTAssertNil(BigInt(exactly: -Float64.pi))
    XCTAssertNil(BigInt(exactly: -FloatXX.pi))

    XCTAssertNil(BigInt(exactly: +Float32.pi))
    XCTAssertNil(BigInt(exactly: +Float64.pi))
    XCTAssertNil(BigInt(exactly: +FloatXX.pi))

    XCTAssertEqual(BigInt(-Float32.pi), -3)
    XCTAssertEqual(BigInt(-Float64.pi), -3)
    XCTAssertEqual(BigInt(-FloatXX.pi), -3)

    XCTAssertEqual(BigInt(+Float32.pi), +3)
    XCTAssertEqual(BigInt(+Float64.pi), +3)
    XCTAssertEqual(BigInt(+FloatXX.pi), +3)
  }

  func testFloatingPoint_random() {
    for _ in 0 ..< 100 {
      let small = Float32.random(in: -10 ... +10)
      XCTAssertEqual(BigInt(small), BigInt(Int64(small)))

      let large = Float32.random(in: -0x1p23 ... +0x1p23)
      XCTAssertEqual(BigInt(large), BigInt(Int64(large)))
    }

    for _ in 0 ..< 100 {
      let small = Float64.random(in: -10 ... +10)
      XCTAssertEqual(BigInt(small), BigInt(Int64(small)))

      let large = Float64.random(in: -0x1p52 ... +0x1p52)
      XCTAssertEqual(BigInt(large), BigInt(Int64(large)))
    }

    for _ in 0 ..< 100 {
      let small = FloatXX.random(in: -10 ... +10)
      XCTAssertEqual(BigInt(small), BigInt(Int64(small)))

      let large = FloatXX.random(in: -0x1p52 ... +0x1p52)
      XCTAssertEqual(BigInt(large), BigInt(Int64(large)))
    }
  }

  func testFloatingPoint_signalingNaN() {
    XCTAssertNil(BigInt(exactly: Float32.signalingNaN))
    XCTAssertNil(BigInt(exactly: Float64.signalingNaN))
    XCTAssertNil(BigInt(exactly: FloatXX.signalingNaN))
  }

  func testFloatingPoint_zero() {
    XCTAssertEqual(BigInt(exactly: -Float32.zero), 0)
    XCTAssertEqual(BigInt(exactly: -Float64.zero), 0)
    XCTAssertEqual(BigInt(exactly: -FloatXX.zero), 0)

    XCTAssertEqual(BigInt(exactly: +Float32.zero), 0)
    XCTAssertEqual(BigInt(exactly: +Float64.zero), 0)
    XCTAssertEqual(BigInt(exactly: +FloatXX.zero), 0)

    XCTAssertEqual(BigInt(-Float32.zero), 0)
    XCTAssertEqual(BigInt(-Float64.zero), 0)
    XCTAssertEqual(BigInt(-FloatXX.zero), 0)

    XCTAssertEqual(BigInt(+Float32.zero), 0)
    XCTAssertEqual(BigInt(+Float64.zero), 0)
    XCTAssertEqual(BigInt(+FloatXX.zero), 0)
  }
}
