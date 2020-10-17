//===--- BigInt.swift -----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// An arbitrarily large signed integer.
///
/// Because there is no logical minimum or maximum value representable as a
/// `BigInt`, operations may take a long time to complete and results may
/// exceed available memory.
///
/// Storage
/// =======
///
/// Internally, a `BigInt` value `x` is represented by its signum, significand,
/// and exponent using the following notional formula:
///
/// ```
/// x == _signum * _significand << (UInt.bitWidth * _exponent)
/// ```
///
/// Each integer value has exactly one normalized representation, where the
/// significand--a collection of the significant digits of the value's magnitude
/// stored in words of type `UInt`--is trimmed of all leading and trailing words
/// that are zero.
@frozen
public struct BigInt {
  /// The combination field.
  ///
  /// The signum and exponent of this value are stored in the combination field
  /// as follows:
  ///
  /// ```
  /// _combination = _signum * (_exponent + 1)
  /// ```
  @usableFromInline
  internal var _combination: Int
  
  /// The signum of this value, expressed as an `Int`.
  ///
  /// Given a value `x`, `x._signum` is `-1` if `x` is less than zero and `1` if
  /// `x` is greater than zero; otherwise, `0`.
  @inlinable
  internal var _signum: Int { _combination.signum() }
  
  /// The exponent of this value, expressed as an `Int`.
  ///
  /// Given a value `x`, its magnitude can be computed by the following notional
  /// formula:
  ///
  /// ```
  /// let magnitude = x._significand << (UInt.bitWidth * x._exponent)
  /// ```
  ///
  /// The exponent obtained in this manner is also the zero-based index of the
  /// first (lowest) nonzero word, enabling random access of the words in the
  /// two's complement representation of a value in constant time.
  ///
  /// Edge case: if `x` is zero, `x._exponent` is `-1`.
  @inlinable
  internal var _exponent: Int { abs(_combination) &- 1 }
  
  /// The significand, a collection of the significant digits of this value's
  /// magnitude stored in words of type `UInt`.
  ///
  /// The first element of the collection is the lowest word.
  @usableFromInline
  internal var _significand: _Significand
  
  /// A Boolean value indicating whether this value is zero.
  ///
  /// A value is zero if and only if its combination field is zero.
  @inlinable
  internal var _isZero: Bool { _combination == 0 }
  
  /// Normalizes the internal representation of this value.
  ///
  /// When a value is normalized, leading (i.e., the highest) zero words are
  /// trimmed. Then, trailing (i.e., the lowest) zero words are trimmed and
  /// `_exponent` is incremented for each word removed.
  ///
  /// A value is zero if and only if its combination field is zero. Its
  /// internal representation, therefore, is normalized when its significand is
  /// an empty collection.
  @inlinable
  internal mutating func _normalize() {
    guard _combination != 0,
      let i = _significand.firstIndex(where: { $0 != 0 }) else {
      _combination = 0
      _significand = []
      return
    }
    
    let j = 1 &+ _significand.lastIndex(where: { $0 != 0 })!
    _significand.removeLast(_significand.count &- j)
    
    _significand.removeFirst(i)
    _combination += _combination < 0 ? -i : i
  }
  
  /// Creates a `BigInt` with the given combination field and significand.
  ///
  /// - Parameters:
  ///   - combination: The combination field of the created value, equivalent to
  ///     `_signum * (_exponent + 1)`.
  ///     If the significand is nonzero, then the signum (and therefore the
  ///     combination field) must also be nonzero.
  ///   - significand: The significand of the created value.
  @inlinable
  internal init(_combination combination: Int, significand: _Significand) {
    _combination = combination
    _significand = significand
    _normalize()
  }
}

extension BigInt: Hashable, Comparable {
  // We must override the default implementation of `==` that comes with
  // `Strideable` conformance. (`BinaryInteger` refines `Strideable`.)
  @inlinable
  public static func == (lhs: BigInt, rhs: BigInt) -> Bool {
    lhs._combination == rhs._combination && lhs._significand == rhs._significand
  }
  
