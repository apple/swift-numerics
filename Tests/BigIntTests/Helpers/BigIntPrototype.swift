//===--- BigIntPrototype.swift --------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import BigIntModule

// MARK: - BigIntPrototype

/// Abstract way of representing `BigInt` without assuming internal representation.
/// Basically an immutable `Word` collection with a sign.
///
/// It can be used to create multiple independent `BigInt` instances with
/// the same value (used during equality tests etc).
internal struct BigIntPrototype {

  internal typealias Word = UInt64

  internal enum Sign {
    case positive
    case negative
  }

  /// Internally `Int1`.
  internal let sign: Sign
  /// Least significant word is at index `0`.
  /// Empty means `0`.
  internal let magnitude: [Word]

  internal var isPositive: Bool {
    return self.sign == .positive
  }

  internal var isNegative: Bool {
    return self.sign == .negative
  }

  internal var isZero: Bool {
    return self.magnitude.isEmpty
  }

  /// Is `magnitude == 1`?` It may be `+1` or `-1` depending on the `self.sign`.
  internal var isMagnitude1: Bool {
    return self.magnitude.count == 1 && self.magnitude[0] == 1
  }

  internal init(_ sign: Sign, magnitude: Word) {
    self.init(sign, magnitude: [magnitude])
  }

  internal init(_ sign: Sign, magnitude: [Word]) {
    self.sign = sign
    self.magnitude = magnitude

    let isZero = self.magnitude.isEmpty
    let zeroHasPositiveSign = !isZero || sign == .positive
    assert(zeroHasPositiveSign, "[BigIntPrototype] Negative zero")
  }

  internal init(isPositive: Bool, magnitude: [Word]) {
    let sign: Sign = isPositive ? .positive : .negative
    self.init(sign, magnitude: magnitude)
  }

  /// `BigInt` -> `BigIntPrototype`.
  @available(
    *,
    deprecated,
    message: "Use only when writing test cases to convert BigInt -> Prototype."
  )
  internal init(_ big: BigInt) {
    var n = abs(big)

    let power = BigInt(Word.max) + 1
    var magnitude = [Word]()

    while n != 0 {
      let rem = n % power
      magnitude.append(Word(rem))
      n /= power
    }

    let sign = big < 0 ? Sign.negative : Sign.positive
    self = BigIntPrototype(sign, magnitude: magnitude)
  }

  internal var withOppositeSign: BigIntPrototype {
    assert(!self.isZero, "[BigIntPrototype] Negative zero: (0).withOppositeSign")
    return BigIntPrototype(isPositive: !self.isPositive, magnitude: self.magnitude)
  }

  internal func withAddedWord(word: Word) -> BigIntPrototype {
    var magnitude = self.magnitude
    magnitude.append(word)
    return BigIntPrototype(isPositive: self.isPositive, magnitude: magnitude)
  }

  internal var withRemovedWord: BigIntPrototype {
    assert(!self.isZero, "[BigIntPrototype] Removing word from zero")

    var magnitude = self.magnitude
    magnitude.removeLast()

    // Removing word may have made the whole value '0', which could change sign!
    let isZero = magnitude.isEmpty
    let isPositive = self.isPositive || isZero
    return BigIntPrototype(isPositive: isPositive, magnitude: magnitude)
  }

  /// Collection where each element is a `BigIntPrototype` with one of the words
  /// modified by provided `wordChange`.
  ///
  /// Used to easily create prototypes with smaller/bigger magnitude.
  /// Useful for testing `==`, `<`, `>`, `<=` and `>=`.
  internal func withEachMagnitudeWordModified(
    byAdding wordChange: Int
  ) -> WithEachMagnitudeWordModified {
    return WithEachMagnitudeWordModified(base: self, by: wordChange)
  }

  internal func create() -> BigInt {
    return BigIntPrototype.create(isPositive: self.isPositive, magnitude: self.magnitude)
  }

