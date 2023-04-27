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

extension BigInt: LosslessStringConvertible {

  public init?(_ description: String) {
    self.init(description, radix: 10)
  }
  
  ////////////////////////////////////////////////////////////////////////////
  ///
  ///  NEW CODE STARTS
  ///  Code liberated and adapted from the Violet BigInt implementation
  ///  Speeds the time to initialize a BigInt by about a factor of 35 for
  ///  the test case of the string for 512! using radix 10. A radix 16 test
  ///  for the same number was 310X faster.
  public init?(_ description: String, radix: Int = 10) {
    guard 2 <= radix && radix <= Self.maxRadix else { return nil }
    guard !description.isEmpty else { return nil }

    let utf8 = description.utf8

    // Most of the time we will go 'fast' (in Swift dominant apps).
    // Fast (on 'UnsafeBufferPointer') is 2x faster than on 'UTF8View'.
    let fast = utf8.withContiguousStorageIfAvailable { buffer in
      return Self.parse(buffer, radix: radix)
    }

    // Try again -- if necessary -- with a standard buffer
    if let r = fast ?? Self.parse(utf8, radix: radix) {
      self = r
      return
    }
    return nil
  }

  private static func mulAdd(result: inout Words, multiplier: UInt, addIn: UInt) {
    var carry = addIn
    var overflow = false
    let highWord = result.count-1
    for i in 0...highWord {
      let product = result[i].multipliedFullWidth(by: multiplier)
      (result[i], overflow) = carry.addingReportingOverflow(product.low)
      (carry, overflow) = product.high.addingReportingOverflow(overflow ? 1 : 0)
    }
    assert(!overflow, "Word size overflow during \(#function)")
  }

  // MARK: - Parse

  private static func parse<C: BidirectionalCollection>(_ chars: C, radix: Int) -> BigInt? where C.Element == UInt8 {
    var (isNegative, index) = Self.checkSign(chars)
    let endIndex = chars.endIndex
    if index == endIndex { return nil } // only the sign was found

    // note and discard leading zeros
    let hasZeroPrefix = Self.stripLeadingZeros(chars, index: &index)
    if index == endIndex { return hasZeroPrefix ? BigInt() : nil }  // only zeros - return 0
    let (charCountPerWord, power) = Self.maxRepresentablePower(of: radix)
    let remainingCount = chars.distance(from: index, to: endIndex)

    // allocate one more word than estimated
    let capacity = (remainingCount / charCountPerWord) + 1
    let digitParser = DigitParser(radix: radix)
    var currentWord = UInt(0)
    let firstWordCount = remainingCount % charCountPerWord
    var remainingCharsInCurrentWord = firstWordCount == 0 ? charCountPerWord : firstWordCount
    let isPowerOfTwo = radix & (radix - 1) == 0

    // working buffer
    var buffer = Words(repeating: 0, count: capacity)
    if isPowerOfTwo {
      // Radix powers of 2 convert about 10X faster with this algorithm
      var reverseIndex = chars.endIndex
      chars.formIndex(before: &reverseIndex)
      var wordIndex = 0
      var wordShift = 0
      let bitsPerChar = radix.trailingZeroBitCount
      buffer[wordIndex] = 0
      while reverseIndex >= index {
        // check for illegal digits and convert to UInt
        let char = chars[reverseIndex]
        guard let digit = digitParser.parse(char) else { return nil }

        buffer[wordIndex] |= digit &<< wordShift
        wordShift &+= bitsPerChar
        if wordShift >= UInt.bitWidth {
          wordIndex &+= 1
          wordShift = wordShift % UInt.bitWidth
          assert(wordIndex < capacity)
          buffer[wordIndex] = digit &>> (bitsPerChar &- wordShift)
        }
        chars.formIndex(before: &reverseIndex)
      }
    } else {
      while index != endIndex {
        // check for illegal digits and convert to UInt
        let char = chars[index]
        guard let digit = digitParser.parse(char) else { return nil }

        // Overflows are guaranteed to not occur due to `charCountPerWord`
        currentWord = currentWord &* UInt(radix) &+ digit
        remainingCharsInCurrentWord &-= 1
        if remainingCharsInCurrentWord == 0 {
          // Append word even if it is zero -- zeros can occur in the middle of a number
          mulAdd(result: &buffer, multiplier: power, addIn: currentWord)
          currentWord = 0
          remainingCharsInCurrentWord = charCountPerWord
        }
        chars.formIndex(after: &index)
      }
    }

    BigInt._dropExcessWords(words: &buffer)
    var result = BigInt(_uncheckedWords: buffer)
    if isNegative { result.negate() }
    return result
  }

