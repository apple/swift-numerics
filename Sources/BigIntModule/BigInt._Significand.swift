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

#if true
extension BigInt {
  /// The significand of a `BigInt` value, a nonempty collection of the
  /// significant digits of that value's magnitude stored in words of type
  /// `UInt`.
  ///
  /// The first element of the collection is the lowest word.
  @usableFromInline
  internal typealias _Significand = [UInt]
}

extension BigInt._Significand {
  /// Creates a new significand with the given words.
  @inlinable
  internal init(_ low: UInt, _ rest: [UInt] = []) {
    self = [low]
    reserveCapacity(rest.count + 1)
    insert(contentsOf: rest, at: 1)
  }
}
#else
extension BigInt {
  /// The significand of a `BigInt` value, a nonempty collection of the
  /// significant digits of that value's magnitude stored in words of type
  /// `UInt`.
  ///
  /// The first element of the collection is the lowest word.
  @frozen
  @usableFromInline
  internal struct _Significand {
    /// The low word of this significand.
    @usableFromInline
    internal var _low: UInt
    
    /// The rest of the words of this significand, from second lowest to
    /// highest.
    @usableFromInline
    internal var _rest: [UInt]

    /// Creates a new significand with the given words.
    @inlinable
    internal init(_ low: UInt, _ rest: [UInt] = []) {
      _low = low
      _rest = rest
    }
  }
}

extension BigInt._Significand: RandomAccessCollection, MutableCollection {
  @inlinable
  internal var count: Int { _rest.count + 1 }
  
  @inlinable
  internal var startIndex: Int { 0 }
  
  @inlinable
  internal var endIndex: Int { count }
  
  @inlinable
  internal func index(before i: Int) -> Int { i - 1 }
  
  @inlinable
  internal func index(after i: Int) -> Int { i + 1 }
  
  @inlinable
  internal subscript(position: Int) -> UInt {
    _read {
      if position == 0 {
        yield _low
      } else {
        yield _rest[position - 1]
      }
    }
    _modify {
      if position == 0 {
        yield &_low
      } else {
        yield &_rest[position - 1]
      }
    }
  }
}

/// `BigInt._Significand` can never be empty, so it cannot conform to
/// `RangeReplaceableCollection`; however, we will implement some of its
/// requirements here.
///
/// Documentation is transposed from the corresponding methods on
/// `RangeReplaceableCollection` in the standard library, with changes noted in
/// **bold**.
extension BigInt._Significand {
  /// Replaces the specified subrange of elements with the given collection.
  ///
  /// This method has the effect of removing the specified range of elements
  /// from the collection and inserting the new elements at the same location.
  /// The number of new elements need not match the number of elements being
  /// removed.
  ///
  /// If you pass a zero-length range as the `subrange` parameter, this method
  /// inserts the elements of `newElements` at `subrange.startIndex`. Calling
  /// the `insert(contentsOf:at:)` method instead is preferred.
  ///
  /// Likewise, if you pass a zero-length collection as the `newElements`
  /// parameter, this method removes the elements in the given subrange
  /// without replacement. Calling the `removeSubrange(_:)` method instead is
  /// preferred.
  ///
  /// Calling this method may invalidate any existing indices for use with this
  /// collection.
  ///
  /// - Parameters:
  ///   - subrange: The subrange of the collection to replace. The bounds of
  ///     the range must be valid indices of the collection. **If `newElements`
  ///     is empty, then the range must not be equivalent to the full unbounded
  ///     range of indices of the collection.**
  ///   - newElements: The new elements to add to the collection.
  @inlinable
  internal mutating func replaceSubrange<C: Collection>(
    _ subrange: Range<Int>, with newElements: __owned C
  ) where C.Element == UInt {
    guard !newElements.isEmpty else {
      removeSubrange(subrange)
      return
    }
    switch (subrange.lowerBound, subrange.upperBound) {
    case (0, 0):
      _rest.insert(_low, at: 0)
      _low = newElements.first!
      _rest.insert(contentsOf: newElements.dropFirst(), at: 0)
    case (0, let upperBound):
      _low = newElements.first!
      _rest.replaceSubrange(0..<(upperBound - 1), with: newElements.dropFirst())
    case (let lowerBound, let upperBound):
      _rest.replaceSubrange(
        (lowerBound - 1)..<(upperBound - 1), with: newElements)
    }
  }
  
  /// Prepares the collection to store the specified number of elements, when
  /// doing so is appropriate for the underlying type.
  ///
  /// If you are adding a known number of elements to a collection, use this
  /// method to avoid multiple reallocations.
  ///
  /// - Parameter n: The requested number of elements to store.
  @inlinable
  internal mutating func reserveCapacity(_ n: Int) {
    if n > 0 { _rest.reserveCapacity(n &- 1) }
  }
  