  @inlinable
  public static func < (lhs: BigInt, rhs: BigInt) -> Bool {
    if lhs._isZero { return rhs._combination > 0 }
    if rhs._isZero { return lhs._combination < 0 }
    if (lhs._combination < 0) != (rhs._combination < 0) {
      return lhs._combination < rhs._combination
    }

    let words = (left: lhs.words, right: rhs.words)
    let counts = (left: words.left.count, right: words.right.count)
    if counts.left != counts.right {
      return (lhs._combination < 0) != (counts.left < counts.right)
    }
    let exponent = Swift.min(lhs._exponent, rhs._exponent)
    for i in (exponent..<counts.left).reversed() {
      let (left, right) = (words.left[i], words.right[i])
      if left != right { return left < right }
    }
    return false
  }
}

extension BigInt: ExpressibleByIntegerLiteral {
  @inlinable
  public init(integerLiteral value: Int) {
    _combination = value.signum()
    _significand = value == 0 ? [] : [value.magnitude]
  }
}

extension BigInt: AdditiveArithmetic {
  @inlinable
  public init() {
    _combination = 0
    _significand = []
  }
  
  @inlinable
  public static var zero: BigInt { BigInt() }
  
  // @inlinable
  public static func += (lhs: inout BigInt, rhs: BigInt) {
    guard !lhs._isZero else {
      lhs = rhs
      return
    }
    guard !rhs._isZero else { return }
    guard (lhs._combination < 0) == (rhs._combination < 0) else {
      lhs -= -rhs
      return
    }
    
    let exponents = (left: lhs._exponent, right: rhs._exponent)
    let counts =
      (left: lhs._significand.count + exponents.left,
      right: rhs._significand.count + exponents.right)
    if counts.left < counts.right {
      lhs._significand.reserveCapacity(
        lhs._significand.count + (counts.right &- counts.left) + 1)
    }
    if exponents.left > exponents.right {
      lhs._combination = lhs._signum * (exponents.right + 1)
      lhs._significand.insert(
        contentsOf: repeatElement(0, count: exponents.left &- exponents.right),
        at: 0)
      lhs._significand.add(rhs._significand, exponent: 0)
    } else {
      lhs._significand.add(
        rhs._significand, exponent: exponents.right &- exponents.left)
    }
    lhs._normalize()
  }

  @inlinable
  public static func + (lhs: BigInt, rhs: BigInt) -> BigInt {
    var result = lhs
    result += rhs
    return result
  }

  // @inlinable
  public static func -= (lhs: inout BigInt, rhs: BigInt) {
    guard !lhs._isZero else {
      lhs = -rhs
      return
    }
    guard !rhs._isZero else { return }
    guard (lhs._combination < 0) == (rhs._combination < 0) else {
      lhs += -rhs
      return
    }
    
    let exponents = (left: lhs._exponent, right: rhs._exponent)
    let counts =
      (left: lhs._significand.count + exponents.left,
      right: rhs._significand.count + exponents.right)
    if counts.left < counts.right {
      lhs._significand.reserveCapacity(
        lhs._significand.count + (counts.right &- counts.left))
    }
    let overflow: Bool
    if exponents.left > exponents.right {
      lhs._combination = lhs._signum * (exponents.right + 1)
      lhs._significand.insert(
        contentsOf: repeatElement(0, count: exponents.left &- exponents.right),
        at: 0)
      overflow = lhs._significand.subtract(rhs._significand, exponent: 0)
    } else {
      overflow = lhs._significand.subtract(
        rhs._significand, exponent: exponents.right &- exponents.left)
    }
    if overflow {
      lhs._combination.negate()
      lhs._significand.complement(radix: 2)
    }
    lhs._normalize()
  }
  
  @inlinable
  public static func - (lhs: BigInt, rhs: BigInt) -> BigInt {
    var result = lhs
    result -= rhs
    return result
  }
}

extension BigInt: SignedNumeric {
  @inlinable
  public init?<T: BinaryInteger>(exactly source: T) {
    self.init(source)
  }

  @inlinable
  public var magnitude: BigInt { _combination < 0 ? -self : self }
  
  @inlinable
  public mutating func negate() { _combination.negate() }

