# Swift Numerics
  
## Introduction
Swift Numerics provides a set of modules that support numerical computing in Swift.
These modules fall broadly into two categories:

- API that is too specialized to go into the standard library, but which is sufficiently general to be centralized in a single common package.
- API that is under active development toward possible future inclusion in the standard library.

There is some overlap between these two categories, and API that begins in the first category may migrate to the second as it matures and new uses are discovered.

Swift Numerics modules are fine-grained; if you need support for Complex numbers, you can import ComplexModule¹ without pulling in everything else in the library as well:
```swift
import ComplexModule

let z = Complex<Double>.i
```
However, there is also a top-level `Numerics` module that simply re-exports the complete public interface of swift-numerics:
```swift
import Numerics

// All swift-numerics API is now available
```

Swift Numerics modules have minimal dependencies on other projects.
The current modules assume only the availability of the Swift and C standard libraries and the runtime support provided by compiler-rt.
Future expansion may assume the availability of other standard interfaces such as [BLAS (Basic Linear Algebra Subprograms)](https://en.wikipedia.org/wiki/Basic_Linear_Algebra_Subprograms) and [LAPACK (Linear Algebra Package)](https://en.wikipedia.org/wiki/LAPACK), but modules with more specialized dependencies (or dependencies that are not available on all platforms supported by Swift) belong in a separate package.

Because we intend to make it possible to adopt Swift Numerics modules in the standard library at some future point, Swift Numerics uses the same license and contribution guidelines as the Swift project.

## Using Swift Numerics in your project
To use Swift Numerics in a SwiftPM project, add the following line to the dependencies in your `Package.swift` file:
```swift
.package(url: "https://github.com/apple/swift-numerics", from: "0.0.5"),
```
add `Numerics` as a dependency for your target:
```swift
.target(name: "MyTarget", dependencies: [
  .product(name: "Numerics", package: "swift-numerics"),
  "AnotherModule"
]),
```
and finally, add `import Numerics` in your source code.
    
## Contributing to Swift Numerics
Swift Numerics is a standalone library separate from the core Swift project.
In practice, it will act as a staging ground for some APIs that may eventually be incorporated into the Swift Standard Library, and when that happens such changes will be proposed to the Swift Standard Library using the established evolution process of the Swift project.

Swift Numerics uses GitHub issues to track bugs and features. We use pull requests for development.

To propose a new module:
1. Raise an issue with the [new module] tag.
2. Raise a PR with an implementation sketch.
3. Once you have some consensus, ask an admin to create a feature branch against which PRs can be raised.
4. When the design has stabilized and is functional enough to be useful, raise a PR to merge the new module to master.

To propose a new feature for an existing module:
1. Raise an issue with the [enhancement] tag.
2. Raise a PR with your implementation, and discuss the implementation there.
3. Once there is a consensus that the new feature is desirable and the design is suitable, it can be merged.

To fix a bug, or make smaller improvements:
1. Raise a PR with your change. Be sure to add test coverage for whatever changes you are making.

Questions about how to use Swift Numerics modules, or issues that are not clearly bugs can be discussed in the ["Swift Numerics" section of the Swift forums.](https://forums.swift.org/c/related-projects/swift-numerics)

## Modules
1. [RealModule](Sources/RealModule/README.md)
2. [ComplexModule](Sources/ComplexModule/README.md)
3. [Approximate Equality](Sources/ApproximateEquality/README.md)

## Future expansion
1. [Large Fixed-Width Integers](https://github.com/apple/swift-numerics/issues/4)
2. [Arbitrary-Precision Integers](https://github.com/apple/swift-numerics/issues/5)
3. [Shaped Arrays](https://github.com/apple/swift-numerics/issues/6)
4. [Decimal Floating-point](https://github.com/apple/swift-numerics/issues/7)

## Notes
¹ Swift is currently unable to use the fully-qualified name for types when a type and module have the same name (discussion here: https://forums.swift.org/t/pitch-fully-qualified-name-syntax/28482).
This would prevent users of Swift Numerics who don't need generic types from doing things like:
```swift
import Complex
// I know I only ever want Complex<Double>, so I shouldn't need the generic parameter.
typealias Complex = Complex.Complex<Double> // doesn't work, because name lookup fails.
```
For this reason, modules that would have this ambiguity are suffixed with `Module` within Swift Numerics:
```swift
import ComplexModule
// I know I only ever want Complex<Double>, so I shouldn't need the generic parameter.
typealias Complex = ComplexModule.Complex<Double>
// But I can still refer to the generic type by qualifying the name if I need it occasionally:
let a = ComplexModule.Complex<Float>
```
The `Real` module does not contain a `Real` type, but does contain a `Real` protocol, and users may want to define their own `Real` type (and possibly re-export the `Real` module), so the suffix is also applied there.
 New modules have to evaluate this decision carefully, but can err on the side of adding the suffix.
 It's expected that most users will simply `import Numerics`, so this isn't an issue for them.
