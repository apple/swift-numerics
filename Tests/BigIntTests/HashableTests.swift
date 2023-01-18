//===--- HashableTests.swift ----------------------------------*- swift -*-===//
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

// Well… actually… hash and equatable
class HashableTests: XCTestCase {

  private lazy var ints: [Int] = {
    let result = generateInts(approximateCount: 50)
    HashableTests.assertNoDuplicates(result)
    return result
  }()

  private lazy var bigs: [BigIntPrototype] = {
    let result = generateBigInts(approximateCount: 50)
    HashableTests.assertNoDuplicates(result.map { $0.create() })
    return result
  }()

  private static func assertNoDuplicates<T: Equatable>(_ values: [T]) {
    // We can't use 'Set' because 'Hashable' was not yet proven to work correctly...
    for (index, lhs) in values.enumerated() {
      for rhs in values[..<index] {
        assert(lhs != rhs, "Duplicate: \(lhs). This will break 'count' calculations.")
      }
    }
  }

  // Values that are in both `ints` and `bigs`.
  private lazy var common: [BigInt] = {
    var result = [BigInt]()
    let intsSet = Set(self.ints)

    for p in self.bigs {
      let big = p.create()

      if let int = Int(exactly: big), intsSet.contains(int) {
        result.append(big)
      }
    }

    assert(!result.isEmpty)
    return result
  }()

  private var scalars: [UnicodeScalar] = {
    let asciiStart: UInt8 = 0x21 // !
    let asciiEnd: UInt8 = 0x7e // ~
    let result = (asciiStart...asciiEnd).map { UnicodeScalar($0) }
    return result + result // to be sure that it is more than 'self.ints.count'
  }()

  // MARK: - Set

  func test_set_insertAndFind() {
    // Insert all of the values
    var set = Set<BigInt>()
    self.insert(&set, values: self.ints)
    self.insert(&set, values: self.bigs)

    let expectedCount = self.ints.count + self.bigs.count - self.common.count
    XCTAssertEqual(set.count, expectedCount)

    // Check if we can find them
    for value in self.ints {
      let int = self.create(value)
      XCTAssert(set.contains(int), "\(value)")
    }

    for value in self.bigs {
      let int = self.create(value)
      XCTAssert(set.contains(int), "\(int)")
    }
  }

  func test_set_insertAndRemove() {
    // Insert all of the values
    var set = Set<BigInt>()
    self.insert(&set, values: self.ints)
    self.insert(&set, values: self.bigs)

    let allCount = self.ints.count + self.bigs.count - self.common.count
    XCTAssertEqual(set.count, allCount)

    // And now remove them
    for value in self.ints {
      let int = self.create(value)
      let existing = set.remove(int)
      XCTAssertNotNil(existing, "Missing: \(value)")
    }

    let withoutIntCount = self.bigs.count - self.common.count
    XCTAssertEqual(set.count, withoutIntCount)

    for value in self.bigs {
      let int = self.create(value)
      let wasAlreadyRemoved = self.common.contains(int)

      if !wasAlreadyRemoved {
        let existing = set.remove(int)
        XCTAssertNotNil(existing, "Missing: \(int)")
      }
    }

    XCTAssert(set.isEmpty)
  }

  // MARK: - Dict

  func test_dict_insertAndFind() {
    // Insert all of the numbers to dict
    var dict = [BigInt: UnicodeScalar]()
    self.insert(&dict, values: zip(self.ints, self.scalars))
    self.insert(&dict, values: zip(self.bigs, self.scalars), excluding: self.common)

    let expectedCount = self.ints.count + self.bigs.count - self.common.count
    XCTAssertEqual(dict.count, expectedCount)

    // Check if we can find all of the elements
    for (value, char) in zip(self.ints, self.scalars) {
      let int = self.create(value)

      if let result = dict[int] {
        XCTAssertEqual(result, char, "key: \(int)")
      } else {
        XCTFail("missing: \(int)")
      }
    }

    for (value, char) in zip(self.bigs, self.scalars) {
      let int = self.create(value)

      if self.common.contains(int) {
        // It was already checked in 'int' loop
      } else if let result = dict[int] {
        XCTAssertEqual(result, char, "key: \(int)")
      } else {
        XCTFail("missing: \(int)")
      }
    }
  }