  // @inlinable
  public static func * (lhs: BigInt, rhs: BigInt) -> BigInt {
    guard !lhs._isZero && !rhs._isZero else { return BigInt() }
    let combination =
      lhs._signum * rhs._signum * (lhs._exponent + rhs._exponent + 1)
    let significand =
      lhs._significand.multiplying(by: rhs._significand /*, karatsubaThreshold: 8 */)
    return BigInt(_combination: combination, significand: significand)
  }

  @inlinable
  public static func *= (lhs: inout BigInt, rhs: BigInt) {
    lhs = lhs * rhs
  }
}

extension BigInt: BinaryInteger {
  @inlinable
  public var words: Words { Words(self) }

  @inlinable
  public var bitWidth: Int {
    guard !_isZero else { return 0 }
    let lastIndex = _significand.count &- 1
    let highWord = _significand[lastIndex]
    let magnitudeBitWidth =
      UInt.bitWidth * (_exponent + lastIndex)
        + (UInt.bitWidth &- highWord.leadingZeroBitCount)
    // For a positive value:
    // We need to add one leading zero bit for a signed representation.
    if _combination > 0 { return magnitudeBitWidth + 1 }
    // For a negative value:
    // The two's complement of a magnitude has the same bit width as that of the
    // magnitude itself if and only if the magnitude is a power of two.
    // Otherwise, we need one additional bit to fit the two's complement.
    //
    // (Note that `(x & (x &- 1)) == 0` is a method of determining if `x` is
    // a power of two.)
    return lastIndex == 0 && (highWord & (highWord &- 1)) == 0
      ? magnitudeBitWidth
      : magnitudeBitWidth + 1
  }

  @inlinable
  public var trailingZeroBitCount: Int {
    guard !_isZero else { return 0 }
    // The trailing zero bit count of a value and its two's complement are
    // always the same.
    return _exponent * UInt.bitWidth + _significand[0].trailingZeroBitCount
  }
  
  @inlinable
  public func signum() -> BigInt { BigInt(_signum) }
  
  @inlinable
  public init<T: BinaryInteger>(_ source: T) {
    guard source != (0 as T) else {
      self = BigInt()
      return
    }
    if let temporary = UInt(exactly: source) {
      _combination = 1
      _significand = [temporary]
      return
    }
    self = BigInt(
      _combination: Int(source.signum()),
      significand: _Significand(source.magnitude.words))
  }
  
  @inlinable
  public init<T: BinaryInteger>(clamping source: T) {
    self.init(source)
  }
  
  @inlinable
  public init<T: BinaryInteger>(truncatingIfNeeded source: T) {
    self.init(source)
  }
  
  @usableFromInline // @inlinable
  internal static func _convert<T: BinaryFloatingPoint>(
    from source: T
  ) -> (value: BigInt?, exact: Bool) {
    // This implementation is adapted from its counterpart implemented for
    // `FixedWidthInteger` types in the standard library.
    guard !source.isZero else { return (0, true) }
    guard source.isFinite else { return (nil, false) }
    let exponent = source.exponent
    let minBitWidth = source.significandWidth
    let isExact = (minBitWidth <= exponent)
    let bitPattern = source.significandBitPattern
    // `RawSignificand.bitWidth` is not available if `RawSignificand` does not
    // conform to `FixedWidthInteger`; we can compute this value as follows if
    // `source` is finite:
    let bitWidth = minBitWidth &+ bitPattern.trailingZeroBitCount
    let shift = exponent - T.Exponent(bitWidth)
    let shiftedBitPattern = BigInt(bitPattern) << shift
    let magnitude = ((1 as BigInt) << exponent) | shiftedBitPattern
    return (source < 0 ? -magnitude : magnitude, isExact)
  }
  
  @inlinable
  public init?<T: BinaryFloatingPoint>(exactly source: T) {
    let (temporary, exact) = BigInt._convert(from: source)
    guard exact, let value = temporary else { return nil }
    self = value
  }

  @inlinable
  public init<T: BinaryFloatingPoint>(_ source: T) {
    guard let value = BigInt._convert(from: source).value else {
      fatalError(
        "\(T.self) value cannot be converted to BigInt because it is infinite or NaN")
    }
    self = value
  }

  @inlinable
  public static var isSigned: Bool { true }

