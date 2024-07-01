//===--- Interval.swift ---------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

// A not-particularly-clever floating-point iterval that is iterable for the
// purposes of testing.
public struct Interval<Element>: Sequence where Element: FloatingPoint {
  
  let lower: Element
  
  let upper: Element
  
  public init(from: Element, through: Element) {
    precondition(from <= through)
    lower = from
    upper = through
  }
  
  public init(from: Element, to: Element) {
    self.init(from: from, through: to.nextDown)
  }
  
  public func makeIterator() -> Iterator {
    Iterator(self)
  }
  
  public struct Iterator: IteratorProtocol {
    let interval: Interval
    var nextOutput: Element?
    
    init(_ interval: Interval) {
      self.interval = interval
      self.nextOutput = interval.lower
    }
    
    public mutating func next() -> Element? {
      let result = nextOutput
      if nextOutput == interval.upper { nextOutput = nil }
      else { nextOutput = nextOutput?.nextUp }
      return result
    }
  }
}
