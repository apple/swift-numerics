//===--- Complex+IntegerLiteral.swift -------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2025 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension Complex: ExpressibleByIntegerLiteral {
  public typealias IntegerLiteralType = RealType.IntegerLiteralType
  
  @inlinable
  public init(integerLiteral value: IntegerLiteralType) {
    self.init(RealType(integerLiteral: value))
  }
}
