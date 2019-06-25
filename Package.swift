// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "swift-numerics",
  products: [
    .library(name: "Complex", targets: ["Complex"]),
    .library(name: "ElementaryFunctions", targets: ["ElementaryFunctions"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "Complex", dependencies: ["ElementaryFunctions"]),
    .target(name: "ElementaryFunctions", dependencies: ["NumericsShims"]),
    .target(name: "NumericsShims", dependencies: []),
    
    .testTarget(name: "ComplexTests", dependencies: ["Complex"]),
    .testTarget(name: "ElementaryFunctionTests", dependencies: ["ElementaryFunctions"]),
  ]
)