  private static func checkSign<C: Collection>(_ chars: C) -> (isNegative:Bool, index: C.Index) where C.Element == UInt8 {
    var index = chars.startIndex
    let first = chars[index]
    if first == _plus {
      chars.formIndex(after: &index)
      return (isNegative: false, index: index)
    }
    if first == _minus {
      chars.formIndex(after: &index)
      return (isNegative: true, index: index)
    }
    return (isNegative: false, index: index)
  }

  private static func stripLeadingZeros<C: Collection>(_ chars: C, index: inout C.Index) -> Bool where C.Element == UInt8 {
    let hasZeroPrefix = chars[index] == _0
    let endIndex = chars.endIndex

    // skip leading zeros
    while index != endIndex && chars[index] == _0 {
      chars.formIndex(after: &index)
    }
    return hasZeroPrefix
  }
  
  private struct DigitParser {
    private let numericalUpperBound: UInt8
    private let uppercaseUpperBound: UInt8
    private let lowercaseUpperBound: UInt8

    fileprivate init(radix: Int) {
      if radix <= 10 {
        self.numericalUpperBound = _0 &+ UInt8(truncatingIfNeeded: radix)
        self.uppercaseUpperBound = _A
        self.lowercaseUpperBound = _a
      } else {
        self.numericalUpperBound = _0 &+ 10
        self.uppercaseUpperBound = _A &+ UInt8(truncatingIfNeeded: radix &- 10)
        self.lowercaseUpperBound = _a &+ UInt8(truncatingIfNeeded: radix &- 10)
      }
    }

    fileprivate func parse(_ char: UInt8) -> UInt? {
      return
        _0 <= char && char < numericalUpperBound ? UInt(truncatingIfNeeded: char &- _0) :
        _A <= char && char < uppercaseUpperBound ? UInt(truncatingIfNeeded: char &- _A &+ 10) :
        _a <= char && char < lowercaseUpperBound ? UInt(truncatingIfNeeded: char &- _a &+ 10) :
        nil
    }
  }
  
  /// NEW CODE ENDS
  ///
  ////////////////////////////////////////////////////////////////////////////
}

extension BigInt : CustomStringConvertible {
  
  ////////////////////////////////////////////////////////////////////////////
  ///
  ///  NEW CODE STARTS

  /// Code below was shamelessly adapted from the Violet implementation of
  /// BigInt. I took a few shortcuts to reduce the code size: There's no
  /// DivBuffer and instead used a copy of the self.words for doing the
  /// divisions/shifts. A different approach was used to calculate the number
  /// of digits needed in a string — again less code was needed. The good:
  /// This code is almost 20X faster for decimals and 90X faster for binary
  /// radixes. The bad: Lots of code required to implement this improvement.
  /// Is it worth it? You decide. It's always easy to comment out and use the
  /// default (albeit much slower) String() implementation. Maybe the String
  /// in the runtime could be updated to be faster.
  public var description: String {
    return self.toString(radix: 10, uppercase: false)
  }
  
  private static var maxRadix: Int { 36 }
  
  // ASCII constants
  
  private static let _0     = UInt8(ascii: "0")
  private static let _A     = UInt8(ascii: "A")
  private static let _a     = UInt8(ascii: "a")
  private static let _plus  = UInt8(ascii: "+")
  private static let _minus = UInt8(ascii: "-")
  
  internal func div(_ dividend: inout Words, by divisor: UInt) -> UInt {
    var carry = UInt(0)
    for i in (0..<dividend.count).reversed() {
      (dividend[i], carry) = divisor.dividingFullWidth((carry, dividend[i]))
    }
    // Trim suffix zeros
    while !dividend.isEmpty && dividend[dividend.count - 1] == 0 {
      dividend.removeLast()
    }
    return carry
  }
  
