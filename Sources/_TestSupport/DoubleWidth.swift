//===--- DoubleWidth.swift ------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2017-2024 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// A fixed-width integer that has twice the bit width of its base type.
///
/// You can use the `DoubleWidth` type to continue calculations with the result
/// of a full width arithmetic operation. Normally, when you perform a full
/// width operation, the result is a tuple of the high and low parts of the
/// result.
///
///     let a = 2241543570477705381
///     let b = 186319822866995413
///     let c = a.multipliedFullWidth(by: b)
///     // c == (high: 22640526660490081, low: 7959093232766896457)
///
/// The tuple `c` can't be used in any further comparisons or calculations. To
/// use this value, create a `DoubleWidth` instance from the result. You can
/// use the `DoubleWidth` instance in the same way that you would use any other
/// integer type.
///
///     let d = DoubleWidth(a.multipliedFullWidth(by: b))
///     // d == 417644001000058515200174966092417353
///
///     // Check the calculation:
///     print(d / DoubleWidth(a) == b)
///     // Prints "true"
///
///     if d > Int.max {
///         print("Too big to be an 'Int'!")
///     } else {
///         print("Small enough to fit in an 'Int'")
///     }
///     // Prints "Too big to be an 'Int'!"
///
/// The `DoubleWidth` type is not intended as a replacement for a variable-width
/// integer type. Nesting `DoubleWidth` instances, in particular, may result in
/// undesirable performance.
public struct DoubleWidth<Base : FixedWidthInteger> {
  public typealias High = Base
  public typealias Low = Base.Magnitude

  internal var _storage: (low: Low, high: High)
}

extension DoubleWidth {
  /// The "high word" of this value.
  ///
  /// Equivalent to `Base(self >> Base.bitWidth)`.
  public var high: High {
    return _storage.high
  }

  /// The "low word" of the value.
  ///
  /// Equivalent to`Base.Magnitude(truncatingIfNecessary: self)`.
  public var low: Low {
    return _storage.low
  }

  /// Creates a new instance from the given tuple of high and low parts.
  ///
  /// Equivalent to
  /// ```
  /// DoubleWidth<Base>(high) << Base.bitWidth + DoubleWidth<Base>(low)
  /// ```
  ///
  /// - Parameter value: The tuple to use as the source of the new instance's
  ///   high and low parts.
  public init(_ value: (high: High, low: Low)) {
    self._storage = (low: value.low, high: value.high)
  }

  // We expect users to invoke the public initializer above as demonstrated in
  // the documentation (that is, by passing in the result of a full width
  // operation).
  //
  // Internally, we'll need to create new instances by supplying high and low
  // parts directly; ((double parentheses)) greatly impair readability,
  // especially when nested:
  //
  //   DoubleWidth<DoubleWidth>((DoubleWidth((0, 0)), DoubleWidth((0, 0))))
  //
  // For that reason, we'll include an internal initializer that takes two
  // separate arguments.
  
  /// Creates a new instance from the given tuple of high and low parts.
  ///
  /// Equivalent to
  /// ```
  /// DoubleWidth<Base>(high) << Base.bitWidth + DoubleWidth<Base>(low)
  /// ```
  internal init(_ _high: High, _ low: Low) {
    self.init((_high, low))
  }
  
  /// Zero.
  public init() {
    self.init(0, 0)
  }
}

extension DoubleWidth : CustomStringConvertible {
  public var description: String {
    return String(self, radix: 10)
  }
}

extension DoubleWidth : CustomDebugStringConvertible {
  public var debugDescription: String {
    return "(\(_storage.high), \(_storage.low))"
  }
}

extension DoubleWidth : Equatable {
  public static func ==(lhs: DoubleWidth, rhs: DoubleWidth) -> Bool {
    return lhs._storage.low == rhs._storage.low
        && lhs._storage.high == rhs._storage.high
  }
}

extension DoubleWidth : Comparable {
  public static func <(lhs: DoubleWidth, rhs: DoubleWidth) -> Bool {
    if lhs._storage.high < rhs._storage.high { return true }
    else if lhs._storage.high > rhs._storage.high { return false }
    else { return lhs._storage.low < rhs._storage.low }
  }
}

