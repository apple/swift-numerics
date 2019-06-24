//===--- FloatingPointTestGen.swift ---------------------------*- swift -*-===//
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

protocol FloatingPointTestInput {
  static func testInputs() -> [Self]
}

extension Float: FloatingPointTestInput { }
extension Double: FloatingPointTestInput { }
#if arch(x86_64) && !os(Windows)
extension Float80: FloatingPointTestInput { }
#endif

/*
extension BinaryFloatingPoint where Self.RawSignificand : FixedWidthInteger {
  static func appendBounds<Integer>(_ testCases: inout [Self], for: Integer.Type)
    where Integer : FixedWidthInteger {
      if Self(Integer.min).isNormal { testCases.append(Self(Integer.min)) }
      if Self(Integer.max).isNormal { testCases.append(Self(Integer.max)) }
  }
}

public func unique<FP>(_ array: [FP]) -> [FP] where FP : BinaryFloatingPoint {
  var set = Set<FP>()
  for value in array {
    if !set.contains(where: { value == $0 || (value.isNaN && $0.isNaN) }) {
      set.insert(value)
    }
  }
  return Array(set)
}

func testCases<FP>( ) -> [FP]
  where FP: BinaryFloatingPoint, FP.RawSignificand : FixedWidthInteger {
    var interesting = [
      FP.leastNonzeroMagnitude,
      FP.leastNormalMagnitude,
      FP.ulpOfOne,
      1.0 as FP,
      FP.pi,
      FP.greatestFiniteMagnitude,
      FP.infinity,
      FP.nan
    ]
    FP.appendBounds(&interesting, for: Int8.self)
    FP.appendBounds(&interesting, for: Int16.self)
    FP.appendBounds(&interesting, for: Int32.self)
    FP.appendBounds(&interesting, for: Int64.self)
    interesting = interesting.flatMap { [0.5*$0, $0, 2*$0] }
    interesting = interesting.flatMap { [$0, 1/$0, -$0, -1/$0] }
    interesting = interesting.flatMap {
      [$0.nextDown, $0, $0.nextUp, $0.binade * FP.random(in: 1 ..< 2)]
    }
    return unique(interesting)
}

let floatTestInputs: [Float] = { testCases( ) }()

extension Float : NumericsTestInputs {
  public static func testInputs() -> [Float] {
    return floatTestInputs
  }
}

let doubleTestInputs: [Double] = { testCases( ) }()

extension Double : NumericsTestInputs {
  public static func testInputs() -> [Double] {
    return doubleTestInputs
  }
}

#if (arch(i386) || arch(x86_64)) && !os(Windows)
let float80TestInputs: [Float80] = { testCases( ) }()

extension Float80 : NumericsTestInputs {
  public static func testInputs() -> [Float80] {
    return float80TestInputs
  }
}
#endif
*/
