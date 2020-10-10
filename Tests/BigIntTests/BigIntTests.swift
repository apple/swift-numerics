//===--- BigIntTests.swift ------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import BigIntModule

internal func _randomWords(count: Int) -> (BigInt, AttaswiftBigInt) {
  var words: [UInt] = (0..<Int.random(in: 1...count)).map { _ in
    UInt.random(in: 0..<UInt.max)
  }
  words.append(0)
  var temporary
    = BigInt(_combination: 1, significand: BigInt._Significand(words))
  temporary._normalize()
  return (temporary, AttaswiftBigInt(words: words))
}

final class BigIntModuleTests: XCTestCase {
  func testLayout() {
#if false
    XCTAssertEqual(MemoryLayout<BigInt>.size, MemoryLayout<Int>.size * 3)
    XCTAssertEqual(MemoryLayout<BigInt>.stride, MemoryLayout<Int>.size * 3)
#endif
  }
  
  func testSignificand() {
    let x = BigInt._Significand([1, 2, 3])
    XCTAssertEqual(x[0], 1)
    XCTAssertEqual(x[1], 2)
    XCTAssertEqual(x[2], 3)
  }
  
  func testWords() {
    let i = BigInt(_combination: 1, significand:
      BigInt._Significand(10284089032038000429, [1319478378503944518]))
    XCTAssertEqual(i.words.count, 2)
    XCTAssertEqual(i.words[0], 10284089032038000429)
    XCTAssertEqual(i.words[1], 1319478378503944518)
  }
  
  func testConversion() {
    for i in (-42..<42) {
      let x = BigInt(i)
      XCTAssertEqual(x._combination, i.signum())
      XCTAssertEqual(x._significand[0], i.magnitude)
      XCTAssertEqual(x.description, i.description)
      let j = Int(x)
      XCTAssertEqual(i, j)
    }
    for _ in 0..<10 {
      let x = _randomWords(count: 8)
      XCTAssertEqual(x.0.description, x.1.description)
      XCTAssertEqual(x.0, BigInt(words: x.1.words))
      
      for i in 2...36 {
        let strings = (String(x.0, radix: i), String(x.1, radix: i))
        let x = BigInt(strings.0, radix: i)!
        let y = AttaswiftBigInt(strings.1, radix: i)!
        XCTAssertEqual(x, BigInt(y), "\(i)")
      }
    }
    for _ in 0..<100 {
      let x = UInt64.random(in: 0...UInt64.max)
      let y = Double(bitPattern: x)
      var temporary = (BigInt(exactly: y), AttaswiftBigInt(exactly: y))
      if temporary.0 == nil {
        XCTAssertNil(temporary.1)
      } else {
        XCTAssertNotNil(temporary.1)
        XCTAssertEqual(temporary.0!, BigInt(temporary.1!))
      }
      if y.isFinite {
        XCTAssertEqual(BigInt(y), BigInt(AttaswiftBigInt(y)))
      }
      
      let z = UInt32.random(in: 0...UInt32.max)
      let w = Float(bitPattern: z)
      temporary = (BigInt(exactly: w), AttaswiftBigInt(exactly: w))
      if temporary.0 == nil {
        XCTAssertNil(temporary.1)
      } else {
        XCTAssertNotNil(temporary.1)
        XCTAssertEqual(temporary.0!, BigInt(temporary.1!))
      }
      if w.isFinite {
        XCTAssertEqual(BigInt(w), BigInt(AttaswiftBigInt(w)))
      }
    }
  }
  
