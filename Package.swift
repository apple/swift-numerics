// swift-tools-version:5.0
//===--- Package.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2020 Apple Inc. and the Swift Numerics project authors
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
    .library(name: "ComplexModule", targets: ["ComplexModule"]),
    .library(name: "Numerics", targets: ["Numerics"]),
    .library(name: "RealModule", targets: ["RealModule"]),
  ],
  dependencies: [
    .package(url: "https://github.com/attaswift/BigInt.git", from: "3.0.0")
  ],
  targets: [
    .target(name: "BigIntModule", dependencies: []),
    .target(name: "ComplexModule", dependencies: ["RealModule"]),
    .target(name: "Numerics", dependencies: ["ComplexModule", "RealModule"]),
    .target(name: "_NumericsShims", dependencies: []),
    .target(name: "RealModule", dependencies: ["_NumericsShims"]),
    
    .testTarget(name: "BigIntTests", dependencies: ["BigIntModule", "BigInt"]),
    .testTarget(name: "ComplexTests", dependencies: ["ComplexModule", "_NumericsShims"]),
    .testTarget(name: "RealTests", dependencies: ["RealModule"]),
  ]
)
