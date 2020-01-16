//===--- BigInt.swift -----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

public struct BigInt: SignedInteger {

  public typealias Words = [UInt]

  public private(set) var words: Words

  @usableFromInline
  internal init(_uncheckedWords: Words) {
    self.words = _uncheckedWords
  }

  public init<T>(bitPattern source: T) where T: BinaryInteger {
    words = Words(source.words)
    BigInt._dropExcessWords(words: &words)
  }

  @usableFromInline
  internal var _isNegative: Bool {
    words[words.endIndex - 1] > Int.max
  }

  private static let _digits: [BigInt] = (0 ... 36).map {
    BigInt(_uncheckedWords: [UInt(bitPattern: $0)])
  }
}

// MARK: - Basic Behaviors

extension BigInt: Equatable {

  @inlinable
  public static func == (lhs: BigInt, rhs: BigInt) -> Bool {
    lhs.words == rhs.words
  }

  @inlinable
  public static func != (lhs: BigInt, rhs: BigInt) -> Bool {
    !(lhs == rhs)
  }
}

extension BigInt: Hashable {

  @inlinable
  public func hash(into hasher: inout Hasher) {
    hasher.combine(words)
  }
}

extension BigInt: Comparable {

  @inlinable
  public static func < (lhs: BigInt, rhs: BigInt) -> Bool {
    let lhsNegative = lhs._isNegative
    let rhsNegative = rhs._isNegative

    if lhsNegative && !rhsNegative { return true }
    if rhsNegative && !lhsNegative { return false }

    if (lhsNegative && rhsNegative) || (!lhsNegative && !rhsNegative) {
      if lhs.words.count > rhs.words.count {
        return lhsNegative ? true : false
      }
      if lhs.words.count < rhs.words.count {
        return lhsNegative ? false : true
      }

      for i in stride(from: lhs.words.count - 1, through: 0, by: -1) {
        if lhs.words[i] > rhs.words[i] {
          return false
        } else if lhs.words[i] < rhs.words[i] {
          return true
        }
      }
    }

    return false
  }
}

extension BigInt: CustomStringConvertible {

  public var description: String {
    var result = ""

    if words.count == 1 {
      return Int64(bitPattern: UInt64(words[0])).description
    } else {
      var next = abs(self)
      while next != 0 {
        let digit: BigInt
        (next, digit) = BigInt._div(lhs: next, rhs: 10)
        result += "\(digit.words[0])"
      }
    }

    return (self < 0 ? "-" : "") + String(result.reversed())
  }
}

extension BigInt: LosslessStringConvertible {

  public init?(_ description: String) {
    self.init(description, radix: 10)
  }

  public init?<T>(_ description: T, radix: Int = 10) where T: StringProtocol {
    precondition(2 ... 36 ~= radix, "Radix not in range 2 ... 36")

    self = 0

    let isNegative = description.hasPrefix("-")
    let hasPrefix = isNegative || description.hasPrefix("+")
    let utf8 = description.utf8.dropFirst(hasPrefix ? 1 : 0)
    guard !utf8.isEmpty else { return nil }

    for var byte in utf8 {
      switch byte {
      case UInt8(ascii: "0") ... UInt8(ascii: "9"):
        byte -= UInt8(ascii: "0")
      case UInt8(ascii: "A") ... UInt8(ascii: "Z"):
        byte -= UInt8(ascii: "A")
        byte += 10
      case UInt8(ascii: "a") ... UInt8(ascii: "z"):
        byte -= UInt8(ascii: "a")
        byte += 10
      default:
        return nil
      }
      guard byte < radix else { return nil }
      self *= BigInt._digits[radix]
      self += BigInt._digits[Int(byte)]
    }

    if isNegative {
      self.negate()
    }
  }
}

extension BigInt: Decodable {

  public init(from decoder: Decoder) throws {
    let singleValueContainer = try decoder.singleValueContainer()
    let description = try singleValueContainer.decode(String.self)
    guard let result = BigInt(description) else {
      throw DecodingError.dataCorruptedError(
        in: singleValueContainer,
        debugDescription: "BigInt(\(description.debugDescription)) failed")
    }
    self = result
  }
}

extension BigInt: Encodable {

  public func encode(to encoder: Encoder) throws {
    var singleValueContainer = encoder.singleValueContainer()
    try singleValueContainer.encode(description)
  }
}

// MARK: - Numeric Protocols

extension BigInt: ExpressibleByIntegerLiteral {

  public init(integerLiteral value: Int) {
    if value >= 0, value < BigInt._digits.count {
      self = BigInt._digits[value]
    } else {
      words = [UInt(bitPattern: value)]
    }
  }
}

