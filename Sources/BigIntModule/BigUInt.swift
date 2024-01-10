//===--- BigUInt.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

public struct BigUInt: UnsignedInteger {

  public typealias Words = [UInt]

  public private(set) var words: Words

  @usableFromInline
  internal init(_uncheckedWords: Words) {
    self.words = _uncheckedWords
  }

  public init<T>(bitPattern source: T) where T: BinaryInteger {
    words = Words(source.words)
    BigUInt._dropExcessWords(words: &words)
  }

  @usableFromInline
  internal var _isNegative: Bool {
    words[words.endIndex - 1] > Int.max
  }

  private static let _digits: [BigUInt] = (0 ... 36).map {
    BigUInt(_uncheckedWords: [UInt(bitPattern: $0)])
  }
  
  private static let _digitRadix = BigInt(_uncheckedWords: [0, 1])
}

// MARK: - Basic Behaviors

extension BigUInt: Equatable {

  @inlinable
  public static func == (lhs: BigUInt, rhs: BigUInt) -> Bool {
    lhs.words == rhs.words
  }

  @inlinable
  public static func != (lhs: BigUInt, rhs: BigUInt) -> Bool {
    !(lhs == rhs)
  }
}

extension BigUInt: Hashable {

  @inlinable
  public func hash(into hasher: inout Hasher) {
    hasher.combine(words)
  }
}

extension BigUInt: Comparable {

  @inlinable
  public static func < (lhs: BigUInt, rhs: BigUInt) -> Bool {
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

extension BigUInt: LosslessStringConvertible {

  public init?(_ description: String) {
    self.init(description, radix: 10)
  }

  public init?<T>(_ description: T, radix: Int = 10) where T: StringProtocol {
    precondition(2 ... 36 ~= radix, "Radix not in range 2 ... 36")

    self = 0

    let hasPrefix = description.hasPrefix("+")
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
      self *= BigUInt._digits[radix]
      self += BigUInt._digits[Int(byte)]
    }
  }
}

extension BigUInt: Decodable {

  public init(from decoder: Decoder) throws {
    let singleValueContainer = try decoder.singleValueContainer()
    let description = try singleValueContainer.decode(String.self)
    guard let result = BigUInt(description) else {
      throw DecodingError.dataCorruptedError(
        in: singleValueContainer,
        debugDescription: "BigUInt(\(description.debugDescription)) failed")
    }
    self = result
  }
}

extension BigUInt: Encodable {

  public func encode(to encoder: Encoder) throws {
    var singleValueContainer = encoder.singleValueContainer()
    try singleValueContainer.encode(description)
  }
}

// MARK: - Numeric Protocols

extension BigUInt: ExpressibleByIntegerLiteral {

  public init(integerLiteral value: Int) {
    if value < BigUInt._digits.count {
      self = BigUInt._digits[value]
    } else {
      words = [UInt(bitPattern: value)]
    }
  }
}

extension BigUInt: AdditiveArithmetic {

  @inlinable
  public static func + (lhs: BigUInt, rhs: BigUInt) -> BigUInt {
    var result = lhs
    result += rhs
    return result
  }

  public static func += (lhs: inout BigUInt, rhs: BigUInt) {
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

    lhs.words.append(0)
    rhsWords.append(0)
    BigUInt._zeroExtend(lhsWords: &lhs.words, rhsWords: &rhsWords)

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

    BigUInt._dropExcessWords(words: &lhs.words)
  }

  @inlinable
  public static func - (lhs: BigUInt, rhs: BigUInt) -> BigUInt {
    var result = lhs
    result -= rhs
    return result
  }

  @inlinable
  public static func -= (lhs: inout BigUInt, rhs: BigUInt) {
    lhs = .init(_uncheckedWords: (BigInt(_uncheckedWords: lhs.words) + -BigInt(_uncheckedWords: rhs.words)).words)
  }
}

extension BigUInt: Numeric {

  public init?<T>(exactly source: T) where T: BinaryInteger {
    self.init(source)
  }

