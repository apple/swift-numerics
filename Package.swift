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
    .library(name: "Numerics_Complex", targets: ["Numerics_Complex"]),
    .library(name: "Numerics", targets: ["Numerics"]),
    .library(name: "Numerics_Real", targets: ["Numerics_Real"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "Numerics_Complex", dependencies: ["Numerics_Real"]),
    .target(name: "Numerics", dependencies: ["Numerics_Complex", "Numerics_Real"]),
    .target(name: "_Numerics_Shims", dependencies: []),
    .target(name: "Numerics_Real", dependencies: ["_Numerics_Shims"]),
    
    .testTarget(name: "ComplexTests", dependencies: ["Numerics_Complex", "_Numerics_Shims"]),
    .testTarget(name: "RealTests", dependencies: ["Numerics_Real"]),
  ]
)
