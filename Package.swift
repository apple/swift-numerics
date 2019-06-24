// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required
// to build this package.

import PackageDescription

let package = Package(
  name: "swift-numerics",
  products: [
    .library(name: "NumericsShims", targets: ["NumericsShims"]),
    .library(name: "ElementaryFunctions", targets: ["ElementaryFunctions"]),
    .library(name: "Complex", targets: ["Complex"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "NumericsShims", dependencies: []),
    .target(name: "ElementaryFunctions", dependencies: ["NumericsShims"]),
    .target(name: "Complex", dependencies: ["ElementaryFunctions"]),
    
    .testTarget(name: "ElementaryFunctionTests", dependencies: ["ElementaryFunctions"]),
    .testTarget(name: "ComplexTests", dependencies: ["Complex"]),
  ]
)