extension DoubleWidth : Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(low)
    hasher.combine(high)
  }
}

extension DoubleWidth : Numeric {
  public typealias Magnitude = DoubleWidth<Low>

  public var magnitude: Magnitude {
    let result = Magnitude(Low(truncatingIfNeeded: _storage.high), _storage.low)
    if Base.isSigned && _storage.high < (0 as High) {
      return ~result &+ 1
    } else {
      return result
    }
  }

  internal init(_ _magnitude: Magnitude) {
    self.init(High(_magnitude._storage.high), _magnitude._storage.low)
  }

  public init<T : BinaryInteger>(_ source: T) {
    guard let result = DoubleWidth<Base>(exactly: source) else {
      preconditionFailure("Value is outside the representable range")
    }
    self = result
  }

  public init?<T : BinaryInteger>(exactly source: T) {
    // Can't represent a negative 'source' if Base is unsigned.
    guard DoubleWidth.isSigned || source >= 0 else { return nil }
    
    // Is 'source' entirely representable in Low?
    if let low = Low(exactly: source.magnitude) {
      self.init(source < (0 as T) ? (~0, ~low &+ 1) : (0, low))
    } else {
      // At this point we know source.bitWidth > Base.bitWidth, or else we
      // would've taken the first branch.
      let lowInT = source & T(~0 as Low)
      let highInT = source >> Low.bitWidth
      
      let low = Low(lowInT)
      guard let high = High(exactly: highInT) else { return nil }
      self.init(high, low)
    }
  }
}

extension DoubleWidth {
  public struct Words {
    public var _high: High.Words
    public var _low: Low.Words

    public init(_ value: DoubleWidth<Base>) {
      // Multiples of word size only.
      guard Base.bitWidth == Base.Magnitude.bitWidth &&
        (UInt.bitWidth % Base.bitWidth == 0 ||
        Base.bitWidth % UInt.bitWidth == 0) else {
        fatalError("Access to words is not supported on this type")
      }
      self._high = value._storage.high.words
      self._low = value._storage.low.words
      assert(!_low.isEmpty)
    }
  }
}

extension DoubleWidth.Words: RandomAccessCollection {
  public typealias Index = Int
  
  public var startIndex: Index {
    return 0
  }

  public var endIndex: Index {
    return count
  }
  
  public var count: Int {
    if Base.bitWidth < UInt.bitWidth { return 1 }
    return _low.count + _high.count
  }

  public subscript(_ i: Index) -> UInt {
    if Base.bitWidth < UInt.bitWidth {
      precondition(i == 0, "Invalid index")
      assert(2 * Base.bitWidth <= UInt.bitWidth)
      return _low.first! | (_high.first! &<< Base.bitWidth._lowWord) 
    }
    if i < _low.count {
      return _low[i + _low.startIndex]
    }
    
    return _high[i - _low.count + _high.startIndex]
  }
}

extension DoubleWidth : FixedWidthInteger {
  public var words: Words {
    return Words(self)
  }

  public static var isSigned: Bool {
    return Base.isSigned
  }

  public static var max: DoubleWidth {
    return self.init(High.max, Low.max)
  }

  public static var min: DoubleWidth {
    return self.init(High.min, Low.min)
  }

  public static var bitWidth: Int {
    return High.bitWidth + Low.bitWidth
  }

  public func addingReportingOverflow(_ rhs: DoubleWidth)
    -> (partialValue: DoubleWidth, overflow: Bool) {
    let (low, lowOverflow) =
      _storage.low.addingReportingOverflow(rhs._storage.low)
    let (high, highOverflow) =
      _storage.high.addingReportingOverflow(rhs._storage.high)
    let result = (high &+ (lowOverflow ? 1 : 0), low)
    let overflow = highOverflow ||
      high == Base.max && lowOverflow
    return (partialValue: DoubleWidth(result), overflow: overflow)
  }
  public func subtractingReportingOverflow(_ rhs: DoubleWidth)
    -> (partialValue: DoubleWidth, overflow: Bool) {
    let (low, lowOverflow) =
      _storage.low.subtractingReportingOverflow(rhs._storage.low)
    let (high, highOverflow) =
      _storage.high.subtractingReportingOverflow(rhs._storage.high)
    let result = (high &- (lowOverflow ? 1 : 0), low)
    let overflow = highOverflow ||
      high == Base.min && lowOverflow
    return (partialValue: DoubleWidth(result), overflow: overflow)
  }

