//===--- BigInt._Significand.swift ----------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension BigInt {
  /// The significand of a `BigInt` value, a nonempty collection of the
  /// significant digits of that value's magnitude stored in words of type
  /// `UInt`.
  ///
  /// The first element of the collection is the lowest word.
  @usableFromInline
  internal typealias _Significand = [UInt]
}

/// Nota bene:
/// While operations implemented on `BigInt` expect inputs that are normalized
/// and produce outputs that are normalized, operations implemented here should
/// tolerate input significands with extraneous leading or trailing zeros and do
/// not need to delete them from their output.
extension BigInt._Significand {
  /// Replaces this significand with its radix complement and returns a Boolean
  /// value indicating whether overflow occurred.
  ///
  /// - Parameter radix: The radix to use in computing the radix complement.
  ///   This method is currently implemented only for radix 2 (i.e., two's
  ///   complement).
  /// - Returns: A Boolean value indicating whether overflow occurred, in which
  ///   case `self` is the partial value (without the overflowing bit).
  @inlinable
  @discardableResult
  internal mutating func complement(radix: Int) -> /* overflow: */ Bool {
    precondition(radix == 2)
    var i = 0
    var overflow = true
    while overflow && i < count {
      self[i]._invert()
      overflow = (self[i] == UInt.max)
      self[i] &+= 1
      i &+= 1
    }
    while i < count {
      self[i]._invert()
      i &+= 1
    }
    return overflow
  }
  
  /// Increments this significand by one.
  @inlinable
  internal mutating func increment() {
    var overflow = true
    for i in 0..<count {
      if overflow {
        overflow = (self[i] == UInt.max)
        self[i] &+= 1
      } else {
        break
      }
    }
    if overflow { append(1) }
  }
  
  /// Decrements this significand by one and returns a Boolean value indicating
  /// whether overflow occurred.
  ///
  /// - Returns: A Boolean value indicating whether overflow occurred (i.e.,
  ///   whether the logical result is less than zero), in which case `self` is
  ///   the partial value (or two's complement representation of the logical
  ///   result).
  @inlinable
  @discardableResult
  internal mutating func decrement() -> /* overflow: */ Bool {
    var overflow = true
    for i in 0..<count {
      if overflow {
        overflow = (self[i] == 0)
        self[i] &-= 1
      } else {
        break
      }
    }
    return overflow
  }
  
  // @inlinable
  internal mutating func add(_ other: Self, exponent: Int = 0) {
    let counts = (count, other.count + exponent)
    var i = exponent
    var overflow = false
    while i < Swift.min(counts.0, counts.1) {
      let temporary = self[i].addingReportingOverflow(other[i &- exponent])
      if overflow {
        overflow = temporary.overflow || (temporary.partialValue == UInt.max)
        self[i] = temporary.partialValue &+ 1
      } else {
        overflow = temporary.overflow
        self[i] = temporary.partialValue
      }
      i &+= 1
    }
    if counts.0 >= counts.1 {
      while i < counts.0 {
        if overflow {
          overflow = (self[i] == UInt.max)
          self[i] &+= 1
        } else {
          break
        }
        i &+= 1
      }
    } else {
      if i > counts.0 {
        assert(i == exponent)
        insert(contentsOf: repeatElement(0, count: i &- counts.0), at: counts.0)
      }
      while overflow && i < counts.1 {
        let temporary = other[i &- exponent]
        overflow = (temporary == UInt.max)
        append(temporary &+ 1)
        i &+= 1
      }
      while i < counts.1 {
        append(other[i &- exponent])
        i &+= 1
      }
    }
    if overflow { append(1) }
  }
  
  // @inlinable
  @discardableResult
  internal mutating func subtract(
    _ other: Self, exponent: Int = 0
  ) -> /* overflow: */ Bool {
    let counts = (count, other.count + exponent)
    var i = exponent
    var overflow = false
    while i < Swift.min(counts.0, counts.1) {
      let temporary = self[i].subtractingReportingOverflow(other[i &- exponent])
      if overflow {
        overflow = temporary.overflow || (temporary.partialValue == 0)
        self[i] = temporary.partialValue &- 1
      } else {
        overflow = temporary.overflow
        self[i] = temporary.partialValue
      }
      i &+= 1
    }
    if counts.0 >= counts.1 {
      while i < counts.0 {
        if overflow {
          overflow = (self[i] == 0)
          self[i] &-= 1
        } else {
          break
        }
        i &+= 1
      }
    } else {
      if i > counts.0 {
        assert(i == exponent)
        insert(contentsOf: repeatElement(0, count: i &- counts.0), at: counts.0)
      }
      while !overflow && i < counts.1 {
        let temporary = other[i &- exponent]
        overflow = (temporary != 0)
        append(0 &- temporary)
        i &+= 1
      }
      while i < counts.1 {
        append(~other[i &- exponent]) // Note that `~x == 0 &- x &- 1`.
        i &+= 1
      }
    }
    return overflow
  }
  
  @inlinable
  internal mutating func multiply(by other: UInt) {
    var carry = 0 as UInt
    for i in 0..<count {
      let temporary = self[i].multipliedFullWidth(by: other)
      let overflow: Bool
      (self[i], overflow) = temporary.low.addingReportingOverflow(carry)
      carry = overflow ? temporary.high + 1 : temporary.high
    }
    if carry != 0 { append(carry) }
  }
  
  // @inlinable
  internal func multiplying(by other: Self) -> Self {
    var result = [0] as Self
    result.reserveCapacity(count + other.count)
    for i in 0..<other.count {
      var temporary = self
      temporary.multiply(by: other[i])
      result.add(temporary, exponent: i)
    }
    return result
  }
  
