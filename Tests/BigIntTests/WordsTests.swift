//===--- WordsTests.swift -------------------------------------*- swift -*-===//
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
@testable import BigIntModule

private typealias Word = UInt
private let mostSignificantBitMask = Word(1) << (Word.bitWidth - 1)

private func assertWords(_ value: BigInt,
                         _ expected: [UInt],
                         file: StaticString = #file,
                         line: UInt = #line) {
  let words = Array(value.words)
  XCTAssertEqual(words.count, expected.count, "[\(value)] Count", file: file, line: line)
  XCTAssertEqual(words, expected, "[\(value)] Words", file: file, line: line)

  var recreated: BigInt

  if value >= 0 {
    recreated = BigIntPrototype.create(isPositive: true, magnitude: words)
  } else {
    // 2 complement
    let invertedWords = words.map { ~$0 }
    recreated = BigIntPrototype.create(isPositive: true, magnitude: invertedWords)
    recreated += 1
    recreated *= -1
  }

  XCTAssertEqual(value, recreated, "[\(value)] Recreated value", file: file, line: line)
}

class WordsTests: XCTestCase {

  // MARK: - Zero

  func test_zero() {
    let value = BigInt(0)
    assertWords(value, [0])
  }

  // MARK: - Int

  func test_int() {
    let int = -1
    let big = BigInt(int)
    let expected = Array(int.words)
    assertWords(big, expected)

    for int in generateInts(approximateCount: 100) {
      let big = BigInt(int)
      let expected = Array(int.words)
      assertWords(big, expected)
    }
  }

  // MARK: - Multiple words

  // 0001 0000
  // 0010 0000
  // etc...
  func test_multipleWords_positive() {
    for zeroWordCount in [1, 2] {
      let zeroWords = [Word](repeating: 0, count: zeroWordCount)

      for (_, value) in PositivePowersOf2(type: Word.self) {
        let words = zeroWords + [value]
        let big = self.create(isPositive: true, magnitudeWords: words)

        let needsSignWord = (value & mostSignificantBitMask) == mostSignificantBitMask
        let expectedWords = needsSignWord ? (words + [0]) : words
        assertWords(big, expectedWords)
      }
    }
  }

  // words:      1000 0000
  // invert:     0111 1111
  // complement: 1000 0000
  func test_multipleWords_negative_powerOf2() {
    for zeroWordCount in [1, 2] {
      let zeroWords = [Word](repeating: 0, count: zeroWordCount)

      for (_, value) in PositivePowersOf2(type: Word.self) {
        let words = zeroWords + [value]
        let big = self.create(isPositive: false, magnitudeWords: words)

        let valueCompliment = ~value + 1
        let expectedWords = zeroWords + [valueCompliment]
        assertWords(big, expectedWords)
      }
    }
  }

  // case 1: most common
  // words:      0100 0001
  // invert:     1011 1110
  // complement: 1011 1111
  //
  // case 2: needs sign word
  // words:           1000 0001
  // invert:          0111 1110
  // complement: 1111 0111 1111
  func test_multipleWords_negative_notPowerOf2() {
    for additionalWordCount in [1, 2] {
      // We are not the power of '2', we will set the lowest bit to 1.
      var additionalWords = [Word](repeating: 0, count: additionalWordCount)
      additionalWords[0] = 1

      let all1 = Word.max
      let leastSignificantWords = [Word](repeating: all1, count: additionalWordCount)

      for (_, value) in PositivePowersOf2(type: Word.self) {
        let words = additionalWords + [value]
        let big = self.create(isPositive: false, magnitudeWords: words)

        let needsSignWord = (value & mostSignificantBitMask) == mostSignificantBitMask
        let signWord = needsSignWord ? [all1] : []
        let expectedWords = leastSignificantWords + [~value] + signWord

        assertWords(big, expectedWords)
      }
    }
  }

  // MARK: - Helpers

  private func create(isPositive: Bool, magnitudeWords: [Word]) -> BigInt {
    return BigIntPrototype.create(isPositive: isPositive, magnitude: magnitudeWords)
  }
}
