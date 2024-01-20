//===--- InitFromStringTests.swift ----------------------------*- swift -*-===//
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

// swiftlint:disable line_length
// swiftlint:disable function_body_length
// swiftlint:disable file_length

private typealias TestSuite = StringTestCases.TestSuite
private typealias TestCase = StringTestCases.TestCase
private typealias BinaryTestCases = StringTestCases.Binary
private typealias QuinaryTestCases = StringTestCases.Quinary
private typealias OctalTestCases = StringTestCases.Octal
private typealias DecimalTestCases = StringTestCases.Decimal
private typealias HexTestCases = StringTestCases.Hex

class InitFromStringTests: XCTestCase {

  // MARK: - Empty

  func test_empty_fails() {
    for radix in [2, 4, 7, 32] {
      let n = self.create(string: "", radix: radix)
      XCTAssertNil(n, "Got: \(String(describing: n)), radix: \(radix)")
    }
  }

  func test_onlySign_withoutDigits_plus_fails() {
    for radix in [2, 4, 7, 32] {
      let n = self.create(string: "+", radix: radix)
      XCTAssertNil(n, "Got: \(String(describing: n)), radix: \(radix)")
    }
  }

  func test_onlySign_withoutDigits_minus_fails() {
    for radix in [2, 4, 7, 32] {
      let n = self.create(string: "-", radix: radix)
      XCTAssertNil(n, "Got: \(String(describing: n)), radix: \(radix)")
    }
  }

  // MARK: - Zero

  func test_zero_single() {
    let zero = BigInt()

    for radix in [2, 4, 7, 32] {
      let n = self.create(string: "0", radix: radix)
      XCTAssertEqual(n, zero, "Radix: \(radix)")
    }
  }

  func test_zero_single_plus() {
    let zero = BigInt()

    for radix in [2, 4, 7, 32] {
      let n = self.create(string: "+0", radix: radix)
      XCTAssertEqual(n, zero, "Radix: \(radix)")
    }
  }

  func test_zero_single_minus() {
    let zero = BigInt()

    for radix in [2, 4, 7, 32] {
      let n = self.create(string: "-0", radix: radix)
      XCTAssertEqual(n, zero, "Radix: \(radix)")
    }
  }

  func test_zero_multiple() {
    let zero = BigInt()

    for count in [42, 1_000] {
      let plusString = String(repeating: "0", count: count)
      let minusString = "-" + plusString

      for radix in [2, 4, 7, 32] {
        let plus = self.create(string: plusString, radix: radix)
        XCTAssertEqual(plus, zero, "Count: \(count), radix: \(radix)")

        let minus = self.create(string: minusString, radix: radix)
        XCTAssertEqual(minus, zero, "Count: \(count), radix: \(radix)")
      }
    }
  }

  // MARK: - Int -> String -> BigInt

  func test_int_toString_toBigInt_binary() {
    self.int_toString_toBigInt(radix: 2)
  }

  func test_int_toString_toBigInt_decimal() {
    self.int_toString_toBigInt(radix: 10)
  }

  func test_int_toString_toBigInt_hex() {
    self.int_toString_toBigInt(radix: 16)
  }

  func int_toString_toBigInt(radix: Int,
                             file: StaticString = #file,
                             line: UInt = #line) {
    for int in generateInts(approximateCount: 100) {
      let expected = BigInt(int)

      let lowercase = String(int, radix: radix, uppercase: false)
      let lowercaseResult = self.create(string: lowercase, radix: radix)
      XCTAssertEqual(lowercaseResult,
                     expected,
                     "\(int), lowercase",
                     file: file,
                     line: line)

      let uppercase = String(int, radix: radix, uppercase: true)
      let uppercaseResult = self.create(string: uppercase, radix: radix)
      XCTAssertEqual(uppercaseResult,
                     expected,
                     "\(int), uppercase",
                     file: file,
                     line: line)
    }
  }

  // MARK: - Binary

  func test_binary_singleWord() {
    self.run(suite: BinaryTestCases.singleWord)
  }

  func test_binary_twoWords() {
    self.run(suite: BinaryTestCases.twoWords)
  }

  // MARK: - Quinary

  func test_quinary_singleWord() {
    self.run(suite: QuinaryTestCases.singleWord)
  }

  func test_quinary_twoWords() {
    self.run(suite: QuinaryTestCases.twoWords)
  }

  // MARK: - Octal