  public var magnitude: BigUInt { self }

  public static func * (lhs: BigUInt, rhs: BigUInt) -> BigUInt {
    let lhsWords = lhs.words
    let rhsWords = rhs.words

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

    return BigUInt(_uncheckedWords: newWords)
  }

  @inlinable
  public static func *= (lhs: inout BigUInt, rhs: BigUInt) {
    lhs = lhs * rhs
  }
}

extension BigUInt: BinaryInteger {

  public init?<T>(exactly source: T) where T: BinaryFloatingPoint {
    guard source.isFinite, source == source.rounded(.towardZero) else {
      return nil
    }
    self.init(source)
  }

  public init<T>(_ source: T) where T: BinaryFloatingPoint {
    precondition(
      source.isFinite && source >= 0.0,
      """
      \(type(of: source)) value cannot be converted to BigUInt because it is \
      either infinite, NaN, or negative
      """)

    var float = source

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

      if let last = words.last, last >= Int.max {
        words.append(0)
      }
      self.words = words
    }
  }

  public init<T>(_ source: T) where T: BinaryInteger {
    if source >= 0, source < BigUInt._digits.count {
      self = BigUInt._digits[Int(source)]
    } else {
      words = Words(source.words)
      if source > 0 && source.words[source.words.endIndex - 1] > Int.max {
        words.append(0)
      }
      // needed to handle sign-extended multi-word numbers that
      // actually fit in a single word
      BigUInt._dropExcessWords(words: &words)
    }
  }

  public init<T>(clamping source: T) where T: BinaryInteger {
    self.init(source)
  }

  public init<T>(truncatingIfNeeded source: T) where T: BinaryInteger {
    words = Words(source.words)
  }

  public var bitWidth: Int { words.count * UInt.bitWidth }

  public var trailingZeroBitCount: Int {
    var totalZeros = 0
    for word in words {
      if word == 0 {
        totalZeros += UInt.bitWidth
      } else {
        totalZeros += word.trailingZeroBitCount
        break
      }
    }
    return totalZeros
  }

  @inlinable
  public static func / (lhs: BigUInt, rhs: BigUInt) -> BigUInt {
    let (result, _) = _div(lhs: lhs, rhs: rhs)
    return result
  }

  @inlinable
  public static func /= (lhs: inout BigUInt, rhs: BigUInt) {
    lhs = lhs / rhs
  }

  @inlinable
  public static func % (lhs: BigUInt, rhs: BigUInt) -> BigUInt {
    let (_, result) = _div(lhs: lhs, rhs: rhs)

    return result
  }

  @inlinable
  public static func %= (lhs: inout BigUInt, rhs: BigUInt) {
    lhs = lhs % rhs
  }

  @inlinable
  public static prefix func ~ (x: BigUInt) -> BigUInt {
    let newWords = x.words.map { ~$0 }
    return BigUInt(_uncheckedWords: Words(newWords))
  }

  public static func &= (lhs: inout BigUInt, rhs: BigUInt) {
    var rhsWords = rhs.words
    BigUInt._zeroExtend(lhsWords: &lhs.words, rhsWords: &rhsWords)

    for i in 0 ..< rhsWords.count {
      lhs.words[i] &= rhsWords[i]
    }

    BigUInt._dropExcessWords(words: &lhs.words)
  }

  public static func |= (lhs: inout BigUInt, rhs: BigUInt) {
    var rhsWords = rhs.words
    BigUInt._zeroExtend(lhsWords: &lhs.words, rhsWords: &rhsWords)

    for i in 0 ..< rhsWords.count {
      lhs.words[i] |= rhsWords[i]
    }

    BigUInt._dropExcessWords(words: &lhs.words)
  }

  public static func ^= (lhs: inout BigUInt, rhs: BigUInt) {
    var rhsWords = rhs.words
    BigUInt._zeroExtend(lhsWords: &lhs.words, rhsWords: &rhsWords)

    for i in 0 ..< rhsWords.count {
      lhs.words[i] &= rhsWords[i]
    }

    BigUInt._dropExcessWords(words: &lhs.words)
  }

