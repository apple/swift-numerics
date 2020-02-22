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
    .library(name: "Performance", targets: ["Performance"]),
    .library(name: "CorePerformance", targets: ["CorePerformance"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "ComplexModule", dependencies: ["RealModule"]),
    .target(name: "Numerics", dependencies: ["ComplexModule", "RealModule"]),
    .target(name: "_NumericsShims", dependencies: []),
    .target(name: "RealModule", dependencies: ["_NumericsShims"]),
    .target(name: "Performance", dependencies: ["ComplexModule", "RealModule", "CorePerformance"]),
    .target(name: "CorePerformance", dependencies: ["ComplexModule", "RealModule"]),
    .testTarget(name: "ComplexTests", dependencies: ["ComplexModule", "_NumericsShims"]),
    .testTarget(name: "RealTests", dependencies: ["RealModule"]),
    .testTarget(name: "CorePerformanceTests", dependencies: ["CorePerformance", "ComplexModule"]),
    .testTarget(name: "PerformanceTests", dependencies: ["Performance", "ComplexModule"]),
)
