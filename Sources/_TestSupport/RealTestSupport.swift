//===--- RealTestSupport.swift --------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import RealModule

public protocol FixedWidthFloatingPoint: BinaryFloatingPoint
where Exponent: FixedWidthInteger,
      RawSignificand: FixedWidthInteger { }

#if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
extension Float16: FixedWidthFloatingPoint { }
#endif

extension Float: FixedWidthFloatingPoint { }
extension Double: FixedWidthFloatingPoint { }
#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
extension Float80: FixedWidthFloatingPoint { }
#endif

extension FloatingPointSign {
  static func random<G: RandomNumberGenerator>(using g: inout G) -> FloatingPointSign {
    [.plus,.minus].randomElement(using: &g)!
  }
}