  func test_octal_singleWord() {
    self.run(suite: OctalTestCases.singleWord)
  }

  func test_octal_twoWords() {
    self.run(suite: OctalTestCases.twoWords)
  }

  func test_octal_threeWords() {
    self.run(suite: OctalTestCases.threeWords)
  }

  // MARK: - Decimal

  func test_decimal_singleWord() {
    self.run(suite: DecimalTestCases.singleWord)
  }

  func test_decimal_twoWords() {
    self.run(suite: DecimalTestCases.twoWords)
  }

  func test_decimal_threeWords() {
    self.run(suite: DecimalTestCases.threeWords)
  }

  func test_decimal_fourWords() {
    self.run(suite: DecimalTestCases.fourWords)
  }

  // MARK: - Hex

  func test_hex_singleWord() {
    self.run(suite: HexTestCases.singleWord)
  }

  func test_hex_twoWords() {
    self.run(suite: HexTestCases.twoWords)
  }

  func test_hex_threeWords() {
    self.run(suite: HexTestCases.threeWords)
  }

  // MARK: - Underscore

  func test_underscore_binary_fails() {
    self.runUnderscore(suite: BinaryTestCases.twoWords)
  }

  func test_underscore_decimal_fails() {
    self.runUnderscore(suite: DecimalTestCases.twoWords)
  }

  private func runUnderscore(suite: TestSuite,
                             file: StaticString = #file,
                             line: UInt = #line) {
    for testCase in suite.cases {
      let s = testCase.stringWithUnderscores
      let n = self.create(string: s, radix: suite.radix)
      XCTAssertNil(n, s, file: file, line: line)
    }
  }

  func test_underscore_prefix_withoutSign_fails() {
    for radix in [2, 4, 7, 32] {
      let n = self.create(string: "_0101", radix: radix)
      XCTAssertNil(n, "Got: \(String(describing: n)), radix: \(radix)")
    }
  }

  func test_underscore_before_plusSign_fails() {
    for radix in [2, 4, 7, 32] {
      let n = self.create(string: "_+0101", radix: radix)
      XCTAssertNil(n, "Got: \(String(describing: n)), radix: \(radix)")
    }
  }

  func test_underscore_before_minusSign_fails() {
    for radix in [2, 4, 7, 32] {
      let n = self.create(string: "_+0101", radix: radix)
      XCTAssertNil(n, "Got: \(String(describing: n)), radix: \(radix)")
    }
  }

  func test_underscore_after_plusSign_fails() {
    for radix in [2, 4, 7, 32] {
      let n = self.create(string: "+_0101", radix: radix)
      XCTAssertNil(n, "Got: \(String(describing: n)), radix: \(radix)")
    }
  }

  func test_underscore_after_minusSign_fails() {
    for radix in [2, 4, 7, 32] {
      let n = self.create(string: "-_0101", radix: radix)
      XCTAssertNil(n, "Got: \(String(describing: n)), radix: \(radix)")
    }
  }

  func test_underscore_suffix_fails() {
    for radix in [2, 4, 7, 32] {
      let n = self.create(string: "0101_", radix: radix)
      XCTAssertNil(n, "Got: \(String(describing: n)), radix: \(radix)")
    }
  }

  func test_underscore_double_fails() {
    for radix in [2, 4, 7, 32] {
      let n = self.create(string: "01__01", radix: radix)
      XCTAssertNil(n, "Got: \(String(describing: n)), radix: \(radix)")
    }
  }

  // MARK: - Invalid digit

  func test_invalidDigit_biggerThanRadix_fails() {
    let cases: [(Int, UnicodeScalar)] = [
      (2, "2"),
      (4, "4"),
      (7, "7"),
      (10, "a"),
      (16, "g")
    ]

    for (radix, biggerThanRadix) in cases {
      let n = self.create(string: "01\(biggerThanRadix)01", radix: radix)
      XCTAssertNil(n, "Got: \(String(describing: n)), radix: \(radix)")
    }
  }

  // MARK: - Unicode