  @inlinable
  public static func / (lhs: BigInt, rhs: BigInt) -> BigInt {
    var result = lhs
    result /= rhs
    return result
  }

  // @inlinable
  public static func /= (lhs: inout BigInt, rhs: BigInt) {
    guard !rhs._isZero else { fatalError("Division by zero") }
    guard !lhs._isZero && abs(lhs) >= abs(rhs) else {
      lhs = 0
      return
    }
    
    let exponents = (left: lhs._exponent, right: rhs._exponent)
    if exponents.left < exponents.right {
      lhs._significand.removeFirst(exponents.right &- exponents.left)
    } else if exponents.left > exponents.right {
      lhs._significand.insert(
        contentsOf: repeatElement(0, count: exponents.left &- exponents.right),
        at: 0)
    }
    lhs._combination = lhs._signum * rhs._signum
    
    if lhs._significand != rhs._significand {
      lhs._significand.divide(by: rhs._significand)
    } else {
      lhs._significand = [1]
    }
    lhs._normalize()
  }

  @inlinable
  public static func % (lhs: BigInt, rhs: BigInt) -> BigInt {
    var result = lhs
    result %= rhs
    return result
  }

  // @inlinable
  public static func %= (lhs: inout BigInt, rhs: BigInt) {
    guard !rhs._isZero else { fatalError("Division by zero") }
    guard !lhs._isZero && abs(lhs) >= abs(rhs) else { return }
    
    var result = _Significand()
    let exponents = (left: lhs._exponent, right: rhs._exponent)
    if exponents.left < exponents.right {
      let i = exponents.right &- exponents.left
      result.insert(contentsOf: lhs._significand[..<i], at: 0)
      lhs._significand.removeFirst(i)
    } else if exponents.left > exponents.right {
      lhs._significand.insert(
        contentsOf: repeatElement(0, count: exponents.left &- exponents.right),
        at: 0)
    }
    lhs._combination = lhs._signum
    
    if lhs._significand != rhs._significand {
      result.insert(
        contentsOf: lhs._significand.divide(by: rhs._significand),
        at: result.endIndex)
    }
    swap(&result, &lhs._significand)
    lhs._normalize()
  }

  // @inlinable
  public static func & (lhs: BigInt, rhs: BigInt) -> BigInt {
    guard !lhs._isZero && !rhs._isZero else { return 0 }
    
    let signum = lhs._combination < 0 && rhs._combination < 0 ? -1 : 1
    let exponent = Swift.max(lhs._exponent, rhs._exponent)
    
    let words = (left: lhs.words, right: rhs.words)
    let count = lhs._combination > 0 && rhs._combination > 0
      ? Swift.min(words.left.count, words.right.count)
      : Swift.max(words.left.count, words.right.count)
    
    guard exponent < count else { return 0 }
    var significand = _Significand((exponent..<count).map { idx in
      words.left[idx] & words.right[idx]
    })
    if signum < 0 {
      let overflow = significand.complement(radix: 2)
      assert(!overflow)
    }
    
    return BigInt(
      _combination: signum * (exponent + 1), significand: significand)
  }
  
  @inlinable
  public static func &= (lhs: inout BigInt, rhs: BigInt) {
    lhs = lhs & rhs
  }

  // @inlinable
  public static func | (lhs: BigInt, rhs: BigInt) -> BigInt {
    guard !lhs._isZero else { return rhs._isZero ? 0 : rhs }
    guard !rhs._isZero else { return lhs }
    
    let signum = (lhs._combination > 0 && rhs._combination > 0) ? 1 : -1
    let exponent = Swift.min(lhs._exponent, rhs._exponent)
    
    let words = (left: lhs.words, right: rhs.words)
    let count = lhs._combination < 0 && rhs._combination < 0
      ? Swift.min(words.left.count, words.right.count)
      : Swift.max(words.left.count, words.right.count)
    
    assert(exponent < count)
    var significand = _Significand((exponent..<count).map { idx in
      words.left[idx] | words.right[idx]
    })
    if signum < 0 {
      let overflow = significand.complement(radix: 2)
      assert(!overflow)
    }
    
    return BigInt(
      _combination: signum * (exponent + 1), significand: significand)
  }
  