  public static func <<= <RHS>(lhs: inout BigUInt, rhs: RHS) where RHS: BinaryInteger {
    if rhs.signum() < 0 {
      lhs >>= rhs.magnitude
      return
    }

    let wordLength = UInt.bitWidth

    let (fullWords, remainder) = rhs.quotientAndRemainder(dividingBy: RHS(wordLength))
    lhs.words = Words(repeating: 0, count: Int(fullWords)) + lhs.words + [0]

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
    }

    BigUInt._dropExcessWords(words: &lhs.words)
  }

  public static func >>= <RHS>(lhs: inout BigUInt, rhs: RHS) where RHS: BinaryInteger {
    if rhs.signum() < 0 {
      lhs <<= rhs.magnitude
      return
    }

    let wordLength = UInt.bitWidth

    let (fullWords, remainder) = rhs.quotientAndRemainder(dividingBy: RHS(wordLength))
    if fullWords < lhs.words.count {
      lhs.words.removeFirst(Int(fullWords))
    } else {
      lhs = 0
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

    BigUInt._dropExcessWords(words: &lhs.words)
  }

  @inlinable
  public func quotientAndRemainder(dividingBy rhs: BigUInt) -> (quotient: BigUInt, remainder: BigUInt) {
    return BigUInt._div(lhs: self, rhs: rhs)
  }
}

// MARK: -

extension BigUInt {

  /// See _The Art of Computer Programming_ volume 2 by Donald Knuth, Section 4.3.1: The Classical Algorithms
  private static func _findQhat(
    high: UInt,
    low: UInt.Magnitude,
    divisor: UInt,
    nextVdigit: UInt,
    nextUdigit: UInt
  ) -> UInt {
    var qhat: Array<UInt>
    var rhat: Array<UInt>
    if high >= divisor {
      let v = divisor
      let u = [low, high]
      var r: UInt = 0
      qhat = Words(repeating: 0, count: 2)
      for j in (0...1).reversed() {
        let uj = u[j]
        (qhat[j], r) = v.dividingFullWidth((r, uj))
      }
      
      BigUInt._dropExcessWords(words: &qhat)
      rhat = [r]
    } else {
      let (qhatWord, rhatWord) = divisor.dividingFullWidth((high, low))
      qhat = [qhatWord]
      rhat = [rhatWord]
    }
    
    repeat {
      var qhatTooLarge = false
      
      if qhat.count > 1 {
        qhatTooLarge = true
      } else {
        // All of the following is computing and checking qhat*v_n-2 > rhat*b + u_j+n-2
        // from TAoCP Volume 2 Section 4.3.1, Algorithm D, step D3
        let (comp_lhs_hi, comp_lhs_lo) = qhat[0].multipliedFullWidth(by: nextVdigit)
        
        if comp_lhs_hi > rhat[0] {
          qhatTooLarge = true
        } else if comp_lhs_hi == rhat[0] && comp_lhs_lo > nextUdigit {
          qhatTooLarge = true
        }
      }
      
      // high >= divisor is standing in for the test qhat >= b from Algorithm D step D3
      if qhatTooLarge {
        // begin qhat -= 1
        if qhat.count == 1 {
          qhat[0] -= 1
        } else {
          let (qlow, underflow) = qhat[0].subtractingReportingOverflow(1)
          qhat[0] = qlow
          if qhat[1] > 0 && underflow {
            qhat[1] -= 1
            if qhat[1] == 0 {
              qhat.remove(at: 1)
            }
          }
        }
        // end qhat -= 1
        
        // begin rhat += divisor
        let (rhatResult, overflow) : (UInt, Bool)
        if rhat.count == 1 || rhat[1] == 0 {
          (rhatResult, overflow) = rhat[0].addingReportingOverflow(divisor)
          rhat[0] = rhatResult
          if overflow {
            rhat.append(1)
          }
        } // we don't need an else because rhat is already larger than BigInt._digitRadix
        // end rhat += divisor
      } else {
        break
      }
    } while rhat.count == 1 // equivalent to rhat < b
    
    return qhat[0]
  }

