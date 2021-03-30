//===--- CollectionPadding.swift ------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

public enum CollectionBound {
  case start
  case end
}
extension CollectionBound {
  internal var inverted: CollectionBound { self == .start ? .end : .start }
}

extension RangeReplaceableCollection {
  internal mutating func pad(
    to newCount: Int, using fill: Self.Element, at bound: CollectionBound = .end
  ) {
    guard newCount > 0 else { return }

    let currentCount = self.count
    guard newCount > currentCount else { return }

    let filler = repeatElement(fill, count: newCount &- currentCount)
    let insertIdx = bound == .start ? self.startIndex : self.endIndex
    self.insert(contentsOf: filler, at: insertIdx)
  }
  // TODO: Align/justify version, which just swaps the bound?
}


// Intersperse
extension Collection where SubSequence == Self {
  fileprivate mutating func _eat(_ n: Int = 1) -> SubSequence {
    defer { self = self.dropFirst(n) }
    return self.prefix(n)
  }
}

// NOTE: The below would be more efficient with RRC method variants
// that returned the new valid indices. Instead, we have to create a new
// collection and reassign self. Similarly, we could benefit from a slide
// operation that can leave temporarily uninitialized spaces inside the
// collection.
extension RangeReplaceableCollection {
  internal mutating func intersperse(
    _ newElement: Element, every n: Int, startingFrom bound: CollectionBound
  ) {
    self.intersperse(
      contentsOf: CollectionOfOne(newElement), every: n, startingFrom: bound)
  }

  internal mutating func intersperse<C: Collection>(
    contentsOf newElements : C, every n: Int, startingFrom bound: CollectionBound
  ) where C.Element == Element {
    precondition(n > 0)

    let currentCount = self.count
    guard currentCount > n else { return }

    let remainder = currentCount % n

    var result = Self()
    let interspersedCount = newElements.count
    let insertCount = (currentCount / n) - (remainder == 0 ? 1 : 0)
    let newCount = currentCount + interspersedCount * insertCount
    defer {
      assert(result.count == newCount)
    }
    result.reserveCapacity(newCount)

    var selfConsumer = self[...]

    // When we start from the end, any remainder will appear as a prefix.
    // Otherwise, the remainder will fall out naturally from the main loop.
    if remainder != 0 && bound == .end {
      result.append(contentsOf: selfConsumer._eat(remainder))
      assert(!selfConsumer.isEmpty, "Guarded count above")
      result.append(contentsOf: newElements)
    }

    while !selfConsumer.isEmpty {
      result.append(contentsOf: selfConsumer._eat(n))
      if !selfConsumer.isEmpty {
        result.append(contentsOf: newElements)
      }
    }
    self = result
  }
}