  @inlinable
  public static func |= (lhs: inout BigInt, rhs: BigInt) {
    lhs = lhs | rhs
  }

  // @inlinable
  public static func ^ (lhs: BigInt, rhs: BigInt) -> BigInt {
    guard !lhs._isZero else { return rhs._isZero ? 0 : rhs }
    guard !rhs._isZero else { return lhs }
    
    let signum = (lhs._combination < 0) != (rhs._combination < 0) ? -1 : 1
    let exponent = Swift.min(lhs._exponent, rhs._exponent)
    
    let words = (left: lhs.words, right: rhs.words)
    let count = Swift.max(words.left.count, words.right.count)
    
    assert(exponent < count)
    var significand = _Significand((exponent..<count).map { idx in
      words.left[idx] ^ words.right[idx]
    })
    if signum < 0 {
      let overflow = significand.complement(radix: 2)
      assert(!overflow)
    }
    
    return BigInt(
      _combination: signum * (exponent + 1), significand: significand)
  }
  
  @inlinable
  public static func ^= (lhs: inout BigInt, rhs: BigInt) {
    lhs = lhs ^ rhs
  }
  
  // @inlinable
  public static func <<= <RHS: BinaryInteger>(lhs: inout BigInt, rhs: RHS) {
    guard !lhs._isZero && rhs != 0 else { return }
    guard rhs > 0 else {
      lhs >>= 0 - rhs
      return
    }
    
    let quotient, remainder: Int
    if let rhs = Int(exactly: rhs) {
      (quotient, remainder) =
        rhs.quotientAndRemainder(dividingBy: UInt.bitWidth)
    } else {
      let temporary = rhs.quotientAndRemainder(dividingBy: RHS(UInt.bitWidth))
      (quotient, remainder) = (Int(temporary.0), Int(temporary.1))
    }
    
    if remainder != 0 {
      var carry = 0 as UInt
      for i in 0..<lhs._significand.count {
        let temporary = lhs._significand[i]
        lhs._significand[i] = temporary &<< remainder | carry
        carry = temporary &>> (UInt.bitWidth &- remainder)
      }
      if carry != 0 { lhs._significand.append(carry) }
    }
    
    lhs._combination += lhs._combination < 0 ? -quotient : quotient
    lhs._normalize()
  }
  
  // @inlinable
  public static func >>= <RHS: BinaryInteger>(lhs: inout BigInt, rhs: RHS) {
    guard !lhs._isZero && rhs != 0 else { return }
    guard rhs > 0 else {
      lhs <<= 0 - rhs
      return
    }
    
    var quotient, remainder: Int
    if let rhs = Int(exactly: rhs) {
      (quotient, remainder) =
        rhs.quotientAndRemainder(dividingBy: UInt.bitWidth)
    } else {
      let temporary = rhs.quotientAndRemainder(dividingBy: RHS(UInt.bitWidth))
      (quotient, remainder) = (Int(temporary.0), Int(temporary.1))
    }
    
    // For a negative value:
    // Shifting right is equivalent to dividing by the corresponding power of
    // two and rounding down (towards negative infinity). Therefore, if we
    // remove any nonzero bits, we'll need to subtract one (or, equivalently,
    // add one to the magnitude) after shifting.
    var rounding: Bool
    if quotient > lhs._exponent {
      quotient -= lhs._exponent
      guard quotient < lhs._significand.count else {
        lhs = lhs._combination < 0 ? -1 : 0
        return
      }
      lhs._significand.removeFirst(quotient)
      lhs._combination = lhs._signum
      rounding = lhs._combination < 0
    } else {
      lhs._combination += lhs._combination < 0 ? quotient : -quotient
      rounding = false
    }

    if remainder != 0 {
      var carry = 0 as UInt
      for i in (0..<lhs._significand.count).reversed() {
        let temporary = lhs._significand[i]
        lhs._significand[i] = temporary &>> remainder | carry
        carry = temporary &<< (UInt.bitWidth &- remainder)
      }
      if carry != 0 {
        if lhs._exponent != 0 {
          lhs._significand.insert(carry, at: 0)
          lhs._combination += lhs._combination < 0 ? 1 : -1
        } else if lhs._combination < 0 {
          rounding = true
        }
      }
    }
    if rounding { lhs._significand.increment() }
    lhs._normalize()
  }
  