  internal static func create<T: FixedWidthInteger>(
    isPositive: Bool,
    magnitude: [T]
  ) -> BigInt {
    assert(!T.isSigned)
    var result = BigInt()
    var power = BigInt(1)

    for word in magnitude {
      // As for the magic '+1' in power:
      // Without it (example for UInt8):
      //   [255]  -> 255*1         = 255
      //   [0, 1] -> 0  *1 + 1*255 = 255
      //   So, we have 2 ways of representing '255' (aka. T.max)
      // With it:
      //   [255]  -> 255*1             = 255
      //   [0, 1] -> 0  *1 + 1*(255+1) = 256
      result += BigInt(word) * power
      power *= BigInt(T.max) + 1
    }

    if !isPositive {
      result *= -1
    }

    return result
  }

  internal enum CompareResult {
    case equal
    case less
    case greater
  }

  internal static func compare(_ lhs: BigIntPrototype,
                               _ rhs: BigIntPrototype) -> CompareResult {
    let lhsM = lhs.magnitude
    let rhsM = rhs.magnitude

    guard lhsM.count == rhsM.count else {
      return lhsM.count > rhsM.count ? .greater : .less
    }

    for (l, r) in zip(lhsM, rhsM).reversed() {
      if l > r {
        return .greater
      }

      if l < r {
        return .less
      }
    }

    return .equal
  }
}

// MARK: - Modify magnitude words

internal struct WithEachMagnitudeWordModified: Sequence {

  internal typealias Element = BigIntPrototype

  internal struct Iterator: IteratorProtocol {

    private let base: BigIntPrototype
    private let wordChange: Int
    private var wordIndex = 0

    internal init(base: BigIntPrototype, wordChange: Int) {
      self.base = base
      self.wordChange = wordChange
    }

    internal mutating func next() -> Element? {
      var magnitude = self.base.magnitude
      let wordChangeMagnitude = BigIntPrototype.Word(self.wordChange.magnitude)

      while self.wordIndex < magnitude.count {
        let word = magnitude[self.wordIndex]
        defer { self.wordIndex += 1 }

        let (newWord, hasOverflow) = self.wordChange >= 0 ?
          word.addingReportingOverflow(wordChangeMagnitude) :
          word.subtractingReportingOverflow(wordChangeMagnitude)

        if !hasOverflow {
          magnitude[self.wordIndex] = newWord
          let isPositive = self.base.isPositive
          return BigIntPrototype(isPositive: isPositive, magnitude: magnitude)
        }
      }

      return nil
    }
  }

  private let base: BigIntPrototype
  private let wordChange: Int

  internal init(base: BigIntPrototype, by wordChange: Int) {
    self.base = base
    self.wordChange = wordChange
  }

  internal func makeIterator() -> Iterator {
    return Iterator(base: self.base, wordChange: self.wordChange)
  }
}

// MARK: - Tests

/// Tests for `BigIntPrototype`.
/// Yep… we are testing our test code…
class BigIntPrototypeTests: XCTestCase {

  func test_create() {
    let p1 = BigIntPrototype(.positive, magnitude: [.max])
    let big1 = p1.create()
    let expected1 = BigInt(BigIntPrototype.Word.max)
    XCTAssertEqual(big1, expected1)

    let p2 = BigIntPrototype(.positive, magnitude: [0, 1])
    let big2 = p2.create()
    let expected2 = BigInt(BigIntPrototype.Word.max) + 1
    XCTAssertEqual(big2, expected2)
  }

  func test_magnitudeWordModified_positive() {
    let p = BigIntPrototype(.positive, magnitude: [3, .max, 5])
    let modified = p.withEachMagnitudeWordModified(byAdding: 7)
    var iter = modified.makeIterator()

    let p1 = iter.next()
    XCTAssertEqual(p1?.magnitude, [10, .max, 5])

    // '.max' should be skipped, because it overflows

    let p2 = iter.next()
    XCTAssertEqual(p2?.magnitude, [3, .max, 12])

    let p3 = iter.next()
    XCTAssertNil(p3)
  }

  func test_magnitudeWordModified_negative() {
    let p = BigIntPrototype(.positive, magnitude: [7, 3, 11])
    let modified = p.withEachMagnitudeWordModified(byAdding: -5)
    var iter = modified.makeIterator()

    let p1 = iter.next()
    XCTAssertEqual(p1?.magnitude, [2, 3, 11])

    // '3' should be skipped, because it overflows

    let p2 = iter.next()
    XCTAssertEqual(p2?.magnitude, [7, 3, 6])

    let p3 = iter.next()
    XCTAssertNil(p3)
  }
}