extension BigInt: AdditiveArithmetic {

  @inlinable
  public static func + (lhs: BigInt, rhs: BigInt) -> BigInt {
    var result = lhs
    result += rhs
    return result
  }

  public static func += (lhs: inout BigInt, rhs: BigInt) {
    if lhs.words.count == 1, rhs.words.count == 1 {
      let lhsWord = lhs.words[0]
      let rhsWord = rhs.words[0]

      let (result, isOverflow) = lhsWord.addingReportingOverflow(rhsWord)

      if !isOverflow && result < Int.max {
        lhs.words[0] = result
        return
      }
      let knownNegativeResult = lhsWord > Int.max && rhsWord > Int.max

      if lhsWord > Int.max || rhsWord > Int.max, !knownNegativeResult {
        // positive + negative is always smaller, so overflow is a red herring
        lhs.words[0] = result
        return
      }
    }

    var isOverflow = false

    var rhsWords = rhs.words

    lhs.words.append(lhs._isNegative ? UInt.max : 0)
    rhsWords.append(rhs._isNegative ? UInt.max : 0)

    BigInt._signExtend(lhsWords: &lhs.words, rhsWords: &rhsWords)
    var temp: UInt = 0
    for index in 0 ..< lhs.words.count {
      var carryOverflow = false

      if isOverflow {
        (temp, carryOverflow) = rhsWords[index].addingReportingOverflow(1)
      } else {
        temp = rhsWords[index]
      }

      (lhs.words[index], isOverflow) = lhs.words[index].addingReportingOverflow(temp)

      isOverflow = carryOverflow || isOverflow
    }

    BigInt._dropExcessWords(words: &lhs.words)
  }

  @inlinable
  public static func - (lhs: BigInt, rhs: BigInt) -> BigInt {
    var result = lhs
    result -= rhs
    return result
  }

  @inlinable
  public static func -= (lhs: inout BigInt, rhs: BigInt) {
    lhs += -rhs
  }
}

extension BigInt: Numeric {

  public init?<T>(exactly source: T) where T: BinaryInteger {
    self.init(source)
  }

  public var magnitude: BigInt { _isNegative ? -self : self }

  public static func * (lhs: BigInt, rhs: BigInt) -> BigInt {
    let lhsIsNeg = lhs.words[lhs.words.endIndex - 1] > Int.max
    let rhsIsNeg = rhs.words[rhs.words.endIndex - 1] > Int.max

    let lhsWords = lhsIsNeg ? (-lhs).words : lhs.words
    let rhsWords = rhsIsNeg ? (-rhs).words : rhs.words

    let count = lhsWords.count + rhsWords.count + 1
    var newWords = Words(repeating: 0, count: count)

    for i in 0 ..< rhsWords.count {
      var carry: UInt = 0
      var digit: UInt = 0

      var lastJ: Int = 0
      for j in i ..< (lhsWords.count + i) {
        var (high, low) = rhsWords[i].multipliedFullWidth(by: lhsWords[j - i])
        var isOverflow: Bool
        (digit, isOverflow) = low.addingReportingOverflow(newWords[j])
        if isOverflow {
          high += 1
        }

        (digit, isOverflow) = digit.addingReportingOverflow(carry)
        if isOverflow {
          high += 1
        }

        carry = high
        newWords[j] = digit
        lastJ = j
      }

      if carry != 0 {
        let isOverflow: Bool
        (digit, isOverflow) = newWords[lastJ + 1].addingReportingOverflow(carry)
        if isOverflow {
          carry = 1
        }
        newWords[lastJ + 1] = digit
      }
    }

    for i in stride(from: count - 1, through: 1, by: -1) {
      if newWords[i] == 0, newWords[i - 1] <= Int.max {
        newWords.removeLast()
      } else {
        break
      }
    }

    if lhsIsNeg || rhsIsNeg, !(lhsIsNeg && rhsIsNeg) {
      return -BigInt(_uncheckedWords: newWords)
    }

    return BigInt(_uncheckedWords: newWords)
  }

  @inlinable
  public static func *= (lhs: inout BigInt, rhs: BigInt) {
    lhs = lhs * rhs
  }
}

extension BigInt: SignedNumeric {

  public mutating func negate() {
    var isOverflow = true
    for i in 0 ..< words.count {
      if isOverflow {
        (words[i], isOverflow) = (~words[i]).addingReportingOverflow(1)
      } else {
        words[i] = ~words[i]
      }
    }
    
    BigInt._dropExcessWords(words: &words)
  }

  @inlinable
  public static prefix func - (x: BigInt) -> BigInt {
    var result = x
    result.negate()
    return result
  }
}

