//===--- IntegerTestGen.swift ---------------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

func unique<T>(_ array: [T]) -> [T] where T: Hashable {
  return Array(Set(array))
}

func twiddle<T>(_ list: inout [T], upTo bit: Int, depth: Int) where T : FixedWidthInteger {
  guard depth != 0 else { return }
  let base = list.last!
  for i in 0 ..< bit {
    let step = 1 as T &<< i
    list.append(base &+ step)
    twiddle(&list, upTo: i, depth: depth - 1)
    if i + 1 != bit {
      list.append(base &- step)
      twiddle(&list, upTo: i, depth: depth - 1)
    }
  }
}

public func testCases<T>(depth: Int = 3) -> [T]
  where T: FixedWidthInteger {
    var cases = [0 as T]
    twiddle(&cases, upTo: T.bitWidth, depth: depth)
    return unique(cases)
}

let int8TestInputs: [Int8] = { testCases( ) }()
let int16TestInputs: [Int16] = { testCases( ) }()
let int32TestInputs: [Int32] = { testCases( ) }()
let int64TestInputs: [Int64] = { testCases( ) }()
let intTestInputs: [Int] = { testCases( ) }()

let uint8TestInputs: [UInt8] = {
  int8TestInputs.map{ UInt8(truncatingIfNeeded: $0) }
}()
let uint16TestInputs: [UInt16] = {
  int16TestInputs.map{ UInt16(truncatingIfNeeded: $0) }
}()
let uint32TestInputs: [UInt32] = {
  int32TestInputs.map{ UInt32(truncatingIfNeeded: $0) }
}()
let uint64TestInputs: [UInt64] = {
  int64TestInputs.map{ UInt64(truncatingIfNeeded: $0) }
}()
let uintTestInputs: [UInt] = {
  intTestInputs.map{ UInt(truncatingIfNeeded: $0) }
}()

extension Int8 : NumericsTestInputs {
  public static func testInputs() -> [Int8] {
    return int8TestInputs
  }
}

extension UInt8 : NumericsTestInputs {
  public static func testInputs() -> [UInt8] {
    return uint8TestInputs
  }
}

extension Int16 : NumericsTestInputs {
  public static func testInputs() -> [Int16] {
    return int16TestInputs
  }
}

extension UInt16 : NumericsTestInputs {
  public static func testInputs() -> [UInt16] {
    return uint16TestInputs
  }
}

extension Int32 : NumericsTestInputs {
  public static func testInputs() -> [Int32] {
    return int32TestInputs
  }
}

extension UInt32 : NumericsTestInputs {
  public static func testInputs() -> [UInt32] {
    return uint32TestInputs
  }
}

extension Int64 : NumericsTestInputs {
  public static func testInputs() -> [Int64] {
    return int64TestInputs
  }
}

extension UInt64 : NumericsTestInputs {
  public static func testInputs() -> [UInt64] {
    return uint64TestInputs
  }
}

extension Int : NumericsTestInputs {
  public static func testInputs() -> [Int] {
    return intTestInputs
  }
}

extension UInt : NumericsTestInputs {
  public static func testInputs() -> [UInt] {
    return uintTestInputs
  }
}