  func testAddition() {
    for _ in 0..<100 {
      let a = _randomWords(count: 8)
      let b = _randomWords(count: 8)
      XCTAssertEqual(a.0 + 0, a.0)
      XCTAssertEqual(0 + a.0, a.0)
      XCTAssertEqual(b.0 + 0, b.0)
      XCTAssertEqual(0 + b.0, b.0)
      XCTAssertEqual(a.0 - 0, a.0)
      XCTAssertEqual(0 - a.0, -a.0)
      XCTAssertEqual(b.0 - 0, b.0)
      XCTAssertEqual(0 - b.0, -b.0)
      
      var results = (a.0 + b.0, a.1 + b.1)
      let words = (results.0.words, results.1.words)
      for (left, right) in zip(words.0, words.1) {
        XCTAssertEqual(left, right, "Expected \(a.1) + \(b.1) == \(results.1)")
      }
      results = (a.0 + -b.0, a.1 - b.1)
      XCTAssertEqual(results.0, BigInt(results.1))
      results = (-a.0 + b.0, b.1 - a.1)
      XCTAssertEqual(results.0, BigInt(results.1))
      results = (-a.0 - b.0, -(a.1 + b.1))
      XCTAssertEqual(results.0, BigInt(results.1))
      
      results = (a.0 - -b.0, a.1 + b.1)
      XCTAssertEqual(results.0, BigInt(results.1))
      results = (a.0 - b.0, a.1 - b.1)
      XCTAssertEqual(results.0, BigInt(results.1))
      results = (-a.0 - -b.0, b.1 - a.1)
      XCTAssertEqual(results.0, BigInt(results.1))
      results = (-a.0 - b.0, -(a.1 + b.1))
      XCTAssertEqual(results.0, BigInt(results.1))
    }
  }
  
  func testMultiplication() {
    let x = (184467440737095516 as BigInt) * 100
    XCTAssertEqual(x.description, "18446744073709551600")
    for _ in 0..<100 {
      let a = _randomWords(count: 8)
      let b = _randomWords(count: 8)
      
      XCTAssertEqual(a.0 * 0, 0)
      XCTAssertEqual(a.0 * 1, a.0)
      XCTAssertEqual(0 * a.0, 0)
      XCTAssertEqual(1 * a.0, a.0)
      
      var results = (a.0 * b.0, a.1 * b.1)
      let words = (results.0.words, results.1.words)
      for (left, right) in zip(words.0, words.1) {
        XCTAssertEqual(left, right, "Expected \(a.1) * \(b.1) == \(results.1)")
      }
      results = (a.0 * -b.0, a.1 * -b.1)
      XCTAssertEqual(results.0, BigInt(results.1))
      results = (-a.0 * b.0, a.1 * -b.1)
      XCTAssertEqual(results.0, BigInt(results.1))
      results = (-a.0 * -b.0, a.1 * b.1)
      XCTAssertEqual(results.0, BigInt(results.1))
    }
    for _ in 0..<10 {
      let a = _randomWords(count: 64)
      let b = _randomWords(count: 64)
      let products = (a.0 * b.0, a.1 * b.1)
      let words = (products.0.words, products.1.words)
      for (left, right) in zip(words.0, words.1) {
        XCTAssertEqual(left, right, "Expected \(a.1) * \(b.1) == \(products.1)")
      }
    }
  }
  
  func testDivision() {
    let x = BigInt("327441402998268901582239630362983195839")!
    let y = BigInt("279240677930711642307518656231691197860")!
    XCTAssertEqual(x / y, 1)

    let z = BigInt("3182990411991163758463334586237477812181413821081264903177942613807541528844305823312360947978873366530408681494780")!
    let w = BigInt("16012987498029214696648267754993196043335730812460137832692217701508007910953126091749743662257786118530085930814191")!
    XCTAssertEqual(z * w / z, w)

    for _ in 0..<50 {
      let a = _randomWords(count: 6)
      let b = _randomWords(count: 4)
      
      XCTAssertEqual(a.0 / b.0, BigInt(a.1 / b.1))
      XCTAssertEqual(a.0 % b.0, BigInt(a.1 % b.1))
      XCTAssertEqual(
        (a.0 << 128) / (b.0 << 42),
        BigInt((a.1 << 128) / (b.1 << 42)))
      XCTAssertEqual(
        (a.0 << 128) % (b.0 << 42),
        BigInt((a.1 << 128) % (b.1 << 42)))
      XCTAssertEqual(
        (a.0 << 42) / (b.0 << 128),
        BigInt((a.1 << 42) / (b.1 << 128)))
      XCTAssertEqual(
        (a.0 << 42) % (b.0 << 128),
        BigInt((a.1 << 42) % (b.1 << 128)))
      XCTAssertEqual((a.0 << 128) / (b.0 << 128), a.0 / b.0)
    }
  }
  