  /// Creates a new collection containing the specified number of a single,
  /// repeated value.
  ///
  /// - Parameters:
  ///   - repeatedValue: The element to repeat.
  ///   - count: The number of times to repeat the value passed in the
  ///     `repeating` parameter. `count` must be **one** or greater.
  @inlinable
  internal init(repeating repeatedValue: UInt, count: Int) {
    _low = repeatedValue
    _rest = [UInt](repeating: repeatedValue, count: count - 1)
  }
  
  /// Creates a new instance of a collection containing the elements of a
  /// **nonempty collection**.
  ///
  /// Users expect `Self(collection).count == collection.count`, but we cannot
  /// create an empty collection of type `BigInt._Significand`.
  ///
  /// - Parameter elements: The **collection** of elements for the new
  ///   collection. `elements` must be **nonempty**.
  @inlinable
  internal init<C: Collection>(_ elements: C) where C.Element == UInt {
    _low = elements.first!
    _rest = [UInt](elements.dropFirst())
  }
  
  /// Creates a new instance of a collection containing the elements of a
  /// **nonempty slice**.
  ///
  /// Users expect `Self(slice).count == slice.count`, but we cannot create an
  /// empty collection of type `BigInt._Significand`.
  ///
  /// - Parameter elements: The **slice** containing elements for the new
  ///   collection. `elements` must be **nonempty**.
  @inlinable
  internal init(_ elements: Slice<Self>) {
    if elements.startIndex == elements.base.startIndex
      && elements.endIndex == elements.base.endIndex {
      self = elements.base
    } else {
      _low = elements.first!
      _rest = [UInt](elements.dropFirst())
    }
  }
  
  /// Adds an element to the end of the collection.
  ///
  /// If the collection does not have sufficient capacity for another element,
  /// additional storage is allocated before appending `newElement`.
  ///
  /// - Parameter newElement: The element to append to the collection.
  @inlinable
  internal mutating func append(_ newElement: __owned UInt) {
    _rest.append(newElement)
  }
  
  /// Adds the elements of a sequence or collection to the end of this
  /// collection.
  ///
  /// The collection being appended to allocates any additional necessary
  /// storage to hold the new elements.
  ///
  /// - Parameter newElements: The elements to append to the collection.
  @inlinable
  internal mutating func append<S: Sequence>(
    contentsOf newElements: __owned S
  ) where S.Element == UInt {
    _rest.append(contentsOf: newElements)
  }
  
  /// Inserts a new element into the collection at the specified position.
  ///
  /// The new element is inserted before the element currently at the
  /// specified index. If you pass the collection's `endIndex` property as
  /// the `index` parameter, the new element is appended to the
  /// collection.
  ///
  /// Calling this method may invalidate any existing indices for use with this
  /// collection.
  ///
  /// - Parameter newElement: The new element to insert into the collection.
  /// - Parameter i: The position at which to insert the new element.
  ///   `index` must be a valid index into the collection.
  @inlinable
  internal mutating func insert(_ newElement: __owned UInt, at i: Int) {
    if i != 0 {
      _rest.insert(newElement, at: i - 1)
    } else {
      _rest.insert(_low, at: 0)
      _low = newElement
    }
  }
  
  /// Inserts the elements of a sequence into the collection at the specified
  /// position.
  ///
  /// The new elements are inserted before the element currently at the
  /// specified index. If you pass the collection's `endIndex` property as the
  /// `index` parameter, the new elements are appended to the collection.
  ///
  /// Calling this method may invalidate any existing indices for use with this
  /// collection.
  ///
  /// - Parameter newElements: The new elements to insert into the collection.
  /// - Parameter i: The position at which to insert the new elements. `index`
  ///   must be a valid index of the collection.
  @inlinable
  internal mutating func insert<C: Collection>(
    contentsOf newElements: __owned C, at i: Int
  ) where C.Element == UInt {
    if i != 0 {
      _rest.insert(contentsOf: newElements, at: i - 1)
    } else if !newElements.isEmpty {
      _rest.insert(_low, at: 0)
      _low = newElements.first!
      _rest.insert(contentsOf: newElements.dropFirst(), at: 0)
    }
  }
  
  /// Removes and returns the element at the specified position.
  ///
  /// **The collection must have more than one element.**
  ///
  /// All the elements following the specified position are moved to close the
  /// gap.
  ///
  /// Calling this method may invalidate any existing indices for use with this
  /// collection.
  ///
  /// - Parameter i: The position of the element to remove. `i` must be a valid
  ///   index of the collection that is not equal to the collection's end index.
  /// - Returns: The removed element.
  @inlinable
  @discardableResult
  internal mutating func remove(at i: Int) -> UInt {
    return i == 0 ? removeFirst() : _rest.remove(at: i - 1)
  }
  
  /// Removes and returns the first element of the collection.
  ///
  /// The collection must **have more than one element**.
  ///
  /// Calling this method may invalidate any existing indices for use with this
  /// collection.
  ///
  /// - Returns: The removed element.
  @inlinable
  @discardableResult
  internal mutating func removeFirst() -> UInt {
    let temporary = _low
    _low = _rest.removeFirst()
    return temporary
  }
  