  // Nota bene: `karatsubaThreshold` is defined in terms of `m`, the count (in
  // words) of the lower half of each operand.
  // @inlinable
  internal func multiplying(by other: Self, karatsubaThreshold: Int) -> Self {
    func add(_ lhs: SubSequence, _ rhs: SubSequence) -> Self {
      // Recall that we have a precondition for `Self<C: Collection>(_: C)` that
      // the argument not be empty.
      if lhs.isEmpty { return rhs.isEmpty ? [0] as Self : Self(rhs) }
      if rhs.isEmpty { return Self(lhs) }
      
      var result = Self(lhs)
      result.add(Self(rhs))
      return result
    }
    
    func multiply(_ lhs: SubSequence, _ rhs: SubSequence) -> Self {
      
      // Based on Karatsuba's method. For details see:
      // <https://mathworld.wolfram.com/KaratsubaMultiplication.html>.
      
      let m = (Swift.max(lhs.count, rhs.count) + 1) / 2
      guard m >= karatsubaThreshold else {
        if lhs.isEmpty || rhs.isEmpty { return [0] as Self }
        return Self(lhs).multiplying(by: Self(rhs))
      }
      
      let (x0, x1) = (lhs.prefix(m), lhs.dropFirst(m))
      let (y0, y1) = (rhs.prefix(m), rhs.dropFirst(m))

      var z0 = multiply(x0, y0)
      let z2 = multiply(x1, y1)
      
      let a = add(x0, x1)
      let b = add(y0, y1)
      var z1 = multiply(a[...], b[...])
      z1.subtract(z2)
      z1.subtract(z0)
      
      z0.reserveCapacity(lhs.count + rhs.count)
      z0.add(z1, exponent: m)
      z0.add(z2, exponent: m * 2)
      return z0
    }
    
    return multiply(self[...], other[...])
  }
  
  @inlinable
  @discardableResult
  internal mutating func divide(by other: UInt) -> /* remainder: */ UInt {
    if other == 1 { return 0 }
    var remainder = 0 as UInt
    for i in (0..<count).reversed() {
      (self[i], remainder) = other.dividingFullWidth((remainder, self[i]))
    }
    return remainder
  }
  
  // @inlinable
  @discardableResult
  internal mutating func divide(by other: Self) -> /* remainder: */ Self {
    func shift(_ lhs: inout Self, leftBy rhs: Int) {
      var carry = 0 as UInt
      guard rhs != 0 else {
        lhs.append(0)
        return
      }
      for i in 0..<lhs.count {
        let temporary = lhs[i]
        lhs[i] = temporary &<< rhs | carry
        carry = temporary &>> (UInt.bitWidth &- rhs)
      }
      lhs.append(carry)
    }
    
    func shift(_ lhs: inout Self, rightBy rhs: Int) {
      var carry = 0 as UInt
      guard rhs != 0 else {
        return
      }
      for i in (0..<lhs.count).reversed() {
        let temporary = lhs[i]
        lhs[i] = temporary &>> rhs | carry
        carry = temporary &<< (UInt.bitWidth &- rhs)
      }
    }
    
    // Based on Knuth's Algorithm D (section 4.3.1). For details see:
    // <https://skanthak.homepage.t-online.de/division.html>.
    
    // We'll remove any extraneous leading zero words while determining by how
    // much to shift our operands.
    var other = other
    var n = other.count
    guard let i = other.lastIndex(where: { $0 != 0 }) else {
      fatalError("Divide by zero")
    }
    if n > i &+ 1 {
      other.removeLast(n &- (i &+ 1))
      n = i &+ 1
    }
    guard n > 1 else { return [divide(by: other[0])] as Self }
    let clz = other[n &- 1].leadingZeroBitCount
    
    var m = count - n
    guard let j = lastIndex(where: { $0 != 0 }) else { return [0] as Self }
    if m > j &+ 1 {
      removeLast(m &- (j &+ 1))
      m = j &+ 1
    }
    precondition(m >= 0)
    
    // 1. Normalize operands.
    shift(&other, leftBy: clz)
    shift(&self, leftBy: clz)
    
    // 2. Initialize loop.
    var result = Self(repeating: 0, count: m &+ 1)
    let right = (high: other[n &- 1], low: other[n &- 2])
    for idx in (n...(n &+ m)).reversed() {
      let left = (high: self[idx], low: self[idx &- 1])
      
      // 3. Calculate trial quotient and remainder.
      var overflow = false
      var (q̂, r̂): (UInt, UInt)
      if right.high > left.high {
        (q̂, r̂) = right.high.dividingFullWidth((left.high, left.low))
      } else {
        (q̂, r̂) = right.high < left.high
          ? right.high.dividingFullWidth((left.high &- right.high, left.low))
          : left.low.quotientAndRemainder(dividingBy: right.high)
        overflow = true
      }
      while overflow
        || q̂.multipliedFullWidth(by: right.low) > (r̂, self[idx &- 2]) {
        q̂ &-= 1
        r̂ &+= right.high
        if r̂ < right.high { break }
        if q̂ == UInt.max { overflow = false }
      }
      
      // 4. Multiply and subtract.
      let slice = self[(idx &- n)...idx]
      var x = Self(slice), y = other
      y.multiply(by: q̂)
      overflow = x.subtract(y)
      
      // 5. Test remainder.
      if overflow {
        // 6. Add back.
        q̂ -= 1
        x.add(y)
      }
      
      replaceSubrange((idx &- n)...idx, with: x[0...n])
      result[idx &- n] = q̂
    } // 7. Loop.
    
    // 8. Unnormalize.
    removeLast(m &+ 1)
    shift(&self, rightBy: clz)
    
    swap(&self, &result)
    return result
  }
}