  public func multipliedReportingOverflow(
    by rhs: DoubleWidth
  ) -> (partialValue: DoubleWidth, overflow: Bool) {
    let (carry, product) = multipliedFullWidth(by: rhs)
    let partialValue = DoubleWidth(truncatingIfNeeded: product)
    // Overflow has occured if carry is not just the sign-extension of
    // partialValue (which is zero when Base is unsigned).
    let overflow = carry != (partialValue >> DoubleWidth.bitWidth)
    return (partialValue, overflow)
  }

  public func quotientAndRemainder(
    dividingBy other: DoubleWidth
  ) -> (quotient: DoubleWidth, remainder: DoubleWidth) {
    let (quotient, remainder) =
      Magnitude._divide(self.magnitude, by: other.magnitude)
    guard DoubleWidth.isSigned else {
      return (DoubleWidth(quotient), DoubleWidth(remainder))
    }
    let isNegative = (self.high < (0 as High)) != (other.high < (0 as High))
    let quotient_ = isNegative
      ? quotient == DoubleWidth.min.magnitude
        ? DoubleWidth.min
        : 0 - DoubleWidth(quotient)
      : DoubleWidth(quotient)
    let remainder_ = self.high < (0 as High)
      ? 0 - DoubleWidth(remainder)
      : DoubleWidth(remainder)
    return (quotient_, remainder_)
  }

  public func dividedReportingOverflow(
    by other: DoubleWidth
  ) -> (partialValue: DoubleWidth, overflow: Bool) {
    if other == (0 as DoubleWidth) { return (self, true) }
    if DoubleWidth.isSigned && other == -1 && self == .min {
      return (self, true)
    }
    return (quotientAndRemainder(dividingBy: other).quotient, false)
  }

  public func remainderReportingOverflow(
    dividingBy other: DoubleWidth
  ) -> (partialValue: DoubleWidth, overflow: Bool) {
    if other == (0 as DoubleWidth) { return (self, true) }
    if DoubleWidth.isSigned && other == -1 && self == .min { return (0, true) }
    return (quotientAndRemainder(dividingBy: other).remainder, false)
  }
  
  // When using a pre-Swift 6.0 runtime, `&*` is not a protocol requirement of
  // FixedWidthInteger, which results in the default implementation of this
  // operation ending up recursively calling itself forever. In order to avoid
  // this, we keep the concrete implementation around.
  public func multipliedFullWidth(
    by other: DoubleWidth
  ) -> (high: DoubleWidth, low: DoubleWidth.Magnitude) {
    let isNegative = DoubleWidth.isSigned &&
      (self < (0 as DoubleWidth)) != (other < (0 as DoubleWidth))

    func mul(_ x: Low, _ y: Low) -> (partial: Low, carry: Low) {
      let (high, low) = x.multipliedFullWidth(by: y)
      return (low, high)
    }
        
    func sum(_ x: Low, _ y: Low, _ z: Low) -> (partial: Low, carry: Low) {
      let (sum1, overflow1) = x.addingReportingOverflow(y)
      let (sum2, overflow2) = sum1.addingReportingOverflow(z)
      let carry: Low = (overflow1 ? 1 : 0) + (overflow2 ? 1 : 0)
      return (sum2, carry)
    }
        
    let lhs = self.magnitude
    let rhs = other.magnitude
        
    let a = mul(rhs._storage.low, lhs._storage.low)
    let b = mul(rhs._storage.low, lhs._storage.high)
    let c = mul(rhs._storage.high, lhs._storage.low)
    let d = mul(rhs._storage.high, lhs._storage.high)
        
    let mid1 = sum(a.carry, b.partial, c.partial)
    let mid2 = sum(b.carry, c.carry, d.partial)
        
    let low =
      DoubleWidth<Low>(mid1.partial, a.partial)
    let (sum_, overflow_) =
      mid1.carry.addingReportingOverflow(mid2.partial)
    let high =
      DoubleWidth(High(mid2.carry + d.carry + (overflow_ ? 1 : 0)), sum_)
        
    if isNegative {
      let (lowComplement, overflow) = (~low).addingReportingOverflow(1)
      return (~high + (overflow ? 1 : 0 as DoubleWidth), lowComplement)
    } else {
      return (high, low)
    }
  }

