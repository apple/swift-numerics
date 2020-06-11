// swift-tools-version:5.0
//===--- Package.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import PackageDescription

let package = Package(
  name: "swift-numerics",
  products: [
    .library(name: "BigIntModule", targets: ["BigIntModule"]),
    .library(name: "Complex", targets: ["Complex"]),
    .library(name: "Numerics", targets: ["Numerics"]),
    .library(name: "Real", targets: ["Real"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "BigIntModule", dependencies: []),
    .target(name: "Complex", dependencies: ["Real"]),
    .target(name: "Numerics", dependencies: ["BigIntModule", "Complex", "Real"]),
    .target(name: "NumericsShims", dependencies: []),
    .target(name: "Real", dependencies: ["NumericsShims"]),
    
    .testTarget(name: "BigIntTests", dependencies: ["BigIntModule"]),
    .testTarget(name: "ComplexTests", dependencies: ["Complex", "NumericsShims"]),
    .testTarget(name: "RealTests", dependencies: ["Real"]),
  ]
)