  // From String.init(cString:) docs:
  //   A pointer to a null-terminated UTF-8 code sequence.
  //   If cString contains ill-formed UTF-8 code unit sequences, this initializer
  //   replaces them with the Unicode replacement character ("\u{FFFD}").
  //
  // One could say that we are testing String instead of BigInt, but the semantic
  // we are going for is:
  //   Given an invalid UTF-8 string BigInt.init will NOT produce a result.
  //
  // https://en.wikipedia.org/wiki/UTF-8#Encoding
  func test_unicode_broken_UTF8_fails() {
    let inputs: [[UInt8]] = [
      // 2 bytes
      [0b1100_0000], // No 2nd byte
      [0b1100_0011, 0b0010_1000], // 2nd byte should start with 10
      // 3 bytes
      [0b1110_0010], // No 2nd/3rd byte
      [0b1110_0010, 0b1000_0000], // No 3rd byte
      [0b1110_0010, 0b0010_1000, 0b1010_0001], // 2nd byte should start with 10
      [0b1110_0010, 0b1000_0010, 0b0010_1000], // 3rd byte should start with 10
      // 4 bytes
      [0b1111_0010], // No 2nd/3rd/4th byte
      [0b1111_0010, 0b1000_0010], // No 3rd/4th byte
      [0b1111_0010, 0b1000_0010, 0b1000_0010], // No 4th byte
      [0b1111_0000, 0b0010_1000, 0b1000_1100, 0b1011_1100], // 2nd byte should start with 10
      [0b1111_0000, 0b1001_0000, 0b0010_1000, 0b1011_1100], // 3rd byte should start with 10
      [0b1111_0000, 0b0010_1000, 0b1000_1100, 0b0010_1000] // 4th byte should start with 10
    ]

    var strings = [String]()

    for bytes in inputs {
      let count = bytes.count + 1 // +1 for NULL
      let ptr = UnsafeMutablePointer<UInt8>.allocate(capacity: count)
      let bufferPtr = UnsafeMutableBufferPointer(start: ptr, count: count)

      var (bytesEnd, bufferEnd) = bufferPtr.initialize(from: bytes)
      assert(bytesEnd.next() == nil, "Buffer too smol?")
      assert(bufferEnd == bytes.count, "No space for NULL?")
      ptr[bufferEnd] = 0

      let s = String(cString: ptr) // Borrows 'ptr' to create owned copy.
      ptr.deallocate()

      strings.append(s)
      strings.append("123" + s)
      strings.append("12" + s + "3")
      strings.append(s + "123")
    }

    for string in strings {
      let bytes = string.utf8CString

      for radix in [2, 4, 8, 10, 16, 32] {
        let n = self.create(string: string, radix: radix)
        XCTAssertNil(n, "\(bytes) (radix: \(radix))")
      }
    }
  }

  // https://en.wikipedia.org/wiki/Numerals_in_Unicode
  func test_unicode_invalidNumerals_fails() {
    let inputs = [
      // Not numeric
      "X", // Latin
      "!",
      "Д",
      "μ",
      "に",
      ",̆",
      // Decimal
      "६", // Devanagari 6
      "೬", // Kannada 6
      "𝟨", // Mathematical, styled sans serif
      // Digit
      "¹", // superscript
      "①", // in circle
      "⒈", // digit with full stop
      // Numeric
      "¾",
      "௰", // Tamil number ten
      "Ⅹ", // Roman numeral
      "六", // Han number 6
      // Fullwidth
      "２", "Ｃ", // capitals
      "２", "ｃ", // small letters
      // Mathematical constants
      "ℎ", // U+210E PLANCK CONSTANT
      "ℏ", // U+210F PLANCK CONSTANT OVER TWO PI
      "ℇ", // U+2107 EULER CONSTANT
      // Cultures
      "1\u{066B}25", "٠٫٢٥", // // Arabic (٫ - comma, '٠٫٢٥' = 0.25)
      "𐅈", "𐅥", // Greek
      "Ⅲ", "Ⅸ", "ↁ", // Roman
      "𝍢", "𝍧", // Counting rod
      // Zalgo (https://www.zalgo.org)
      "1̴2̷3̸",
      "1̵̻̊̎2̴̩̝̃̆3̴̪̹͆"
    ]

    self.unicodeFails(inputs: inputs)
  }