  public func dividingFullWidth(
    _ dividend: (high: DoubleWidth, low: DoubleWidth.Magnitude)
  ) -> (quotient: DoubleWidth, remainder: DoubleWidth) {
    let other = DoubleWidth<DoubleWidth>(dividend)
    let (quotient, remainder) =
      Magnitude._divide(other.magnitude, by: self.magnitude)
    guard DoubleWidth.isSigned else {
      return (DoubleWidth(quotient), DoubleWidth(remainder))
    }
    let isNegative =
      (self.high < (0 as High)) != (other.high.high < (0 as High))
    let quotient_ = isNegative
      ? quotient == DoubleWidth.min.magnitude
        ? DoubleWidth.min
        : 0 - DoubleWidth(quotient)
      : DoubleWidth(quotient)
    let remainder_ = other.high.high < (0 as High)
      ? 0 - DoubleWidth(remainder)
      : DoubleWidth(remainder)
    return (quotient_, remainder_)
  }

  public static func &=(
    lhs: inout DoubleWidth, rhs: DoubleWidth
  ) {
    lhs._storage.low &= rhs._storage.low
    lhs._storage.high &= rhs._storage.high
  }
  public static func |=(
    lhs: inout DoubleWidth, rhs: DoubleWidth
  ) {
    lhs._storage.low |= rhs._storage.low
    lhs._storage.high |= rhs._storage.high
  }
  public static func ^=(
    lhs: inout DoubleWidth, rhs: DoubleWidth
  ) {
    lhs._storage.low ^= rhs._storage.low
    lhs._storage.high ^= rhs._storage.high
  }

  public static func <<=(lhs: inout DoubleWidth, rhs: DoubleWidth) {
    if DoubleWidth.isSigned && rhs < (0 as DoubleWidth) {
      lhs >>= 0 - rhs
      return
    }
    
    // Shift is larger than this type's bit width.
    if rhs._storage.high != (0 as High) ||
      rhs._storage.low >= DoubleWidth.bitWidth
    {
      lhs = 0
      return
    }

    lhs &<<= rhs
  }
  
  public static func >>=(lhs: inout DoubleWidth, rhs: DoubleWidth) {
    if DoubleWidth.isSigned && rhs < (0 as DoubleWidth) {
      lhs <<= 0 - rhs
      return
    }

    // Shift is larger than this type's bit width.
    if rhs._storage.high != (0 as High) ||
      rhs._storage.low >= DoubleWidth.bitWidth
    {
      lhs = lhs < (0 as DoubleWidth) ? ~0 : 0
      return
    }

    lhs &>>= rhs
  }

  /// Returns this value "masked" by its bit width.
  ///
  /// "Masking" notionally involves repeatedly incrementing or decrementing
  /// this value by `self.bitWidth` until the result is contained in the
  /// range `0..<self.bitWidth`.
  internal func _masked() -> DoubleWidth {
    let bits = DoubleWidth(DoubleWidth.bitWidth)
    if DoubleWidth.bitWidth.nonzeroBitCount == 1 {
      return self & (bits &- 1)
    }
    let reduced = self % bits
    // bitWidth is always positive, but the value being reduced might have
    // been negative, in which case reduced will also be negative. We need
    // the representative in [0, bitWidth), so conditionally add the count
    // to get the positive residue.
    if Base.isSigned && reduced < 0 { return reduced &+ bits }
    return reduced
  }