  @inlinable
  public static prefix func ~ (x: BigInt) -> BigInt { -(x + 1) }
}

extension BigInt: SignedInteger { }

extension BigInt {
  /// Creates a `BigInt` from the given words.
  ///
  /// - Parameter words: The words of an arbitrarily large signed integer. For a
  ///   negative value, words are of the two’s complement representation.
  //    `words` must be a nonempty collection.
  @inlinable
  public init<C: RandomAccessCollection>(
    words: C
  ) where C.Element == UInt, C.Index == Int {
    precondition(!words.isEmpty, "Can't create value from an empty collection of words")
    
    let signum = Int(bitPattern: words.last!) < 0 ? -1 : 1
    guard let exponent = words.firstIndex(where: { $0 != 0 }) else {
      _combination = 0
      _significand = []
      return
    }
    _combination = signum * (exponent + 1)
    
    let count = words.count &- exponent
    var temporary = [signum < 0 ? ~words[exponent] &+ 1 : words[exponent]]
    if count > 1 {
      temporary.reserveCapacity(count)
      if signum < 0 {
        for offset in 1..<count { temporary.append(~words[exponent &+ offset]) }
      } else {
        for offset in 1..<count { temporary.append(words[exponent &+ offset]) }
      }
    }
    let j = 1 &+ temporary.lastIndex(where: { $0 != 0 })!
    temporary.removeLast(count &- j)
    _significand = _Significand(temporary)
  }
  
  /// Creates a `BigInt` from the given words.
  ///
  /// - Parameter words: The words of an arbitrarily large signed integer. For a
  ///   negative value, words are of the two’s complement representation.
  @inlinable
  public init(words: Words) {
    self = words._value
  }
}

/// Documentation is transposed from the corresponding random APIs implemented
/// for `FixedWidthInteger` in the standard library.
extension BigInt {
  /// Returns a random value within the specified range, using the given
  /// generator as a source for randomness.
  ///
  /// Use this method to generate an integer within a specific range when you
  /// are using a custom random number generator.
  ///
  /// - Note: The algorithm used to create random values may change in a future
  ///   version of Swift. If you're passing a generator that results in the
  ///   same sequence of integer values each time you run your program, that
  ///   sequence may change when your program is compiled using a different
  ///   version of Swift.
  ///
  /// - Parameters:
  ///   - range: The range in which to create a random value.
  ///     `range` must not be empty.
  ///   - generator: The random number generator to use when creating the
  ///     new random value.
  /// - Returns: A random value within the bounds of `range`.
  @inlinable
  public static func random<T: RandomNumberGenerator>(
    in range: Range<BigInt>,
    using generator: inout T
  ) -> BigInt {
    precondition(!range.isEmpty, "Can't get random value with an empty range")
    let delta = range.upperBound - range.lowerBound
    return range.lowerBound + generator._next(upperBound: delta)
  }
  
  /// Returns a random value within the specified range.
  ///
  /// Use this method to generate an integer within a specific range.
  ///
  /// This method is equivalent to calling `random(in:using:)`, passing in the
  /// system's default random generator.
  ///
  /// - Parameter range: The range in which to create a random value.
  ///   `range` must not be empty.
  /// - Returns: A random value within the bounds of `range`.
  @inlinable
  public static func random(in range: Range<BigInt>) -> BigInt {
    var generator = SystemRandomNumberGenerator()
    return BigInt.random(in: range, using: &generator)
  }
  
  /// Returns a random value within the specified range, using the given
  /// generator as a source for randomness.
  ///
  /// Use this method to generate an integer within a specific range when you
  /// are using a custom random number generator.
  ///
  /// - Note: The algorithm used to create random values may change in a future
  ///   version of Swift. If you're passing a generator that results in the
  ///   same sequence of integer values each time you run your program, that
  ///   sequence may change when your program is compiled using a different
  ///   version of Swift.
  ///
  /// - Parameters:
  ///   - range: The range in which to create a random value.
  ///   - generator: The random number generator to use when creating the
  ///     new random value.
  /// - Returns: A random value within the bounds of `range`.
  @inlinable
  public static func random<T: RandomNumberGenerator>(
    in range: ClosedRange<BigInt>,
    using generator: inout T
  ) -> BigInt {
    let delta = range.upperBound - range.lowerBound + 1
    return range.lowerBound + generator._next(upperBound: delta)
  }
  