  // https://www.unicode.org/reports/tr51/
  func test_unicode_emoji_fails() {
    let zwj = "\u{200D}" // U+200D ZERO WIDTH JOINER
    let variant = "\u{FE0F}" // U+FE0F Variation Selector-16

    let inputs = [
      zwj,
      variant,
      // Emoji
      "😊",
      "😊\(zwj)",
      "\(zwj)😊",
      // Gender
      "🏃",
      "🏃\(zwj)♂️",
      "🏃\(zwj)♀️",
      // Skin color (modifiers, so ZWJ is not needed)
      "👋",
      "👋\u{1F3FB}", // 🏻 Light Skin Tone
      "👋\u{1F3FC}", // 🏼 Medium-Light Skin Tone
      "👋\u{1F3FD}", // 🏽 Medium Skin Tone
      "👋\u{1F3FE}", // 🏾 Medium-Dark Skin Tone
      "👋\u{1F3FF}", // 🏿 Dark Skin Tone
      "👋\(zwj)\u{1F3FB}", // 🏻 Light Skin Tone (should fail to combine)
      // Combo
      "👩\u{1F3FB}\(zwj)❤️\(zwj)👩\u{1F3FD}", // 👩🏻‍❤️‍👩🏽 Woman Light + Heart + Woman Medium
      "👩\u{1F3FD}\(zwj)❤\(variant)\(zwj)💋\(zwj)👨\u{1F3FF}", // 👩🏽‍❤️‍💋‍👨🏿 Woman Medium + Heart + Kiss + Man Dark
      "👨\(zwj)🍼", // 👨‍🍼 Man feeding baby
      "🧑\(zwj)🍼", // 🧑‍🍼 Person feeding baby
      // Kic-kic
      "🐰",
      "🐈\(zwj)⬛",
      "🐈\(zwj)🟧",
      // Direction
      "🏃\(zwj)⬅\(variant)",
      "🏃\(zwj)➡\(variant)",
      // Flags
      "🏴\(zwj)",
      "🏴\(zwj)☠️", // 🏴‍☠️ Pirate Flag
      "🏳\(variant)\(zwj)🌈", // 🏳️‍🌈 Rainbow Flag
      "🏳\(variant)\(zwj)⚧\(variant)", // 🏳️‍⚧️ Transgender Flag
      "\u{1F1F5}\u{1F1F1}", // 🇵🇱 Flag Poland (Regional PL)
      "\u{1F1F5}\u{1F1FF}", // 🇵🇿 Flag Unknown (Regional PZ)
      "🏴\u{E0067}\u{E0062}\u{E0065}\u{E006E}\u{E0067}\u{E007F}" // 🏴󠁧󠁢󠁥󠁮󠁧󠁿 England (Black flag + Regional GBEN + Cancel tag)
    ]

    self.unicodeFails(inputs: inputs)
  }

  private func unicodeFails(inputs: [String],
                            file: StaticString = #file,
                            line: UInt = #line) {
    let zwj = "\u{200D}" // U+200D ZERO WIDTH JOINER

    for i in inputs {
      let variants = [
        i,
        // Suffix
        "123\(i)",
        "123\(zwj)\(i)",
        "123\(i)\(zwj)",
        // Middle
        "12\(i)3",
        "12\(zwj)\(i)3",
        "12\(i)\(zwj)3",
        // Prefix
        "\(i)123",
        "\(zwj)\(i)123",
        "\(i)\(zwj)123"
      ]

      for radix in [2, 4, 8, 10, 16, 32] {
        for string in variants {
          let n = self.create(string: string, radix: radix)
          let nString = n.map(String.init) ?? "nil"
          XCTAssertNil(n,
                       "\(string) -> \(nString) (radix: \(radix))",
                       file: file,
                       line: line)
        }
      }
    }
  }

  // MARK: - Helpers

  /// Abstraction over `BigInt.init(_:radix:)`.
  private func create(string: String, radix: Int) -> BigInt? {
    return BigInt(string, radix: radix)
  }

  private func run(suite: TestSuite,
                   file: StaticString = #file,
                   line: UInt = #line) {
    let radix = suite.radix

    for testCase in suite.cases {
      let input = testCase.string
      let expected = testCase.create()
      let expectedNegative = testCase.create(sign: .negative)

      let lowercased = self.create(string: input.lowercased(), radix: radix)
      XCTAssertEqual(lowercased, expected, "LOWERCASE " + input, file: file, line: line)

      let uppercased = self.create(string: input.uppercased(), radix: radix)
      XCTAssertEqual(uppercased, expected, "UPPERCASE " + input, file: file, line: line)

      let plusSign = self.create(string: "+" + input, radix: radix)
      XCTAssertEqual(plusSign, expected, "PLUS " + input, file: file, line: line)

      assert(!testCase.isZero, "-0 should be handled differently")
      let minusSign = self.create(string: "-" + input, radix: radix)
      XCTAssertEqual(minusSign, expectedNegative, "MINUS " + input, file: file, line: line)
    }
  }
}