  /// See _The Art of Computer Programming_ volume 2 by Donald Knuth, Section 4.3.1: The Classical Algorithms
  @usableFromInline
  internal static func _div(lhs: BigUInt, rhs: BigUInt) -> (quotient: BigUInt, remainder: BigUInt) {
    precondition(rhs != _digits[0], "Division by zero error!")

    if lhs.words.count == 1, rhs.words.count == 1 {
      let (quot, rem) = Int(bitPattern: lhs.words[0]).quotientAndRemainder(dividingBy: Int(bitPattern: rhs.words[0]))
      return (BigUInt(_uncheckedWords: [UInt(bitPattern: quot)]), BigUInt(_uncheckedWords: [UInt(bitPattern: rem)]))
    }

    var lhsWords = lhs.words
    var rhsWords = rhs.words
    
    // See the answer to exercise 16 in Section 4.3.1 of TAOCP
    if rhsWords.count == 1 || (rhsWords.count == 2 && rhsWords[1] == 0) {
      let v = rhsWords[0]
      let u = lhsWords
      var r: UInt = 0
      var quot = Words(repeating: 0, count: u.count)
      for j in (0...(u.count - 1)).reversed() {
        let uj = u[j]
        (quot[j], r) = v.dividingFullWidth((r, uj))
      }

      if quot[u.count - 1] > UInt(Int.max) {
        quot.append(0)
      }

      BigUInt._dropExcessWords(words: &quot)
      return (quotient: BigUInt(_uncheckedWords: quot), remainder: BigUInt(r))
    }

    while rhsWords[rhsWords.endIndex - 1] == 0 {
      rhsWords.removeLast()
    }

    if rhsWords.count > lhsWords.count { return (0, lhs) }

    if lhsWords.count <= rhsWords.count {
      for _ in 0 ... (rhsWords.count - lhsWords.count) {
        lhsWords.append(0)
      }
    }

    let m = lhsWords.count - rhsWords.count
    let n = rhsWords.count

    let bitWidth = UInt(UInt.bitWidth)

    let s = UInt(rhsWords[n - 1].leadingZeroBitCount)
    let rn = UnsafeMutablePointer<UInt>.allocate(capacity: n)
    rn.initialize(repeating: 0, count: n)
    defer { rn.deallocate() }
    for i in (1 ... (n - 1)).reversed() {
      rn[i] = (rhsWords[i] << s) | (rhsWords[i - 1] >> (bitWidth - s))
    }
    rn[0] = rhsWords[0] << s

    let ln = UnsafeMutablePointer<UInt>.allocate(capacity: m + n + 1)
    ln.initialize(repeating: 0, count: m + n + 1)
    defer { ln.deallocate() }
    ln[m + n] = lhsWords[m + n - 1] >> (bitWidth - s)
    for i in (1 ... (m + n - 1)).reversed() {
      ln[i] = (lhsWords[i] << s) | (lhsWords[i - 1] >> (bitWidth - s))
    }
    ln[0] = lhsWords[0] << s

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
        (ln[j + n], _) = ln[j + n].addingReportingOverflow(carry)

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
    
    if rem[n - 1] > UInt(Int.max) {
      rem.append(0)
    }

    BigUInt._dropExcessWords(words: &quot)
    BigUInt._dropExcessWords(words: &rem)

    return (BigUInt(_uncheckedWords: quot), BigUInt(_uncheckedWords: rem))
  }

  private static func _zeroExtend(lhsWords: inout Words, rhsWords: inout Words) {
    if lhsWords.count > rhsWords.count {
      for _ in 0 ..< (lhsWords.count - rhsWords.count) {
        rhsWords.append(0)
      }
    } else if rhsWords.count > lhsWords.count {
      for _ in 0 ..< (rhsWords.count - lhsWords.count) {
        lhsWords.append(0)
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
