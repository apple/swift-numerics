//===--- COWTests.swift ---------------------------------------*- swift -*-===//
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

// swiftlint:disable file_length

private typealias Word = BigInt.Word

class COWTests: XCTestCase {

  // This can't be '1' because 'n *= 1 -> n' (which is one of our test cases)
  private let int = BigInt(2)
  private let big = BigInt(Word.max)
  private let shiftCount = 3

  // MARK: - Plus

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  func test_plus_doesNotModifyOriginal() {
    // +int
    var value = BigInt(Int.max)
    _ = +value
    XCTAssertEqual(value, BigInt(Int.max))

    // +big
    value = BigInt(Word.max)
    _ = +value
    XCTAssertEqual(value, BigInt(Word.max))
  }

  // MARK: - Minus

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  func test_minus_doesNotModifyOriginal() {
    // -int
    var value = BigInt(Int.max)
    _ = -value
    XCTAssertEqual(value, BigInt(Int.max))

    // -big
    value = BigInt(Word.max)
    _ = -value
    XCTAssertEqual(value, BigInt(Word.max))
  }

  // MARK: - Invert

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  func test_invert_doesNotModifyOriginal() {
    // ~int
    var value = BigInt(Int.max)
    _ = ~value
    XCTAssertEqual(value, BigInt(Int.max))

    // ~big
    value = BigInt(Word.max)
    _ = ~value
    XCTAssertEqual(value, BigInt(Word.max))
  }

  // MARK: - Add

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  func test_add_toCopy_doesNotModifyOriginal() {
    // int + int
    var value = BigInt(Int.max)
    var copy = value
    _ = copy + self.int
    XCTAssertEqual(value, BigInt(Int.max))

    // int + big
    value = BigInt(Int.max)
    copy = value
    _ = copy + self.big
    XCTAssertEqual(value, BigInt(Int.max))

    // big + int
    value = BigInt(Word.max)
    copy = value
    _ = copy + self.int
    XCTAssertEqual(value, BigInt(Word.max))

    // big + big
    value = BigInt(Word.max)
    copy = value
    _ = copy + self.big
    XCTAssertEqual(value, BigInt(Word.max))
  }

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  func test_add_toInout_doesNotModifyOriginal() {
    // int + int
    var value = BigInt(Int.max)
    self.addInt(toInout: &value)
    XCTAssertEqual(value, BigInt(Int.max))

    // int + big
    value = BigInt(Int.max)
    self.addBig(toInout: &value)
    XCTAssertEqual(value, BigInt(Int.max))

    // big + int
    value = BigInt(Word.max)
    self.addInt(toInout: &value)
    XCTAssertEqual(value, BigInt(Word.max))

    // big + big
    value = BigInt(Word.max)
    self.addBig(toInout: &value)
    XCTAssertEqual(value, BigInt(Word.max))
  }

  private func addInt(toInout value: inout BigInt) {
    _ = value + self.int
  }

  private func addBig(toInout value: inout BigInt) {
    _ = value + self.big
  }

  func test_addEqual_toCopy_doesNotModifyOriginal() {
    // int + int
    var value = BigInt(Int.max)
    var copy = value
    copy += self.int
    XCTAssertEqual(value, BigInt(Int.max))

    // int + big
    value = BigInt(Int.max)
    copy = value
    copy += self.big
    XCTAssertEqual(value, BigInt(Int.max))

    // big + int
    value = BigInt(Word.max)
    copy = value
    copy += self.int
    XCTAssertEqual(value, BigInt(Word.max))

    // big + big
    value = BigInt(Word.max)
    copy = value
    copy += self.big
    XCTAssertEqual(value, BigInt(Word.max))
  }

  func test_addEqual_toInout_doesModifyOriginal() {
    // int + int
    var value = BigInt(Int.max)
    self.addEqualInt(toInout: &value)
    XCTAssertNotEqual(value, BigInt(Int.max))

    // int + big
    value = BigInt(Int.max)
    self.addEqualBig(toInout: &value)
    XCTAssertNotEqual(value, BigInt(Int.max))

    // big + int
    value = BigInt(Word.max)
    self.addEqualInt(toInout: &value)
    XCTAssertNotEqual(value, BigInt(Word.max))

    // big + big
    value = BigInt(Word.max)
    self.addEqualBig(toInout: &value)
    XCTAssertNotEqual(value, BigInt(Word.max))
  }

