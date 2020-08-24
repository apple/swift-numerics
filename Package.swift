// swift-tools-version:5.0
//===--- Package.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import PackageDescription

let package = Package(
  name: "swift-numerics",
  products: [
    .library(name: "ComplexModule", targets: ["ComplexModule"]),
    .library(name: "Numerics", targets: ["Numerics"]),
    .library(name: "RealModule", targets: ["RealModule"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "ComplexModule", dependencies: ["RealModule"]),
    .target(name: "Numerics", dependencies: ["ComplexModule", "RealModule"]),
    .target(name: "RealModule", dependencies: ["_NumericsShims"]),
    
    .target(name: "_NumericsShims", dependencies: []),
    .target(name: "_TestSupport", dependencies: ["Numerics"]),
    
    .testTarget(name: "ComplexTests", dependencies: ["_TestSupport"]),
    .testTarget(name: "RealTests", dependencies: ["_TestSupport"]),
  ]
)
