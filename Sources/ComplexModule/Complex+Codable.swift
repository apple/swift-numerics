//===--- Complex+Codable.swift --------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2025 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import RealModule

// FloatingPoint does not refine Codable, so this is a conditional conformance.
#if compiler(>=6.0)
@_unavailableInEmbedded
#endif
extension Complex: Decodable where RealType: Decodable {
  public init(from decoder: Decoder) throws {
    var unkeyedContainer = try decoder.unkeyedContainer()
    let x = try unkeyedContainer.decode(RealType.self)
    let y = try unkeyedContainer.decode(RealType.self)
    self.init(x, y)
  }
}

#if compiler(>=6.0)
@_unavailableInEmbedded
#endif
extension Complex: Encodable where RealType: Encodable {
  public func encode(to encoder: Encoder) throws {
    var unkeyedContainer = encoder.unkeyedContainer()
    try unkeyedContainer.encode(x)
    try unkeyedContainer.encode(y)
  }
}
