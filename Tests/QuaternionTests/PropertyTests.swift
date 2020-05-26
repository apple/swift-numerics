//===--- PropertyTests.swift ----------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import QuaternionModule

final class PropertyTests: XCTestCase {

    func testComponentInitializer() {
        let _ = Quaternion(3, (1, 2, 3))
    }
}
