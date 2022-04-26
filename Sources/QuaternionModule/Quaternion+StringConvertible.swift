//===--- Quaternion+StringConvertible.swift -------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2022 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension Quaternion: CustomStringConvertible {
  public var description: String {
    guard isFinite else { return "inf" }
    return "(\(components.w), \(components.x), \(components.y), \(components.z))"
  }
}

extension Quaternion: CustomDebugStringConvertible {
  public var debugDescription: String {
    let x = String(reflecting: components.x)
    let y = String(reflecting: components.y)
    let z = String(reflecting: components.z)
    let r = String(reflecting: components.w)
    return "Quaternion<\(RealType.self)>(\(r), \(x), \(y), \(z))"
  }
}

