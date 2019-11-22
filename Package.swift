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
    .library(name: "Complex", targets: ["Complex"]),
    .library(name: "Numerics", targets: ["Numerics"]),
    .library(name: "Real", targets: ["Real"]),
    .library(name: "Performance", targets: ["Performance"]),
    .library(name: "CorePerformance", targets: ["CorePerformance"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "Complex", dependencies: ["Real"]),
    .target(name: "Numerics", dependencies: ["Complex", "Real", "Performance"]),
    .target(name: "NumericsShims", dependencies: []),
    .target(name: "Real", dependencies: ["NumericsShims"]),
    .target(name: "Performance", dependencies: ["Complex", "Real", "CorePerformance"]),
    .target(name: "CorePerformance", dependencies: ["Complex", "Real"]),
    
    .testTarget(name: "CorePerformanceTests", dependencies: ["CorePerformance", "Complex"]),
    .testTarget(name: "PerformanceTests", dependencies: ["Performance", "Complex"]),
    .testTarget(name: "ComplexTests", dependencies: ["Complex", "NumericsShims"]),
    .testTarget(name: "RealTests", dependencies: ["Real"]),
  ]
)