  public static func &<<=(lhs: inout DoubleWidth, rhs: DoubleWidth) {
    let rhs = rhs._masked()

    guard rhs._storage.low < Base.bitWidth else {
      lhs._storage.high = High(
        truncatingIfNeeded: lhs._storage.low &<<
          (rhs._storage.low &- Low(Base.bitWidth)))
      lhs._storage.low = 0
      return
    }

    guard rhs._storage.low != (0 as Low) else { return }
    lhs._storage.high &<<= High(rhs._storage.low)
    lhs._storage.high |= High(
      truncatingIfNeeded: lhs._storage.low &>>
        (Low(Base.bitWidth) &- rhs._storage.low))
    lhs._storage.low &<<= rhs._storage.low
  }
  
  public static func &>>=(lhs: inout DoubleWidth, rhs: DoubleWidth) {
    let rhs = rhs._masked()

    guard rhs._storage.low < Base.bitWidth else {
      lhs._storage.low = Low(
        truncatingIfNeeded: lhs._storage.high &>>
          High(rhs._storage.low &- Low(Base.bitWidth)))
      lhs._storage.high = lhs._storage.high < (0 as High) ? ~0 : 0
      return
    }

    guard rhs._storage.low != (0 as Low) else { return }
    lhs._storage.low &>>= rhs._storage.low
    lhs._storage.low |= Low(
      truncatingIfNeeded: lhs._storage.high &<<
        High(Low(Base.bitWidth) &- rhs._storage.low))
    lhs._storage.high &>>= High(rhs._storage.low)
  }
  

  // FIXME(integers): remove this once the operators are back to Numeric
  public static func + (
    lhs: DoubleWidth, rhs: DoubleWidth
  ) -> DoubleWidth {
    var lhs = lhs
    lhs += rhs
    return lhs
  }

  public static func +=(
    lhs: inout DoubleWidth, rhs: DoubleWidth
  ) {
    let (result, overflow) = lhs.addingReportingOverflow(rhs)
    precondition(!overflow, "Overflow in +=")
    lhs = result
  }

  // FIXME(integers): remove this once the operators are back to Numeric
  public static func - (
    lhs: DoubleWidth, rhs: DoubleWidth
  ) -> DoubleWidth {
    var lhs = lhs
    lhs -= rhs
    return lhs
  }

  public static func -=(
    lhs: inout DoubleWidth, rhs: DoubleWidth
  ) {
    let (result, overflow) = lhs.subtractingReportingOverflow(rhs)
    precondition(!overflow, "Overflow in -=")
    lhs = result
  }

  // FIXME(integers): remove this once the operators are back to Numeric
  public static func * (
    lhs: DoubleWidth, rhs: DoubleWidth
  ) -> DoubleWidth {
    var lhs = lhs
    lhs *= rhs
    return lhs
  }

  public static func *=(
    lhs: inout DoubleWidth, rhs: DoubleWidth
  ) {
    let (result, overflow) = lhs.multipliedReportingOverflow(by:rhs)
    precondition(!overflow, "Overflow in *=")
    lhs = result
  }

  // FIXME(integers): remove this once the operators are back to Numeric
  public static func / (
    lhs: DoubleWidth, rhs: DoubleWidth
  ) -> DoubleWidth {
    var lhs = lhs
    lhs /= rhs
    return lhs
  }

  public static func /=(
    lhs: inout DoubleWidth, rhs: DoubleWidth
  ) {
    let (result, overflow) = lhs.dividedReportingOverflow(by:rhs)
    precondition(!overflow, "Overflow in /=")
    lhs = result
  }

  // FIXME(integers): remove this once the operators are back to Numeric
  public static func % (
    lhs: DoubleWidth, rhs: DoubleWidth
  ) -> DoubleWidth {
    var lhs = lhs
    lhs %= rhs
    return lhs
  }

  public static func %=(
    lhs: inout DoubleWidth, rhs: DoubleWidth
  ) {
    let (result, overflow) = lhs.remainderReportingOverflow(dividingBy:rhs)
    precondition(!overflow, "Overflow in %=")
    lhs = result
  }
  