extension BigInt: BinaryInteger {

  public init?<T>(exactly source: T) where T: BinaryFloatingPoint {
    if (source.isNaN || source.isInfinite) ||
      (source.rounded(.towardZero) != source) {
      return nil
    }

    self.init(source)
  }

  public init<T>(_ source: T) where T: BinaryFloatingPoint {
    precondition(
      !(source.isNaN || source.isInfinite),
      "\(type(of: source)) value cannot be converted to BigInt because it is either infinite or NaN"
    )

    let isNegative = source < 0.0
    var float = isNegative ? -source : source

    if let _ = UInt(exactly: T.greatestFiniteMagnitude) {
      words = [UInt(float)]
    } else {
      var words = Words()
      let radix = T(sign: .plus, exponent: T.Exponent(UInt.bitWidth), significand: 1)
      repeat {
        let digit = UInt(float.truncatingRemainder(dividingBy: radix))
        words.append(digit)
        float = (float / radix).rounded(.towardZero)
      } while float != 0

      self.words = words
    }

    if isNegative {
      self = -self
    }
  }

  public init<T>(_ source: T) where T: BinaryInteger {
    if source >= 0, source < BigInt._digits.count {
      self = BigInt._digits[Int(source)]
    } else {
      words = Words(source.words)
      if source > Int.max {
        words.append(0)
      }
    }
  }

  public init<T>(clamping source: T) where T: BinaryInteger {
    self.init(source)
  }

  public init<T>(truncatingIfNeeded source: T) where T: BinaryInteger {
    words = Words(source.words)
  }

  public var bitWidth: Int { words.count * UInt.bitWidth }

  public var trailingZeroBitCount: Int { words.first?.trailingZeroBitCount ?? 0 }

  @inlinable
  public static func / (lhs: BigInt, rhs: BigInt) -> BigInt {
    let (result, _) = _div(lhs: lhs, rhs: rhs)
    return result
  }

  @inlinable
  public static func /= (lhs: inout BigInt, rhs: BigInt) {
    lhs = lhs / rhs
  }

  @inlinable
  public static func % (lhs: BigInt, rhs: BigInt) -> BigInt {
    let (_, result) = _div(lhs: lhs, rhs: rhs)

    return result
  }

  @inlinable
  public static func %= (lhs: inout BigInt, rhs: BigInt) {
    lhs = lhs % rhs
  }

  @inlinable
  public static prefix func ~ (x: BigInt) -> BigInt {
    let newWords = x.words.map { ~$0 }
    return BigInt(_uncheckedWords: Words(newWords))
  }

  public static func &= (lhs: inout BigInt, rhs: BigInt) {
    var rhsWords = rhs.words
    BigInt._signExtend(lhsWords: &lhs.words, rhsWords: &rhsWords)

    for i in 0 ..< rhsWords.count {
      lhs.words[i] &= rhsWords[i]
    }

    BigInt._dropExcessWords(words: &lhs.words)
  }

  public static func |= (lhs: inout BigInt, rhs: BigInt) {
    var rhsWords = rhs.words
    BigInt._signExtend(lhsWords: &lhs.words, rhsWords: &rhsWords)

    for i in 0 ..< rhsWords.count {
      lhs.words[i] |= rhsWords[i]
    }

    BigInt._dropExcessWords(words: &lhs.words)
  }

  public static func ^= (lhs: inout BigInt, rhs: BigInt) {
    var rhsWords = rhs.words
    BigInt._signExtend(lhsWords: &lhs.words, rhsWords: &rhsWords)

    for i in 0 ..< rhsWords.count {
      lhs.words[i] &= rhsWords[i]
    }

    BigInt._dropExcessWords(words: &lhs.words)
  }

  public static func <<= <RHS>(lhs: inout BigInt, rhs: RHS) where RHS: BinaryInteger {
    if rhs.signum() < 0 {
      lhs >>= rhs.magnitude
      return
    }

    let wordLength = UInt.bitWidth
    let isNegative = lhs._isNegative

    let (fullWords, remainder) = rhs.quotientAndRemainder(dividingBy: RHS(wordLength))
    lhs.words = Words(repeating: 0, count: Int(fullWords)) + lhs.words + [isNegative ? UInt.max : 0]

    if remainder > 0 {
      var value: UInt = 0
      for i in 0 ..< lhs.words.count {
        let temp = lhs.words[i] >> (wordLength - Int(remainder))
        lhs.words[i] <<= Int(remainder)
        if i > 0 {
          lhs.words[i] &= UInt.max << Int(remainder)
          lhs.words[i] |= value
        }

        value = temp
      }

      if isNegative {
        lhs.words[lhs.words.count - 1] |= (UInt.max << Int(remainder))
      }
    }

    BigInt._dropExcessWords(words: &lhs.words)
  }