  func testBitwiseOperators() {
    for _ in 0..<100 {
      let a = _randomWords(count: 8)
      let b = _randomWords(count: 8)
      
      XCTAssertEqual(a.0 & 0, 0)
      XCTAssertEqual(0 & a.0, 0)
      XCTAssertEqual(-a.0 & 0, 0)
      XCTAssertEqual(0 & -a.0, 0)
      
      XCTAssertEqual(a.0 | 0, a.0)
      XCTAssertEqual(0 | a.0, a.0)
      XCTAssertEqual(-a.0 | 0, -a.0)
      XCTAssertEqual(0 | -a.0, -a.0)
      
      XCTAssertEqual(a.0 ^ 0, a.0)
      XCTAssertEqual(0 ^ a.0, a.0)
      XCTAssertEqual(-a.0 ^ 0, -a.0)
      XCTAssertEqual(0 ^ -a.0, -a.0)
      
      var results = (a.0 & b.0, a.1 & b.1)
      XCTAssertEqual(results.0, BigInt(results.1))
      results = (a.0 & -b.0, a.1 & -b.1)
      XCTAssertEqual(results.0, BigInt(results.1))
      results = (-a.0 & b.0, -a.1 & b.1)
      XCTAssertEqual(results.0, BigInt(results.1))
      results = (-a.0 & -b.0, -a.1 & -b.1)
      XCTAssertEqual(results.0, BigInt(results.1))
      
      results = (a.0 | b.0, a.1 | b.1)
      XCTAssertEqual(results.0, BigInt(results.1))
      results = (a.0 | -b.0, a.1 | -b.1)
      XCTAssertEqual(results.0, BigInt(results.1))
      results = (-a.0 | b.0, -a.1 | b.1)
      XCTAssertEqual(results.0, BigInt(results.1))
      results = (-a.0 | -b.0, -a.1 | -b.1)
      XCTAssertEqual(results.0, BigInt(results.1))
      
      results = (a.0 ^ b.0, a.1 ^ b.1)
      XCTAssertEqual(results.0, BigInt(results.1))
      results = (a.0 ^ -b.0, a.1 ^ -b.1)
      XCTAssertEqual(results.0, BigInt(results.1))
      results = (-a.0 ^ b.0, -a.1 ^ b.1)
      XCTAssertEqual(results.0, BigInt(results.1))
      results = (-a.0 ^ -b.0, -a.1 ^ -b.1)
      XCTAssertEqual(results.0, BigInt(results.1))
    }
    
    let a = _randomWords(count: 4)
    XCTAssertEqual((a.0 << 255 + 1) >> 255, a.0)
    
    for i in (-100..<100) {
      XCTAssertEqual(a.0 << i, BigInt(a.1 << i))
      XCTAssertEqual(a.0 >> i, BigInt(a.1 >> i))
      //FIXME: There appears to be a bug in attaswift/BigInt (see below).
      // XCTAssertEqual(-a.0 << i, BigInt(-a.1 << i))
      // XCTAssertEqual(-a.0 >> i, BigInt(-a.1 >> i))
      
      XCTAssertEqual(a.0 >> ((a.0).bitWidth &- 1), 0)
      XCTAssertEqual(-a.0 >> ((-a.0).bitWidth &- 1), -1)
    }
    
    let b = BigInt(
      "-1011011100111000101101000110100010111110000110001001111011011",
      radix: 2)!
    XCTAssertEqual(b << -51, b >> 51)
    XCTAssertEqual(b << -51, BigInt("-1011011101", radix: 2)!)
    //FIXME: This is a concrete example where attaswift/BigInt is incorrect.
    // XCTAssertEqual(AttaswiftBigInt(b) << -51, AttaswiftBigInt(b << -51))
    
    for i in (-100..<100) {
      XCTAssertEqual(~BigInt(i), BigInt(~i))
    }
  }
  