  func test_dict_insertAndRemove() {
    // Insert all of the numbers to dict
    var dict = [BigInt: UnicodeScalar]()
    self.insert(&dict, values: zip(self.ints, self.scalars))
    self.insert(&dict, values: zip(self.bigs, self.scalars), excluding: self.common)

    let expectedCount = self.ints.count + self.bigs.count - self.common.count
    XCTAssertEqual(dict.count, expectedCount)

    // And now remove them
    for value in self.ints {
      let int = self.create(value)
      let existing = dict.removeValue(forKey: int)
      XCTAssertNotNil(existing, "Missing: \(value)")
    }

    let withoutIntCount = self.bigs.count - self.common.count
    XCTAssertEqual(dict.count, withoutIntCount)

    for value in self.bigs {
      let int = self.create(value)
      let wasAlreadyRemoved = self.common.contains(int)

      if !wasAlreadyRemoved {
        let existing = dict.removeValue(forKey: int)
        XCTAssertNotNil(existing, "Missing: \(int)")
      }
    }

    XCTAssert(dict.isEmpty)
  }

  func test_dict_insertReplaceAndFind() {
    // Insert all of the numbers to dict
    var dict = [BigInt: UnicodeScalar]()
    self.insert(&dict, values: zip(self.ints, self.scalars))
    self.insert(&dict, values: zip(self.bigs, self.scalars), excluding: self.common)

    let expectedCount = self.ints.count + self.bigs.count - self.common.count
    XCTAssertEqual(dict.count, expectedCount)

    // Replace the values
    let reversedScalars = self.scalars.reversed()
    self.insert(&dict, values: zip(self.ints, reversedScalars))
    self.insert(&dict, values: zip(self.bigs, reversedScalars), excluding: self.common)

    // Count should have not changed
    XCTAssertEqual(dict.count, expectedCount)

    // Check if we can find all of the elements
    for (value, char) in zip(self.ints, reversedScalars) {
      let int = self.create(value)

      if let result = dict[int] {
        XCTAssertEqual(result, char, "key: \(int)")
      } else {
        XCTFail("missing: \(int)")
      }
    }

    for (value, char) in zip(self.bigs, reversedScalars) {
      let int = self.create(value)

      if self.common.contains(int) {
        // It was already checked in 'int' loop
      } else if let result = dict[int] {
        XCTAssertEqual(result, char, "key: \(int)")
      } else {
        XCTFail("missing: \(int)")
      }
    }
  }

  // MARK: - Helpers

  private func insert(_ set: inout Set<BigInt>, values: [Int]) {
    for value in values {
      let int = self.create(value)
      set.insert(int)
    }
  }

  private func insert(_ set: inout Set<BigInt>, values: [BigIntPrototype]) {
    for value in values {
      let int = self.create(value)
      set.insert(int)
    }
  }

  private func insert<S: Sequence>(
    _ dict: inout [BigInt: UnicodeScalar],
    values: S
  ) where S.Element == (Int, UnicodeScalar) {
    for (value, char) in values {
      let int = self.create(value)
      dict[int] = char
    }
  }

  private func insert<S: Sequence>(
    _ dict: inout [BigInt: UnicodeScalar],
    values: S,
    excluding: [BigInt]
  ) where S.Element == (BigIntPrototype, UnicodeScalar) {
    for (value, char) in values {
      let int = self.create(value)
      if !excluding.contains(int) {
        dict[int] = char
      }
    }
  }

  private func create(_ int: Int) -> BigInt {
    return BigInt(int)
  }

  private func create(_ p: BigIntPrototype) -> BigInt {
    return p.create()
  }
}