  private func addEqualInt(toInout value: inout BigInt) {
    value += self.int
  }

  private func addEqualBig(toInout value: inout BigInt) {
    value += self.big
  }

  // MARK: - Sub

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  func test_sub_toCopy_doesNotModifyOriginal() {
    // int - int
    var value = BigInt(Int.max)
    var copy = value
    _ = copy - self.int
    XCTAssertEqual(value, BigInt(Int.max))

    // int - big
    value = BigInt(Int.max)
    copy = value
    _ = copy - self.big
    XCTAssertEqual(value, BigInt(Int.max))

    // big - int
    value = BigInt(Word.max)
    copy = value
    _ = copy - self.int
    XCTAssertEqual(value, BigInt(Word.max))

    // big - big
    value = BigInt(Word.max)
    copy = value
    _ = copy - self.big
    XCTAssertEqual(value, BigInt(Word.max))
  }

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  func test_sub_toInout_doesNotModifyOriginal() {
    // int - int
    var value = BigInt(Int.max)
    self.subInt(toInout: &value)
    XCTAssertEqual(value, BigInt(Int.max))

    // int - big
    value = BigInt(Int.max)
    self.subBig(toInout: &value)
    XCTAssertEqual(value, BigInt(Int.max))

    // big - int
    value = BigInt(Word.max)
    self.subInt(toInout: &value)
    XCTAssertEqual(value, BigInt(Word.max))

    // big - big
    value = BigInt(Word.max)
    self.subBig(toInout: &value)
    XCTAssertEqual(value, BigInt(Word.max))
  }

  private func subInt(toInout value: inout BigInt) {
    _ = value - self.int
  }

  private func subBig(toInout value: inout BigInt) {
    _ = value - self.big
  }

  func test_subEqual_toCopy_doesNotModifyOriginal() {
    // int - int
    var value = BigInt(Int.max)
    var copy = value
    copy -= self.int
    XCTAssertEqual(value, BigInt(Int.max))

    // int - big
    value = BigInt(Int.max)
    copy = value
    copy -= self.big
    XCTAssertEqual(value, BigInt(Int.max))

    // big - int
    value = BigInt(Word.max)
    copy = value
    copy -= self.int
    XCTAssertEqual(value, BigInt(Word.max))

    // big - big
    value = BigInt(Word.max)
    copy = value
    copy -= self.big
    XCTAssertEqual(value, BigInt(Word.max))
  }

  func test_subEqual_toInout_doesModifyOriginal() {
    // int - int
    var value = BigInt(Int.max)
    self.subEqualInt(toInout: &value)
    XCTAssertNotEqual(value, BigInt(Int.max))

    // int - big
    value = BigInt(Int.max)
    self.subEqualBig(toInout: &value)
    XCTAssertNotEqual(value, BigInt(Int.max))

    // big - int
    value = BigInt(Word.max)
    self.subEqualInt(toInout: &value)
    XCTAssertNotEqual(value, BigInt(Word.max))

    // big - big
    value = BigInt(Word.max)
    self.subEqualBig(toInout: &value)
    XCTAssertNotEqual(value, BigInt(Word.max))
  }

  private func subEqualInt(toInout value: inout BigInt) {
    value -= self.int
  }

  private func subEqualBig(toInout value: inout BigInt) {
    value -= self.big
  }

