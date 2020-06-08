import XCTest
@testable import BigIntModule

internal func _randomWords(count: Int) -> (BigInt, AttaswiftBigInt) {
  var words: [UInt] = (0..<Int.random(in: 1..<count)).map { _ in
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
    XCTAssertEqual(MemoryLayout<BigInt>.size, MemoryLayout<Int>.size * 3)
    XCTAssertEqual(MemoryLayout<BigInt>.stride, MemoryLayout<Int>.size * 3)
  }
  
  func testSignificand() {
    let x = BigInt._Significand([1, 2, 3])
    XCTAssertEqual(x._low, 1)
    XCTAssertEqual(x._rest[0], 2)
    XCTAssertEqual(x._rest[1], 3)
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
      XCTAssertEqual(x._significand._low, i.magnitude)
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
}
