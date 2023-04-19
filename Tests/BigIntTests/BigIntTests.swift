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

import BigIntModule
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
  
  static let descriptionFactorial512_radix10 =
    """
    3477289793132605363283045917545604711992250655643514570342474831551610412066352543473209850\
    3395022536443224331102139454529500170207006901326415311326093794135871186404471618686104089\
    9557497361427588282356254968425012480396855239725120562512065555822121708786443620799246550\
    9591872320268380814151785881725352800207863134700768597399809657208738499042913738268415847\
    1279861843038733804232977180172476769109501954575898694273251503355152959500987699927955393\
    1070378592917099002397061907147143424113252117585950817850896618433994140232823316432187410\
    3563412623863324969543199731304073425672820273985793825430484568768008623499281404119054312\
    7619743567460328184253074417752736588572162951225387238661311882154084789749310739838195608\
    1763695236422795880296204301770808809477147632428639299038833046264585834888158847387737841\
    8434136648928335862091963669797757488958218269240400578451402875222386750821375703159545267\
    2743709490491479678264100074077789791913409339353042276095514021138717365004735834735337923\
    4387609261306673773281412893026941927424000000000000000000000000000000000000000000000000000\
    000000000000000000000000000000000000000000000000000000000000000000000000000
    """
  static let descriptionFactorial512_radix16 =
    """
    8f9ef398c97defd735dfa6eb05f0aab2afbf84ea79a8e30b10dd6a305f7e1fc1243dc22f19bb1fc48602a8019d5\
    889719e4de855351eb6fc5db53c44cfc9ad3d56120ebd8e9ac5cfcac1f438a9c62189b0e1987b27344ac0a871b0\
    bafacb4b900597d9408ffe7329be5cf061ccc22723714a2c5576bdb663c32b7e9a9a51f799a6dfd461f7f5805ae\
    1b9e79950d5552be34cd47ad1b4abd6a731f34825654ad34f676d84533464c50503d7643ffe6a616f055754e580\
    b59be37a89987abde817d5ecc43903a676a7259ca793dc1975dab19b63d0855003af4981fbd726b009309cceb9e\
    70bd68b548a0f17b78d27da4f1d829ca1adafe45e65a720e2ff815382c9fcbd81342636f6cd97e790ebbaa766f5\
    122cf6c1585707c09ca491f07603c33c95a4fce736bf54255f16b085aa2ef59cd9883929a14c35be1c7f54547db\
    d2ff9b17bf93175b3950bdf82b97bc3d6ffceb5b3466231ce4c655db08ea6d0ac135113d0253b49f1d15dcf5ffe\
    372a3edc3ea1a747d78baa21c6163be4580e989c93731057959e3c803a1d292aab93f30419d63f5667be6146889\
    f9532c580769e1a06eb145800000000000000000000000000000000000000000000000000000000000000000000\
    00000000000000000000000000000000000000000000000000000000000
    """

  // MARK: - Basic arithmetic

  func testDivision() {
    // Signed division test
    let numa = BigInt("-18446744073709551616")!
    let dena = BigInt(123)
    let expecteda = BigInt(Int64(-149973529054549200))
    XCTAssertEqual(numa / dena, expecteda)
    
    let numb = BigInt("18446744073709551616")!
    let denb = BigInt(-123)
    XCTAssertEqual(numb / denb, expecteda)
    let expectedb = BigInt(Int64(149973529054549200))
    XCTAssertEqual(numa / denb, expectedb)
    
    // Previous test cases
    let num1 = BigInt("18446744073709551616")!
    let den1 = BigInt(123)
    let expected1 = BigInt(UInt64(149973529054549200))
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
    
    for _ in 0 ..< 100 {
      let expected = BigInt(Float64.random(in: 0x1p64 ... 0x1p255))
      let divisor  = BigInt(Float64.random(in: 0x1p64 ... 0x1p128))
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
    
  func testStringToBigIntImprovements() {
    var expectedNumber: BigInt!
    
    measure {
      expectedNumber = BigInt(Self.descriptionFactorial512_radix36, radix: 36)
    }
    
    XCTAssertEqual(expectedNumber, BigInt(Self.descriptionFactorial512_radix10, radix: 10))
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
    XCTAssertEqual(barz, BigInt(UInt64.max) + 1)
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
  
  func testTrailingZeroCount() {
    let foo = BigInt(1) << 300
    XCTAssertEqual(foo.trailingZeroBitCount, 300)
    
    let bar = (BigInt(1) << 300) + 0b101000
    XCTAssertEqual(bar.trailingZeroBitCount, 3)
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
  
  func testsFromViolet() {
    // -9223372036854775808 = Int64.min, obviously '-Int64.min' overflows
    let int: Int64 = -9223372036854775808
    var big = BigInt(int)
    XCTAssertEqual(-big, big * -1)
    
    // 9223372036854775808 = UInt64(1) << Float80.significandBitCount
    var int2 : UInt64 = 9223372036854775808
    big = BigInt(int2)
    let fromInt = Float80(exactly: int2) // works
    let fromBigInt = Float80(exactly: big) // crash (not anymore)
    
    // 18446744073709551615 = UInt64.max - was crashing
    int2 = 18446744073709551615
    big = BigInt(int2)
    let revert = UInt64(big)
  }
  
  func test_initFromInt_exactly() {
    let int: UInt64 = 18446744073709551614
    let big = BigInt(exactly: int)!
    let revert = UInt64(exactly: big)
    XCTAssertEqual(int, revert)
  }

  func test_initFromInt_clamping() {
    let int: UInt64 = 18446744073709551614
    let big = BigInt(clamping: int)
    let revert = UInt64(clamping: big)
    XCTAssertEqual(int, revert)
  }

  func test_initFromInt_truncatingIfNeeded() {
    let int: UInt64 = 18446744073709551615
    let big = BigInt(truncatingIfNeeded: int)
    let intString = String(int, radix: 10, uppercase: false)
    let bigString = String(big, radix: 10, uppercase: false)
    XCTAssertEqual(bigString, intString)
  }
  
  func test_node_div_incorrectSign() {
    // positive / negative = negative
    var lhs = BigInt("18446744073709551615")!
    var rhs = BigInt("-1")!
    var expected = BigInt("-18446744073709551615")!
    XCTAssertEqual(lhs / rhs, expected)

    // negative / positive = negative
    lhs = BigInt("-340282366920938463481821351505477763074")!
    rhs = BigInt("18446744073709551629")!
    expected = BigInt("-18446744073709551604")!
    XCTAssertEqual(lhs / rhs, expected)
  }

  func test_node_mod_incorrectSign() {
    // SMALL % BIG = SMALL
    // We need to satisfy: BIG * 0 + result = SMALL -> result = SMALL
    // The same, but on the standard Swift.Int to prove the point:
    XCTAssertEqual(-1 % 123, -1)
    XCTAssertEqual(-1 % -123, -1)
    // In general the 'reminder' follows the 'lhs' sign (round toward 0).
    // Except for the case where 'lhs' is negative and 'reminder' is 0.

    var lhs = BigInt("-1")!
    var rhs = BigInt("18446744073709551615")!
    XCTAssertEqual(lhs % rhs, lhs)

    // Also fails if 'rhs' is negative
    lhs = BigInt("-7730941133")!
    rhs = BigInt("-18446744073709551615")!
    XCTAssertEqual(lhs % rhs, lhs)
  }

  // From my observations all of the `xor` tests are failing.
  func test_node_xor() {
    var lhs = BigInt("0")!
    var rhs = BigInt("1")!
    var expected = BigInt("1")!
    XCTAssertEqual(lhs ^ rhs, expected)
    XCTAssertEqual(0 ^ 1, 1) // Proof

    lhs = BigInt("0")!
    rhs = BigInt("-1")!
    expected = BigInt("-1")!
    XCTAssertEqual(lhs ^ rhs, expected)
    XCTAssertEqual(0 ^ -1, -1) // Proof
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
    XCTAssertEqual(BigInt(clamping: UInt64.max), BigInt(UInt64(18446744073709551615)))
  }

  func testUIntConversion() {
    let foo = BigInt(UInt.max)
    XCTAssertNotEqual(foo, BigInt(-1))

    let bar = BigInt(bitPattern: UInt.max)
    XCTAssertEqual(bar, BigInt(-1))
  }
  
  // MARK: - Testing logical functions
  
  func testLogical() {
    let a = BigInt("7FFF555512340000", radix: 16)!
    let b = BigInt("0000ABCD9876FFFF", radix: 16)!
    
    let aAndb = String(a & b, radix: 16)
    let aOrb  = String(a | b, radix: 16)
    let aXorb = String(a ^ b, radix: 16)
    let notb  = String(~b, radix: 16)
    
    let shiftLeft1  = String(a << 16, radix:16)
    let shiftLeft2  = String(a << -3, radix:16)
    let shiftRight1 = String(a >> 1000, radix:16)
    let shiftRight2 = String(a >> -7, radix:16)
    
    print("a & b = 0x\(aAndb)"); XCTAssertEqual(aAndb, "14510340000")
    print("a | b = 0x\(aOrb)");  XCTAssertEqual(aOrb,  "7fffffdd9a76ffff")
    print("a ^ b = 0x\(aXorb)"); XCTAssertEqual(aXorb, "7ffffe988a42ffff")
    print("~b    = 0x\(notb)");  XCTAssertEqual(notb, "-abcd98770000")
    
    print("a << 16   = \(shiftLeft1)");  XCTAssertEqual(shiftLeft1,  "7fff5555123400000000")
    print("a << -3   = \(shiftLeft2)");  XCTAssertEqual(shiftLeft2,  "fffeaaaa2468000")
    print("a >> 1000 = \(shiftRight1)"); XCTAssertEqual(shiftRight1, "0")
    print("a >> -7   = \(shiftRight2)"); XCTAssertEqual(shiftRight2, "3fffaaaa891a000000")
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

  func testBinaryFloatingPoint<T>(_ type: T.Type) where T: BinaryFloatingPoint {
    var expected = BigInt(T.greatestFiniteMagnitude.significandBitPattern)
    expected |= BigInt(1) << T.significandBitCount
    expected <<= T.greatestFiniteMagnitude.exponent
    expected >>= T.significandBitCount

    XCTAssertEqual(BigInt(exactly: -T.greatestFiniteMagnitude), -expected)
    XCTAssertEqual(BigInt(exactly: +T.greatestFiniteMagnitude), +expected)
    XCTAssertEqual(BigInt(-T.greatestFiniteMagnitude), -expected)
    XCTAssertEqual(BigInt(+T.greatestFiniteMagnitude), +expected)

    XCTAssertNil(BigInt(exactly: -T.infinity))
    XCTAssertNil(BigInt(exactly: +T.infinity))

    XCTAssertNil(BigInt(exactly: -T.leastNonzeroMagnitude))
    XCTAssertNil(BigInt(exactly: +T.leastNonzeroMagnitude))
    XCTAssertEqual(BigInt(-T.leastNonzeroMagnitude), 0)
    XCTAssertEqual(BigInt(+T.leastNonzeroMagnitude), 0)

    XCTAssertNil(BigInt(exactly: -T.leastNormalMagnitude))
    XCTAssertNil(BigInt(exactly: +T.leastNormalMagnitude))
    XCTAssertEqual(BigInt(-T.leastNormalMagnitude), 0)
    XCTAssertEqual(BigInt(+T.leastNormalMagnitude), 0)

    XCTAssertNil(BigInt(exactly: T.nan))
    XCTAssertNil(BigInt(exactly: T.signalingNaN))

    XCTAssertNil(BigInt(exactly: -T.pi))
    XCTAssertNil(BigInt(exactly: +T.pi))
    XCTAssertEqual(BigInt(-T.pi), -3)
    XCTAssertEqual(BigInt(+T.pi), +3)

    XCTAssertNil(BigInt(exactly: -T.ulpOfOne))
    XCTAssertNil(BigInt(exactly: +T.ulpOfOne))
    XCTAssertEqual(BigInt(-T.ulpOfOne), 0)
    XCTAssertEqual(BigInt(+T.ulpOfOne), 0)

    XCTAssertEqual(BigInt(exactly: -T.zero), 0)
    XCTAssertEqual(BigInt(exactly: +T.zero), 0)
    XCTAssertEqual(BigInt(-T.zero), 0)
    XCTAssertEqual(BigInt(+T.zero), 0)
  }

  func testBinaryFloatingPoint() {
    testBinaryFloatingPoint(Float32.self)
    testBinaryFloatingPoint(Float64.self)
    #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    testBinaryFloatingPoint(Float80.self)
    #endif

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

    #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    for _ in 0 ..< 100 {
      let small = Float80.random(in: -10 ... +10)
      XCTAssertEqual(BigInt(small), BigInt(Int64(small)))

      let large = Float80.random(in: -0x1p63 ..< +0x1p63)
      XCTAssertEqual(BigInt(large), BigInt(Int64(large)))
    }
    #endif
  }
}