  // MARK: - Mul

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  func test_mul_toCopy_doesNotModifyOriginal() {
    // int * int
    var value = BigInt(Int.max)
    var copy = value
    _ = copy * self.int
    XCTAssertEqual(value, BigInt(Int.max))

    // int * big
    value = BigInt(Int.max)
    copy = value
    _ = copy * self.big
    XCTAssertEqual(value, BigInt(Int.max))

    // big * int
    value = BigInt(Word.max)
    copy = value
    _ = copy * self.int
    XCTAssertEqual(value, BigInt(Word.max))

    // big * big
    value = BigInt(Word.max)
    copy = value
    _ = copy * self.big
    XCTAssertEqual(value, BigInt(Word.max))
  }

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  func test_mul_toInout_doesNotModifyOriginal() {
    // int * int
    var value = BigInt(Int.max)
    self.mulInt(toInout: &value)
    XCTAssertEqual(value, BigInt(Int.max))

    // int * big
    value = BigInt(Int.max)
    self.mulBig(toInout: &value)
    XCTAssertEqual(value, BigInt(Int.max))

    // big * int
    value = BigInt(Word.max)
    self.mulInt(toInout: &value)
    XCTAssertEqual(value, BigInt(Word.max))

    // big * big
    value = BigInt(Word.max)
    self.mulBig(toInout: &value)
    XCTAssertEqual(value, BigInt(Word.max))
  }

  private func mulInt(toInout value: inout BigInt) {
    _ = value * self.int
  }

  private func mulBig(toInout value: inout BigInt) {
    _ = value * self.big
  }

  func test_mulEqual_toCopy_doesNotModifyOriginal() {
    // int * int
    var value = BigInt(Int.max)
    var copy = value
    copy *= self.int
    XCTAssertEqual(value, BigInt(Int.max))

    // int * big
    value = BigInt(Int.max)
    copy = value
    copy *= self.big
    XCTAssertEqual(value, BigInt(Int.max))

    // big * int
    value = BigInt(Word.max)
    copy = value
    copy *= self.int
    XCTAssertEqual(value, BigInt(Word.max))

    // big * big
    value = BigInt(Word.max)
    copy = value
    copy *= self.big
    XCTAssertEqual(value, BigInt(Word.max))
  }

  func test_mulEqual_toInout_doesModifyOriginal() {
    // int * int
    var value = BigInt(Int.max)
    self.mulEqualInt(toInout: &value)
    XCTAssertNotEqual(value, BigInt(Int.max))

    // int * big
    value = BigInt(Int.max)
    self.mulEqualBig(toInout: &value)
    XCTAssertNotEqual(value, BigInt(Int.max))

    // big * int
    value = BigInt(Word.max)
    self.mulEqualInt(toInout: &value)
    XCTAssertNotEqual(value, BigInt(Word.max))

    // big * big
    value = BigInt(Word.max)
    self.mulEqualBig(toInout: &value)
    XCTAssertNotEqual(value, BigInt(Word.max))
  }

  private func mulEqualInt(toInout value: inout BigInt) {
    value *= self.int
  }

  private func mulEqualBig(toInout value: inout BigInt) {
    value *= self.big
  }

  // MARK: - Div

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  func test_div_toCopy_doesNotModifyOriginal() {
    // int / int
    var value = BigInt(Int.max)
    var copy = value
    _ = copy / self.int
    XCTAssertEqual(value, BigInt(Int.max))

    // int / big
    value = BigInt(Int.max)
    copy = value
    _ = copy / self.big
    XCTAssertEqual(value, BigInt(Int.max))

    // big / int
    value = BigInt(Word.max)
    copy = value
    _ = copy / self.int
    XCTAssertEqual(value, BigInt(Word.max))

    // big / big
    value = BigInt(Word.max)
    copy = value
    _ = copy / self.big
    XCTAssertEqual(value, BigInt(Word.max))
  }

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  func test_div_toInout_doesNotModifyOriginal() {
    // int / int
    var value = BigInt(Int.max)
    self.divInt(toInout: &value)
    XCTAssertEqual(value, BigInt(Int.max))

    // int / big
    value = BigInt(Int.max)
    self.divBig(toInout: &value)
    XCTAssertEqual(value, BigInt(Int.max))

    // big / int
    value = BigInt(Word.max)
    self.divInt(toInout: &value)
    XCTAssertEqual(value, BigInt(Word.max))

    // big / big
    value = BigInt(Word.max)
    self.divBig(toInout: &value)
    XCTAssertEqual(value, BigInt(Word.max))
  }

  private func divInt(toInout value: inout BigInt) {
    _ = value / self.int
  }

  private func divBig(toInout value: inout BigInt) {
    _ = value / self.big
  }