  /// Removes the specified number of elements from the beginning of the
  /// collection.
  ///
  /// Calling this method may invalidate any existing indices for use with this
  /// collection.
  ///
  /// - Parameter k: The number of elements to remove from the collection.
  ///   `k` must be greater than or equal to zero and must not exceed **or
  ///   equal** the number of elements in the collection.
  @inlinable
  internal mutating func removeFirst(_ k: Int) {
    if k == 0 {
      return
    } else if k == 1 {
      _low = _rest.removeFirst()
    } else {
      _low = _rest[k - 1]
      _rest.removeFirst(k)
    }
  }
  
  /// Removes and returns the last element of the collection.
  ///
  /// The collection must **have more than one element**.
  ///
  /// Calling this method may invalidate any existing indices for use with this
  /// collection.
  ///
  /// - Returns: The last element of the collection.
  @inlinable
  @discardableResult
  internal mutating func removeLast() -> UInt {
    return _rest.removeLast()
  }
  
  /// Removes the specified number of elements from the end of the collection.
  ///
  /// Calling this method may invalidate any existing indices for use with this
  /// collection.
  ///
  /// - Parameter k: The number of elements to remove from the collection.
  ///   `k` must be greater than or equal to zero and must not exceed **or
  ///   equal** the number of elements in the collection.
  @inlinable
  internal mutating func removeLast(_ k: Int) {
    _rest.removeLast(k)
  }
  
  /// Removes the specified subrange of elements from the collection.
  ///
  /// Calling this method may invalidate any existing indices for use with this
  /// collection.
  ///
  /// - Parameter bounds: The subrange of the collection to remove. The bounds
  ///   of the range must be valid indices of the collection **and the range
  ///   must not be equivalent to the full unbounded range of indices of the
  ///   collection**.
  @inlinable
  internal mutating func removeSubrange(_ bounds: Range<Int>) {
    let (lowerBound, upperBound) = (bounds.lowerBound, bounds.upperBound)
    if lowerBound == 0 {
      removeFirst(upperBound)
    } else {
      _rest.removeSubrange((lowerBound - 1)..<(upperBound - 1))
    }
  }
  
  /// Removes the specified subrange of elements from the collection.
  ///
  /// Calling this method may invalidate any existing indices for use with this
  /// collection.
  ///
  /// - Parameter bounds: The subrange of the collection to remove. The bounds
  ///   of the range must be valid indices of the collection **and the range
  ///   must not be equivalent to the full unbounded range of indices of the
  ///   collection**.
  @inlinable
  internal mutating func removeSubrange<R: RangeExpression>(
    _ bounds: R
  ) where R.Bound == Int {
    removeSubrange(bounds.relative(to: self))
  }
  
  /// Replaces the specified subrange of elements with the given collection.
  ///
  /// This method has the effect of removing the specified range of elements
  /// from the collection and inserting the new elements at the same location.
  /// The number of new elements need not match the number of elements being
  /// removed.
  ///
  /// If you pass a zero-length range as the `subrange` parameter, this method
  /// inserts the elements of `newElements` at `subrange.startIndex`. Calling
  /// the `insert(contentsOf:at:)` method instead is preferred.
  ///
  /// Likewise, if you pass a zero-length collection as the `newElements`
  /// parameter, this method removes the elements in the given subrange
  /// without replacement. Calling the `removeSubrange(_:)` method instead is
  /// preferred.
  ///
  /// Calling this method may invalidate any existing indices for use with this
  /// collection.
  ///
  /// - Parameters:
  ///   - subrange: The subrange of the collection to replace. The bounds of
  ///     the range must be valid indices of the collection. **If `newElements`
  ///     is empty, then the range must not be equivalent to the full unbounded
  ///     range of indices of the collection.**
  ///   - newElements: The new elements to add to the collection.
  @inlinable
  internal mutating func replaceSubrange<C: Collection, R: RangeExpression>(
    _ subrange: R, with newElements: __owned C
  ) where C.Element == UInt, R.Bound == Int {
    replaceSubrange(subrange.relative(to: self), with: newElements)
  }
}

extension BigInt._Significand: Hashable { }
#endif

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
    var result = Self(0)
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
      if lhs.isEmpty { return rhs.isEmpty ? Self(0) : Self(rhs) }
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
        if lhs.isEmpty || rhs.isEmpty { return Self(0) }
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
  internal mutating func divide(by other: UInt) -> /* remainder: */ Self {
    if other == 1 { return Self(0) }
    var remainder = 0 as UInt
    for i in (0..<count).reversed() {
      (self[i], remainder) = other.dividingFullWidth((remainder, self[i]))
    }
    return Self(remainder)
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
    guard n > 1 else { return divide(by: other[0]) }
    let clz = other[n &- 1].leadingZeroBitCount
    
    var m = count - n
    guard let j = lastIndex(where: { $0 != 0 }) else { return Self(0) }
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
      while overflow || q̂.multipliedFullWidth(by: right.low) > (r̂, left.low) {
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