  public static func >>= <RHS>(lhs: inout BigInt, rhs: RHS) where RHS: BinaryInteger {
    if rhs.signum() < 0 {
      lhs <<= rhs.magnitude
      return
    }

    let wordLength = UInt.bitWidth
    let isNegative = lhs._isNegative

    let (fullWords, remainder) = rhs.quotientAndRemainder(dividingBy: RHS(wordLength))
    if fullWords < lhs.words.count {
      lhs.words.removeFirst(Int(fullWords))
    } else {
      lhs = isNegative ? -1 : 0
      return
    }

    if remainder > 0 {
      let mask = ~(UInt.max << remainder)
      var value: UInt = 0
      for i in stride(from: lhs.words.count - 1, through: 0, by: -1) {
        let temp = lhs.words[i] & mask
        lhs.words[i] >>= remainder
        lhs.words[i] |= (value << (UInt.bitWidth - Int(remainder)))
        value = temp
      }
    }

    if isNegative {
      lhs.words[lhs.words.count - 1] |= (UInt.max << (UInt.bitWidth - Int(remainder)))
    }

    BigInt._dropExcessWords(words: &lhs.words)
  }

  @inlinable
  public func quotientAndRemainder(dividingBy rhs: BigInt) -> (quotient: BigInt, remainder: BigInt) {
    return BigInt._div(lhs: self, rhs: rhs)
  }

  @inlinable
  public func signum() -> BigInt {
    if _isNegative {
      return -1
    } else if self == 0 {
      return 0
    }

    return 1
  }
}

// MARK: -

extension BigInt {

  /// See _The Art of Computer Programming_ volume 2 by Donald Knuth, Section 4.3.1: The Classical Algorithms
  private static func _findQhat(
    high: UInt,
    low: UInt.Magnitude,
    divisor: UInt,
    nextVdigit: UInt,
    nextUdigit: UInt
  ) -> UInt {
    var (qhat, rhat) = divisor.dividingFullWidth((high, low))

    if high >= divisor { // This means qhat >= b
      qhat = UInt.max
    }

    let (tempHigh, tempLow) = qhat.multipliedFullWidth(by: nextVdigit)
    var (rtempHigh, rtempLow) = rhat.multipliedFullWidth(by: UInt.max)
    var overflow = false
    (rtempLow, overflow) = rtempLow.addingReportingOverflow(1)
    if overflow {
      rtempHigh += 1
    }

    (rtempLow, overflow) = rtempLow.addingReportingOverflow(nextUdigit)
    if overflow {
      rtempHigh += 1
    }

    while true {
      if (tempHigh > rtempHigh) || ((tempHigh == rtempHigh) && (tempLow > rtempLow)) {
        qhat -= 1
        (rhat, overflow) = rhat.addingReportingOverflow(divisor)
        if !overflow {
          continue
        } else {
          break
        }
      } else {
        break
      }
    }

    return qhat
  }

