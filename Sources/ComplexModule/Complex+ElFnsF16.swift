//===--- Complex+ElFnsF16.swift -------------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2019-2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

/*
import RealModule

#if swift(>=5.4) && !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
extension Complex {
  @_specialize(exported: true, target: exp(_:), where RealType == Float16)
  public static func _expF16(_ z: Self) -> Self {
    _expImpl(z)
  }
}
#endif
*/