  func testTrailingZeroBitCount() {
    for _ in 0..<100 {
      let a = _randomWords(count: 8)
      XCTAssertEqual(a.0.trailingZeroBitCount, a.1.trailingZeroBitCount)
      XCTAssertEqual((-a.0).trailingZeroBitCount, (-a.1).trailingZeroBitCount)
      
      XCTAssertEqual(
        (a.0 << 12345).trailingZeroBitCount,
        (a.1 << 12345).trailingZeroBitCount)
      XCTAssertEqual(
        (-a.0 << 12345).trailingZeroBitCount,
        (-a.1 << 12345).trailingZeroBitCount)
    }
  }
  
  func testModularOperations() {
    XCTAssertEqual(0.inverse(modulo: 1), 0)
    XCTAssertEqual(3.inverse(modulo: 7), 5)
    
    for _ in 0..<100 {
      let a = _randomWords(count: 1)
      let b = _randomWords(count: 1)
      if b.0 == 0 { continue }
      
      XCTAssertEqual(
        a.0.inverse(modulo: b.0),
        a.1.inverse(b.1).map { BigInt($0) })
      XCTAssertEqual(
        (-(a.0)).inverse(modulo: b.0),
        (-(a.1)).inverse(b.1).map { BigInt($0) })
    }
    
    XCTAssertEqual(Int.pow(0, -1, modulo: 1), 0.inverse(modulo: 1))
    XCTAssertEqual(Int.pow(3, -1, modulo: 5), 3.inverse(modulo: 5))
    
    for _ in 0..<20 {
      let a = _randomWords(count: 2)
      let b = _randomWords(count: 2)
      let c = _randomWords(count: 1)
      if c.0 == 0 { continue }
      
      XCTAssertEqual(
        BigInt.pow(a.0, b.0, modulo: c.0)!,
        BigInt(a.1.power(b.1, modulus: c.1)))
    }
  }
  
  func testRandom() {
    let x = BigInt.random(in: 0...BigInt("98765432109876543210")!)
    XCTAssertLessThanOrEqual(x, BigInt("98765432109876543210")!)
  }

  func testPerformancePiDigits() {
    var acc = 0 as BigInt, num = 1 as BigInt, den = 1 as BigInt

    func extractDigit(_ n: UInt) -> UInt {
      var tmp = num * BigInt(n)
      tmp += acc
      tmp /= den
      return tmp.words[0]
    }
    
    func eliminateDigit(_ d: UInt) {
      acc -= den * BigInt(d)
      acc *= 10
      num *= 10
    }
    
    func nextTerm(_ k: UInt) {
      let k2 = BigInt(k * 2 + 1)
      acc += num * 2
      acc *= k2
      den *= k2
      num *= BigInt(k)
    }
    
    func piDigits(_ n: Int) {
      acc = 0
      den = 1
      num = 1
      
      var i = 0
      var k = 0 as UInt
      var string = ""
      while i < n {
        k += 1
        nextTerm(k)
        if num > acc { continue }
        let d = extractDigit(3)
        if d != extractDigit(4) { continue }
        string.append("\(d)")
        i += 1
        if i.isMultiple(of: 10) {
          print("\(string)\t:\(i)")
          string = ""
        }
        eliminateDigit(d)
      }
    }
    measure {
      piDigits(100)
    }
  }
}