  /// See _The Art of Computer Programming_ volume 2 by Donald Knuth, Section 4.3.1: The Classical Algorithms
  @usableFromInline
  internal static func _div(lhs: BigInt, rhs: BigInt) -> (quotient: BigInt, remainder: BigInt) {
    precondition(rhs != _digits[0], "Division by zero error!")

    if lhs.words.count == 1, rhs.words.count == 1 {
      let (quot, rem) = Int(bitPattern: lhs.words[0]).quotientAndRemainder(dividingBy: Int(bitPattern: rhs.words[0]))
      return (BigInt(_uncheckedWords: [UInt(bitPattern: quot)]), BigInt(_uncheckedWords: [UInt(bitPattern: rem)]))
    }

    let lhsIsNeg = lhs._isNegative
    let rhsIsNeg = rhs._isNegative

    var lhsWords = lhsIsNeg ? (-lhs).words : lhs.words
    var rhsWords = rhsIsNeg ? (-rhs).words : rhs.words

    while rhsWords[rhsWords.endIndex - 1] == 0, rhsWords.count > 2 {
      rhsWords.removeLast()
    }

    if rhsWords.count > lhsWords.count { return (0, lhs) }

    if rhsWords.count == 1 {
      rhsWords.append(0)
    }

    if lhsWords.count < rhsWords.count {
      for _ in 0 ..< (rhsWords.count - lhsWords.count) {
        lhsWords.append(0)
      }
    }

    let m = lhsWords.count
    let n = rhsWords.count

    let bitWidth = UInt(UInt.bitWidth)

    let s = UInt(rhsWords[n - 1].leadingZeroBitCount)
    let rn = UnsafeMutablePointer<UInt>.allocate(capacity: n)
    rn.initialize(repeating: 0, count: n)
    defer { rn.deallocate() }
    for i in (1 ... (n - 1)).reversed() {
      rn[i] = (rhsWords[i] << s) | (rhsWords[i - 1] >> (bitWidth - s))
    }
    rn[0] <<= s

    let ln = UnsafeMutablePointer<UInt>.allocate(capacity: m + n + 1)
    ln.initialize(repeating: 0, count: m + n + 1)
    defer { ln.deallocate() }
    ln[m] = lhsWords[m - 1] >> (bitWidth - s)
    for i in (1 ... (m - 1)).reversed() {
      ln[i] = (lhsWords[i] << s) | (lhsWords[i - 1] >> (bitWidth - s))
    }
    ln[0] <<= s

    let resultSize = m + 1
    var quot = Words(repeating: 0, count: resultSize)

    for j in (0 ... m).reversed() {
      let qhat = _findQhat(
        high: ln[j + n],
        low: UInt.Magnitude(ln[j + n - 1]),
        divisor: rn[n - 1],
        nextVdigit: rn[n - 2],
        nextUdigit: ln[j + n - 2])

      var carry: UInt = 0
      var isOverflow = false
      var borrow: UInt = 0
      var underflow = false
      for i in 0 ..< n {
        if borrow > 0 {
          (ln[i + j], underflow) = ln[i + j].subtractingReportingOverflow(borrow)
          borrow = underflow ? 1 : 0
        }

        var (pHigh, pLow) = qhat.multipliedFullWidth(by: rn[i])
        (pLow, isOverflow) = pLow.addingReportingOverflow(carry)
        if isOverflow {
          pHigh += 1
        }

        (ln[i + j], underflow) = ln[i + j].subtractingReportingOverflow(pLow)
        if underflow {
          borrow += 1
        }

        carry = pHigh
      }

      (ln[j + n], underflow) = ln[j + n].subtractingReportingOverflow(carry + borrow)

      if underflow {
        let newQhat = qhat - 1

        carry = 0
        var total: UInt = 0
        for i in 0 ..< n {
          (total, isOverflow) = ln[i + j].addingReportingOverflow(carry)
          carry = isOverflow ? 1 : 0
          (ln[i + j], isOverflow) = total.addingReportingOverflow(rn[i])
          if carry == 0 { carry = isOverflow ? 1 : 0 }
        }
        ln[j + n] += carry

        quot[j] = newQhat
      } else {
        quot[j] = qhat
      }
    }

    var rem = Words(repeating: 0, count: n)

    for i in 0 ..< (n - 1) {
      rem[i] = (ln[i] >> s) | ln[i + 1] << (bitWidth - s)
    }
    rem[n - 1] = ln[n - 1] >> s

    BigInt._dropExcessWords(words: &quot)
    BigInt._dropExcessWords(words: &rem)

    return (BigInt(_uncheckedWords: quot), BigInt(_uncheckedWords: rem))
  }

  private static func _signExtend(lhsWords: inout Words, rhsWords: inout Words) {
    let lhsIsNeg = (lhsWords.last ?? 0) >> (UInt.bitWidth - Int(1)) == 1
    let rhsIsNeg = (rhsWords.last ?? 0) >> (UInt.bitWidth - Int(1)) == 1

    if lhsWords.count > rhsWords.count {
      for _ in 0 ..< (lhsWords.count - rhsWords.count) {
        rhsIsNeg ? rhsWords.append(UInt.max) : rhsWords.append(0)
      }
    } else if rhsWords.count > lhsWords.count {
      for _ in 0 ..< (rhsWords.count - lhsWords.count) {
        lhsIsNeg ? lhsWords.append(UInt.max) : lhsWords.append(0)
      }
    }
  }

  @usableFromInline
  internal static func _dropExcessWords(words: inout Words) {
    while words.count > 1, words[words.endIndex - 1] == 0 {
      if words[words.endIndex - 2] <= Int.max {
        words.removeLast()
      } else {
        break
      }
    }

    while words.count > 1, words[words.endIndex - 1] == UInt.max {
      if words[words.endIndex - 2] > Int.max {
        words.removeLast()
      } else {
        break
      }
    }
  }
}

// inspired by https://eli.thegreenplace.net/2009/03/21/efficient-integer-exponentiation-algorithms
public func pow(_ lhs: BigInt, _ rhs: BigInt) -> BigInt {
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
