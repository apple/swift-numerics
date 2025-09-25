//===--- Complex+StringConvertible.swift ----------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2025 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension Complex: CustomStringConvertible {
  public var description: String {
    guard isFinite else { return "inf" }
    return "(\(x), \(y))"
  }
}

#if compiler(>=6.0)
@_unavailableInEmbedded
#endif
extension Complex: CustomDebugStringConvertible {
  public var debugDescription: String {
    "Complex<\(RealType.self)>(\(String(reflecting: x)), \(String(reflecting: y)))"
  }
}