  public func toString(radix: Int, uppercase: Bool) -> String {
    precondition(2 ... Self.maxRadix ~= radix, "Radix not in range 2 ... \(Self.maxRadix)")
    
    if self.signum() == 0 { return "0" }

    let digitCount = Int(Self.radixDigits[radix-2] * Double(words.count) + 0.5)
    let (charPerWord, power) = Self.maxRepresentablePower(of: radix)
    let stringMaxSize = digitCount + (self._isNegative ? 1 : 0)
    let radixValid = radix != 8 && radix != 32
    let isValidPowerOfTwoRadix = (radix & (radix-1) == 0) && radixValid
    
    var words = self.magnitude.words; words.reserveCapacity(self.words.count)
    if #available(macOS 11.0, iOS 14.0, *) {
      return StringLiteralType(unsafeUninitializedCapacity: stringMaxSize) { buffer in
        if isValidPowerOfTwoRadix {
          // Handle powers-of-two radixes
          let bitsPerChar = radix.trailingZeroBitCount
          let qr = UInt.bitWidth.quotientAndRemainder(dividingBy: bitsPerChar)
          assert(qr.remainder == 0, "String radix = \(radix) which does not fit in \(UInt.bitWidth) bits")
          var index = 0
          if self._isNegative {
            buffer[index] = Self._minus
            index = 1
          }
          
          // digits fit exactly into a word
          // 0000 0001 1010 0101
          // ^^^^ skip (but only for 1st word)
          let charCountPerWord = qr.quotient
          let last = words[words.count - 1]
          var skip = charCountPerWord - last.leadingZeroBitCount / bitsPerChar - 1
          let mask = UInt(radix - 1)
          
          for word in words.reversed() {
            for groupIndex in stride(from: skip, through: 0, by: -1) {
              let shift = groupIndex &* bitsPerChar
              let group = (word &>> shift) & mask
              buffer[index] = ascii(group, uppercase: uppercase)
              index &+= 1
            }
            
            // From now on we print everything, even middle '0'
            skip = charCountPerWord - 1
          }
          
          assert(index <= stringMaxSize)
          return index
        } else {
          // Deal with the hard-to-use radixes including base 10
          var index = stringMaxSize - 1 // start at end of the buffer
          while !words.isEmpty {
            var remainder = div(&words, by: power)
            let end = index - charPerWord
            
            // extract `radix` digits and add to the string `buffer`
            while remainder != 0 {
              let qr = remainder.quotientAndRemainder(dividingBy: UInt(radix))
              remainder = qr.quotient
              buffer[index] = ascii(qr.remainder, uppercase: uppercase)
              index &-= 1
            }
            
            // fill remaining word digits (except the first) with "0"s
            let isFirstWord = words.isEmpty
            while !isFirstWord && index != end {
              buffer[index] = Self._0
              index &-= 1
            }
          }
          
          // add a minus sign if the number is negative
          if self._isNegative {
            buffer[index] = Self._minus
            index &-= 1
          }
          
          // check for invalid capacity estimate
          var count = stringMaxSize
          if index != -1 {
            count = stringMaxSize - index - 1
            let dstPtr = buffer.baseAddress!
            let srcPtr = dstPtr.advanced(by: index+1)
            dstPtr.update(from: srcPtr, count: count)
            dstPtr[count] = 0
          }
          return count
        }
      }
    } else {
      // Fallback on earlier versions
      return String(self, radix: radix, uppercase: uppercase)
    }
  }
  
  /// Returns the highest number that satisfy `radix^n <= 2^Self.bitWidth`
  internal static func maxRepresentablePower(of radix: Int) -> (n: Int, power: UInt) {
    var n = 1
    var power =  UInt(radix)
    while true {
      let (newPower, overflow) = power.multipliedReportingOverflow(by: UInt(radix))
      if overflow { return (n, power) }
      n += 1
      power = newPower
    }
  }
  
  private func ascii(_ n: UInt, uppercase: Bool) -> UInt8 {
    assert(n < Self.maxRadix) // Always less, never equal!
    let n = UInt8(truncatingIfNeeded: n)
    return n < 10 ? n + Self._0 : n - 10 + (uppercase ? Self._A : Self._a)
  }
  
  /// Table of the number of digits for each radix from 2 to 36
  ///   y = log(Double(UInt.max)) / log(Double(radix))
  static let radixDigits : [Double] = [
    64,            40.3795042286, 32.0000000000, 27.5632997167, 24.7585796630,
    22.7972599749, 21.3333333333, 20.1897521143, 19.2659197225, 18.5001488843,
    17.8523485217, 17.2952418833, 16.8095702424, 16.3813135878, 16.0000000000,
    15.6576346956, 15.3479978604, 15.0661704555, 14.8082056422, 14.5708959166,
    14.3516047499, 14.1481426853, 13.9586746871, 13.7816498583, 13.6157474274,
    13.4598347429, 13.3129342513, 13.1741972775, 13.0428830138, 12.9183415413,
    12.8000000000, 12.6873512429, 12.5799444629, 12.4773774012, 12.3792898315
  ]
  
  /// NEW CODE ENDS
  ///
  ////////////////////////////////////////////////////////////////////////////
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
    if value >= 0, value <= UInt.max {
      words = [UInt(value)]  // No need for a table lookup here
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
    let isNegative = self._isNegative
    for i in 0 ..< words.count {
      if isOverflow {
        (words[i], isOverflow) = (~words[i]).addingReportingOverflow(1)
      } else {
        words[i] = ~words[i]
      }
    }

    BigInt._dropExcessWords(words: &words)
    if self != Self.zero && self._isNegative == isNegative {
      // Corner case where numbers like `0x8000000000000000 ... 0000`
      // remain unchanged after negation so we make sure any negative
      // numbers are truly negated into positive numbers
      if isNegative { words.append(0) } // make the number positive
    }
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
    guard source.isFinite, source == source.rounded(.towardZero) else {
      return nil
    }
    self.init(source)
  }

  public init<T>(_ source: T) where T: BinaryFloatingPoint {
    precondition(
      source.isFinite,
      """
      \(type(of: source)) value cannot be converted to BigInt because it is \
      either infinite or NaN
      """)

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

      if let last = words.last, last >= Int.max {
        words.append(0)
      }
      self.words = words
    }

    if isNegative {
      self.negate()
    }
  }

  public init<T>(_ source: T) where T: BinaryInteger {
    if source >= 0 && source < Int.max {
      words = [UInt(source)]
    } else {
      words = Words(source.words)
      if source > 0 && source.words[source.words.endIndex - 1] > Int.max {
        words.append(0)
      }
      // needed to handle sign-extended multi-word numbers that
      // actually fit in a single word
      BigInt._dropExcessWords(words: &words)
    }
  }

  public init<T>(clamping source: T) where T: BinaryInteger {
    self.init(source)
  }

  public init<T>(truncatingIfNeeded source: T) where T: BinaryInteger {
    self.init(source)  //words = Words(source.words)
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
      lhs.words[i] ^= rhsWords[i]
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
  public func signum() -> BigInt { _isNegative ? -1 : (self == 0) ? 0 : 1 }
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
      
      BigInt._dropExcessWords(words: &qhat)
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
  internal static func _div(lhs: BigInt, rhs: BigInt) -> (quotient: BigInt, remainder: BigInt) {
    precondition(rhs != 0, "Division by zero error!")

    // Speed up single-word divisions
    if lhs.words.count == 1, rhs.words.count == 1 {
      // check for corner case that causes overflow: Int.min / -1
      let lhsInt = Int(bitPattern: lhs.words[0])
      let rhsInt = Int(bitPattern: rhs.words[0])
      if !(lhsInt == Int.min && rhsInt == -1) {
        let (quot, rem) = lhsInt.quotientAndRemainder(dividingBy: rhsInt)
        return (BigInt(_uncheckedWords: [UInt(bitPattern: quot)]), BigInt(_uncheckedWords: [UInt(bitPattern: rem)]))
      }
    }

    let lhsIsNeg = lhs._isNegative
    let rhsIsNeg = rhs._isNegative

    var lhsWords = lhsIsNeg ? (-lhs).words : lhs.words
    var rhsWords = rhsIsNeg ? (-rhs).words : rhs.words
    
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

      BigInt._dropExcessWords(words: &quot)
      // signs are based on the Int definitions
      switch (lhsIsNeg, rhsIsNeg) {
        case (false, true):  return (-BigInt(_uncheckedWords: quot),  BigInt(r))
        case (false, false): return ( BigInt(_uncheckedWords: quot),  BigInt(r))
        case (true, false):  return (-BigInt(_uncheckedWords: quot), -BigInt(r))
        case (true, true):   return ( BigInt(_uncheckedWords: quot), -BigInt(r))
      }
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

    BigInt._dropExcessWords(words: &quot)
    BigInt._dropExcessWords(words: &rem)
    
    // signs are based on the Int definitions
    switch (lhsIsNeg, rhsIsNeg) {
      case (false, true):  return (-BigInt(_uncheckedWords: quot),  BigInt(_uncheckedWords: rem))
      case (false, false): return ( BigInt(_uncheckedWords: quot),  BigInt(_uncheckedWords: rem))
      case (true, false):  return (-BigInt(_uncheckedWords: quot), -BigInt(_uncheckedWords: rem))
      case (true, true):   return ( BigInt(_uncheckedWords: quot), -BigInt(_uncheckedWords: rem))
    }
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