  /// Returns a random value within the specified range.
  ///
  /// Use this method to generate an integer within a specific range.
  ///
  /// This method is equivalent to calling `random(in:using:)`, passing in the
  /// system's default random generator.
  ///
  /// - Parameter range: The range in which to create a random value.
  /// - Returns: A random value within the bounds of `range`.
  @inlinable
  public static func random(in range: ClosedRange<BigInt>) -> BigInt {
    var generator = SystemRandomNumberGenerator()
    return Self.random(in: range, using: &generator)
  }
}

extension BigInt: LosslessStringConvertible {
  /// Creates a new integer value from the given string and radix.
  ///
  /// The string passed as `text` may begin with a plus or minus sign character
  /// (`+` or `-`), followed by one or more numeric digits (`0-9`) or letters
  /// (`a-z` or `A-Z`). Parsing of the string is case insensitive.
  ///
  /// If `text` is in an invalid format or contains characters that are out of
  /// bounds for the given `radix`, the result is `nil`.
  ///
  /// - Parameters:
  ///   - text: The ASCII representation of a number in the radix passed as
  ///     `radix`.
  ///   - radix: The radix, or base, to use for converting `text` to an integer
  ///     value. `radix` must be in the range `2...36`. The default is 10.
  // @inlinable
  public init?<S: StringProtocol>(_ text: S, radix: Int = 10) {
    precondition(radix >= 2 && radix <= 36, "Radix not in range 2...36")
    
    self = BigInt()
    var negative = false
    var iterator = text.unicodeScalars.makeIterator()
    
    var rune_ = iterator.next()
    guard rune_ != nil else { return nil }
    if rune_! == "-" {
      negative = true
      rune_ = iterator.next()
    } else if rune_! == "+" {
      rune_ = iterator.next()
    }
    
    var chunk = ""
    if radix == 2
      || (radix == 4 && UInt.bitWidth % 2 == 0)
      || (radix == 16 && UInt.bitWidth % 4 == 0) {
      let size = UInt.bitWidth / radix._binaryLogarithm()
      while let rune = rune_ {
        guard rune.isASCII && rune != "+" && rune != "-" else { return nil }
        if size == chunk.unicodeScalars.count {
          guard let x = UInt(chunk, radix: radix) else { return nil }
          self <<= UInt.bitWidth
          if x != 0 { self += BigInt(x) }
          chunk = ""
        }
        chunk.unicodeScalars.append(rune)
        rune_ = iterator.next()
      }
      guard let x = UInt(chunk, radix: radix) else { return nil }
      self <<= chunk.unicodeScalars.count * radix._binaryLogarithm()
      if x != 0 { self += BigInt(x) }
    } else {
      var multiplier = 1
      while let rune = rune_ {
        guard rune.isASCII && rune != "+" && rune != "-" else { return nil }
        let temporary = multiplier.multipliedReportingOverflow(by: radix)
        if temporary.overflow {
          guard let x = UInt(chunk, radix: radix) else { return nil }
          self *= BigInt(multiplier)
          if x != 0 { self += BigInt(x) }
          chunk = ""
          multiplier = radix
        } else {
          multiplier = temporary.partialValue
        }
        chunk.unicodeScalars.append(rune)
        rune_ = iterator.next()
      }
      guard let x = UInt(chunk, radix: radix) else { return nil }
      self *= BigInt(multiplier)
      if x != 0 { self += BigInt(x) }
    }
    if negative { self.negate() }
  }
  
  @inlinable
  public init?(_ description: String) {
    self.init(description, radix: 10)
  }
}

extension BigInt: Codable {
  // @inlinable
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode("\(self)")
  }

  // @inlinable
  public init(from decoder: Decoder) throws {
    let string = try decoder.singleValueContainer().decode(String.self)
    self.init(string)!
  }
}
