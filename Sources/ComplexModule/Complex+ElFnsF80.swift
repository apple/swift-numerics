//===--- Complex+ElFnsF80.swift -------------------------------*- swift -*-===//
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

#if (arch(i386) || arch(x86_64)) && !(os(Windows) || os(Android))
extension Complex {
  @_specialize(exported: true, target: exp(_:), where RealType == Float80)
  public static func _expF80(_ z: Self) -> Self {
    _expImpl(z)
  }
}
#endif
*/
