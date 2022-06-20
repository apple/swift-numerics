//===--- Quaternion+Codable.swift -----------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2022 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import RealModule

// FloatingPoint does not refine Codable, so this is a conditional conformance.
extension Quaternion: Decodable where RealType: Decodable {
  public init(from decoder: Decoder) throws {
    try self.init(from: SIMD4(from: decoder))
  }
}

extension Quaternion: Encodable where RealType: Encodable {
  public func encode(to encoder: Encoder) throws {
    try components.encode(to: encoder)
  }
}
