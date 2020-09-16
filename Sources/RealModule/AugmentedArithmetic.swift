//===--- AugmentedArithmetic.swift ----------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

public enum Augmented { }

extension Augmented {
  @_transparent
  public static func twoProdFMA<T:Real>(_ a: T, _ b: T) -> (head: T, tail: T) {
    let head = a*b
    let tail = (-head).addingProduct(a, b)
    return (head, tail)
  }
  
  @_transparent
  public static func fastTwoSum<T:Real>(_ a: T, _ b: T) -> (head: T, tail: T) {
    assert(!(b.magnitude > a.magnitude))
    let head = a + b
    let tail = a - head + b
    return (head, tail)
  }
}