  public static func &+(
    lhs: DoubleWidth, rhs: DoubleWidth
  ) -> DoubleWidth {
    let (low, carry) = lhs.low.addingReportingOverflow(rhs.low)
    let high = lhs.high &+ rhs.high &+ (carry ? 1 : 0)
    return DoubleWidth(high, low)
  }
  
  public static func &-(
    lhs: DoubleWidth, rhs: DoubleWidth
  ) -> DoubleWidth {
    let (low, borrow) = lhs.low.subtractingReportingOverflow(rhs.low)
    let high = lhs.high &- rhs.high &- (borrow ? 1 : 0)
    return DoubleWidth(high, low)
  }
  
  public static func &*(
    lhs: DoubleWidth, rhs: DoubleWidth
  ) -> DoubleWidth {
    let p00 = lhs.low.multipliedFullWidth(by: rhs.low)
    let p10 = lhs.high &* Base(truncatingIfNeeded: rhs.low)
    let p01 = Base(truncatingIfNeeded: lhs.low) &* rhs.high
    return DoubleWidth(p10 &+ p01 &+ Base(truncatingIfNeeded: p00.high), p00.low)
  }

  public init(_truncatingBits bits: UInt) {
    _storage.low = Low(_truncatingBits: bits)
    _storage.high = High(_truncatingBits: bits >> UInt(Low.bitWidth))
  }

  public init(integerLiteral x: Int) {
    self.init(x)
  }
  public var leadingZeroBitCount: Int {
    return high == (0 as High)
      ? High.bitWidth + low.leadingZeroBitCount
      : high.leadingZeroBitCount
  }

  public var trailingZeroBitCount: Int {
    return low == (0 as Low)
      ? Low.bitWidth + high.trailingZeroBitCount
      : low.trailingZeroBitCount
  }

  public var nonzeroBitCount: Int {
    return high.nonzeroBitCount + low.nonzeroBitCount
  }

  public var byteSwapped: DoubleWidth {
    return DoubleWidth(
      High(truncatingIfNeeded: low.byteSwapped),
      Low(truncatingIfNeeded: high.byteSwapped))
  }
}

extension DoubleWidth : UnsignedInteger where Base : UnsignedInteger {
  /// Returns the quotient and remainder after dividing a triple-width magnitude
  /// `lhs` by a double-width magnitude `rhs`.
  ///
  /// This operation is conceptually that described by Burnikel and Ziegler
  /// (1998).
  internal static func _divide(
    _ lhs: (high: Low, mid: Low, low: Low), by rhs: Magnitude
  ) -> (quotient: Low, remainder: Magnitude) {
    // The following invariants are guaranteed to hold by dividingFullWidth or
    // quotientAndRemainder before this method is invoked:
    assert(rhs.leadingZeroBitCount == 0)
    assert(Magnitude(lhs.high, lhs.mid) < rhs)

    guard lhs.high != (0 as Low) else {
      let lhs_ = Magnitude(lhs.mid, lhs.low)
      return lhs_ < rhs ? (0, lhs_) : (1, lhs_ &- rhs)
    }

    // Estimate the quotient.
    var quotient = lhs.high == rhs.high
      ? Low.max
      : rhs.high.dividingFullWidth((lhs.high, lhs.mid)).quotient
    // Compute quotient * rhs.
    // TODO: This could be performed more efficiently.
    var product =
      DoubleWidth<Magnitude>(
        0, Magnitude(quotient.multipliedFullWidth(by: rhs.low)))
    let (x, y) = quotient.multipliedFullWidth(by: rhs.high)
    product += DoubleWidth<Magnitude>(Magnitude(0, x), Magnitude(y, 0))
    // Compute the remainder after decrementing quotient as necessary.
    var remainder =
      DoubleWidth<Magnitude>(
        Magnitude(0, lhs.high), Magnitude(lhs.mid, lhs.low))
    while remainder < product {
      quotient = quotient &- 1
      remainder += DoubleWidth<Magnitude>(0, rhs)
    }
    remainder -= product

    return (quotient, remainder.low)
  }