  func test_divEqual_toCopy_doesNotModifyOriginal() {
    // int / int
    var value = BigInt(Int.max)
    var copy = value
    copy /= self.int
    XCTAssertEqual(value, BigInt(Int.max))

    // int / big
    value = BigInt(Int.max)
    copy = value
    copy /= self.big
    XCTAssertEqual(value, BigInt(Int.max))

    // big / int
    value = BigInt(Word.max)
    copy = value
    copy /= self.int
    XCTAssertEqual(value, BigInt(Word.max))

    // big / big
    value = BigInt(Word.max)
    copy = value
    copy /= self.big
    XCTAssertEqual(value, BigInt(Word.max))
  }

  func test_divEqual_toInout_doesModifyOriginal() {
    // int / int
    var value = BigInt(Int.max)
    self.divEqualInt(toInout: &value)
    XCTAssertNotEqual(value, BigInt(Int.max))

    // int / big
    value = BigInt(Int.max)
    self.divEqualBig(toInout: &value)
    XCTAssertNotEqual(value, BigInt(Int.max))

    // big / int
    value = BigInt(Word.max)
    self.divEqualInt(toInout: &value)
    XCTAssertNotEqual(value, BigInt(Word.max))

    // big / big
    value = BigInt(Word.max)
    self.divEqualBig(toInout: &value)
    XCTAssertNotEqual(value, BigInt(Word.max))
  }

  private func divEqualInt(toInout value: inout BigInt) {
    value /= self.int
  }

  private func divEqualBig(toInout value: inout BigInt) {
    value /= self.big
  }

  // MARK: - Mod

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  func test_mod_toCopy_doesNotModifyOriginal() {
    // int % int
    var value = BigInt(Int.max)
    var copy = value
    _ = copy % self.int
    XCTAssertEqual(value, BigInt(Int.max))

    // int % big
    value = BigInt(Int.max)
    copy = value
    _ = copy % self.big
    XCTAssertEqual(value, BigInt(Int.max))

    // big % int
    value = BigInt(Word.max)
    copy = value
    _ = copy % self.int
    XCTAssertEqual(value, BigInt(Word.max))

    // big % big
    value = BigInt(Word.max)
    copy = value
    _ = copy % self.big
    XCTAssertEqual(value, BigInt(Word.max))
  }

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  func test_mod_toInout_doesNotModifyOriginal() {
    // int % int
    var value = BigInt(Int.max)
    self.modInt(toInout: &value)
    XCTAssertEqual(value, BigInt(Int.max))

    // int % big
    value = BigInt(Int.max)
    self.modBig(toInout: &value)
    XCTAssertEqual(value, BigInt(Int.max))

    // big % int
    value = BigInt(Word.max)
    self.modInt(toInout: &value)
    XCTAssertEqual(value, BigInt(Word.max))

    // big % big
    value = BigInt(Word.max)
    self.modBig(toInout: &value)
    XCTAssertEqual(value, BigInt(Word.max))
  }

  private func modInt(toInout value: inout BigInt) {
    _ = value % self.int
  }

  private func modBig(toInout value: inout BigInt) {
    _ = value % self.big
  }

  func test_modEqual_toCopy_doesNotModifyOriginal() {
    // int % int
    var value = BigInt(Int.max)
    var copy = value
    copy %= self.int
    XCTAssertEqual(value, BigInt(Int.max))

    // int % big
    value = BigInt(Int.max)
    copy = value
    copy %= self.big
    XCTAssertEqual(value, BigInt(Int.max))

    // big % int
    value = BigInt(Word.max)
    copy = value
    copy %= self.int
    XCTAssertEqual(value, BigInt(Word.max))

    // big % big
    value = BigInt(Word.max)
    copy = value
    copy %= self.big
    XCTAssertEqual(value, BigInt(Word.max))
  }

  func test_modEqual_toInout_doesModifyOriginal() {
    // int % int
    var value = BigInt(Int.max)
    self.modEqualInt(toInout: &value)
    XCTAssertNotEqual(value, BigInt(Int.max))

    // int % big
    // 'big' is always greater than 'int', so modulo is actually equal to 'int'
//    value = BigInt(Int.max)
//    self.modEqualBig(toInout: &value)
//    XCTAssertNotEqual(value, BigInt(Int.max))

    // big % int
    value = BigInt(Word.max)
    self.modEqualInt(toInout: &value)
    XCTAssertNotEqual(value, BigInt(Word.max))

    // big % big
    value = BigInt(Word.max)
    self.modEqualBig(toInout: &value)
    XCTAssertNotEqual(value, BigInt(Word.max))
  }

