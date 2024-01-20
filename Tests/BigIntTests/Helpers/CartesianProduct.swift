//===--- CartesianProduct.swift -------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// `[1, 2], [A, B] -> [(1,A), (1,B), (2,A), (2,B)]`
internal struct CartesianProduct<T, V>: Sequence {

  internal typealias Element = (T, V)

  internal struct Iterator: IteratorProtocol {

    private let lhsValues: [T]
    private let rhsValues: [V]

    // Index of the next emitted element
    private var lhsIndex = 0
    private var rhsIndex = 0

    fileprivate init(lhs: [T], rhs: [V]) {
      self.lhsValues = lhs
      self.rhsValues = rhs
    }

    internal mutating func next() -> Element? {
      if self.lhsIndex == self.lhsValues.count {
        return nil
      }

      let lhs = self.lhsValues[self.lhsIndex]
      let rhs = self.rhsValues[self.rhsIndex]

      self.rhsIndex += 1
      if self.rhsIndex == self.rhsValues.count {
        self.lhsIndex += 1
        self.rhsIndex = 0
      }

      return (lhs, rhs)
    }
  }

  private let lhsValues: [T]
  private let rhsValues: [V]

  /// `[1, 2] -> [(1,1), (1,2), (2,1), (2,2)]`
  internal init(_ values: [T]) where T == V {
    self.lhsValues = values
    self.rhsValues = values
  }

  /// `[1, 2], [A, B] -> [(1,A), (1,B), (2,A), (2,B)]`
  internal init(_ lhs: [T], _ rhs: [V]) {
    self.lhsValues = lhs
    self.rhsValues = rhs
  }

  internal func makeIterator() -> Iterator {
    return Iterator(lhs: self.lhsValues, rhs: self.rhsValues)
  }
}