  /// Returns the quotient and remainder after dividing a quadruple-width
  /// magnitude `lhs` by a double-width magnitude `rhs`.
  internal static func _divide(
    _ lhs: DoubleWidth<Magnitude>, by rhs: Magnitude
  ) -> (quotient: Magnitude, remainder: Magnitude) {
    guard _fastPath(rhs > (0 as Magnitude)) else {
      fatalError("Division by zero")
    }
    guard _fastPath(rhs >= lhs.high) else {
      fatalError("Division results in an overflow")
    }

    if lhs.high == (0 as Magnitude) {
      return lhs.low.quotientAndRemainder(dividingBy: rhs)
    }

    if rhs.high == (0 as Low) {
      let a = lhs.high.high % rhs.low
      let b = a == (0 as Low)
        ? lhs.high.low % rhs.low
        : rhs.low.dividingFullWidth((a, lhs.high.low)).remainder
      let (x, c) = b == (0 as Low)
        ? lhs.low.high.quotientAndRemainder(dividingBy: rhs.low)
        : rhs.low.dividingFullWidth((b, lhs.low.high))
      let (y, d) = c == (0 as Low)
        ? lhs.low.low.quotientAndRemainder(dividingBy: rhs.low)
        : rhs.low.dividingFullWidth((c, lhs.low.low))
      return (Magnitude(x, y), Magnitude(0, d))
    }

    // Left shift both rhs and lhs, then divide and right shift the remainder.
    let shift = rhs.leadingZeroBitCount
    let rhs = rhs &<< shift
    let lhs = lhs &<< shift
    if lhs.high.high == (0 as Low)
      && Magnitude(lhs.high.low, lhs.low.high) < rhs {
      let (quotient, remainder) =
        Magnitude._divide((lhs.high.low, lhs.low.high, lhs.low.low), by: rhs)
      return (Magnitude(0, quotient), remainder &>> shift)
    }
    let (x, a) =
      Magnitude._divide((lhs.high.high, lhs.high.low, lhs.low.high), by: rhs)
    let (y, b) =
      Magnitude._divide((a.high, a.low, lhs.low.low), by: rhs)
    return (Magnitude(x, y), b &>> shift)
  }

  /// Returns the quotient and remainder after dividing a double-width
  /// magnitude `lhs` by a double-width magnitude `rhs`.
  internal static func _divide(
    _ lhs: Magnitude, by rhs: Magnitude
  ) -> (quotient: Magnitude, remainder: Magnitude) {
    guard _fastPath(rhs > (0 as Magnitude)) else {
      fatalError("Division by zero")
    }
    guard rhs < lhs else {
      if _fastPath(rhs > lhs) { return (0, lhs) }
      return (1, 0)
    }

    if lhs.high == (0 as Low) {
      let (quotient, remainder) =
        lhs.low.quotientAndRemainder(dividingBy: rhs.low)
      return (Magnitude(quotient), Magnitude(remainder))
    }

    if rhs.high == (0 as Low) {
      let (x, a) = lhs.high.quotientAndRemainder(dividingBy: rhs.low)
      let (y, b) = a == (0 as Low)
        ? lhs.low.quotientAndRemainder(dividingBy: rhs.low)
        : rhs.low.dividingFullWidth((a, lhs.low))
      return (Magnitude(x, y), Magnitude(0, b))
    }

    // Left shift both rhs and lhs, then divide and right shift the remainder.
    let shift = rhs.leadingZeroBitCount
    // Note the use of `>>` instead of `&>>` below,
    // as `high` should be zero if `shift` is zero.
    let high = (lhs >> (Magnitude.bitWidth &- shift)).low
    let rhs = rhs &<< shift
    let lhs = lhs &<< shift
    let (quotient, remainder) =
      Magnitude._divide((high, lhs.high, lhs.low), by: rhs)
    return (Magnitude(0, quotient), remainder &>> shift)
  }
}

extension DoubleWidth : SignedNumeric, SignedInteger
  where Base : SignedInteger {}