  private func modEqualInt(toInout value: inout BigInt) {
    value %= self.int
  }

  private func modEqualBig(toInout value: inout BigInt) {
    value %= self.big
  }

  // MARK: - Shift left

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  func test_shiftLeft_copy_doesNotModifyOriginal() {
    // int << int
    var value = BigInt(Int.max)
    var copy = value
    _ = copy << self.shiftCount
    XCTAssertEqual(value, BigInt(Int.max))

    // big << int
    value = BigInt(Word.max)
    copy = value
    _ = copy << self.shiftCount
    XCTAssertEqual(value, BigInt(Word.max))
  }

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  func test_shiftLeft_inout_doesNotModifyOriginal() {
    // int << int
    var value = BigInt(Int.max)
    self.shiftLeft(value: &value)
    XCTAssertEqual(value, BigInt(Int.max))

    // big << int
    value = BigInt(Word.max)
    self.shiftLeft(value: &value)
    XCTAssertEqual(value, BigInt(Word.max))
  }

  private func shiftLeft(value: inout BigInt) {
    _ = value << self.shiftCount
  }

  func test_shiftLeftEqual_copy_doesNotModifyOriginal() {
    // int << int
    var value = BigInt(Int.max)
    var copy = value
    copy <<= self.shiftCount
    XCTAssertEqual(value, BigInt(Int.max))

    // big << int
    value = BigInt(Word.max)
    copy = value
    copy <<= self.shiftCount
    XCTAssertEqual(value, BigInt(Word.max))
  }

  func test_shiftLeftEqual_inout_doesModifyOriginal() {
    // int << int
    var value = BigInt(Int.max)
    self.shiftLeftEqual(value: &value)
    XCTAssertNotEqual(value, BigInt(Int.max))

    // big << int
    value = BigInt(Word.max)
    self.shiftLeftEqual(value: &value)
    XCTAssertNotEqual(value, BigInt(Word.max))
  }

  private func shiftLeftEqual(value: inout BigInt) {
    value <<= self.shiftCount
  }

  // MARK: - Shift right

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  func test_shiftRight_copy_doesNotModifyOriginal() {
    // int >> int
    var value = BigInt(Int.max)
    var copy = value
    _ = copy >> self.shiftCount
    XCTAssertEqual(value, BigInt(Int.max))

    // big >> int
    value = BigInt(Word.max)
    copy = value
    _ = copy >> self.shiftCount
    XCTAssertEqual(value, BigInt(Word.max))
  }

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  func test_shiftRight_inout_doesNotModifyOriginal() {
    // int >> int
    var value = BigInt(Int.max)
    self.shiftRight(value: &value)
    XCTAssertEqual(value, BigInt(Int.max))

    // big >> int
    value = BigInt(Word.max)
    self.shiftRight(value: &value)
    XCTAssertEqual(value, BigInt(Word.max))
  }

  private func shiftRight(value: inout BigInt) {
    _ = value >> self.shiftCount
  }

  func test_shiftRightEqual_copy_doesNotModifyOriginal() {
    // int >> int
    var value = BigInt(Int.max)
    var copy = value
    copy >>= self.shiftCount
    XCTAssertEqual(value, BigInt(Int.max))

    // big >> int
    value = BigInt(Word.max)
    copy = value
    copy >>= self.shiftCount
    XCTAssertEqual(value, BigInt(Word.max))
  }

  func test_shiftRightEqual_inout_doesModifyOriginal() {
    // int >> int
    var value = BigInt(Int.max)
    self.shiftRightEqual(value: &value)
    XCTAssertNotEqual(value, BigInt(Int.max))

    // big >> int
    value = BigInt(Word.max)
    self.shiftRightEqual(value: &value)
    XCTAssertNotEqual(value, BigInt(Word.max))
  }

  private func shiftRightEqual(value: inout BigInt) {
    value >>= self.shiftCount
  }
}
