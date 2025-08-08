# Swift Numerics
  
## Introduction

Swift Numerics provides a set of modules that support numerical computing in Swift.
These modules fall broadly into two categories:

- API that is too specialized to go into the standard library, but which is sufficiently general to be centralized in a single common package.
- API that is under active development toward possible future inclusion in the standard library.

There is some overlap between these two categories, and an API that begins in the first category may migrate into the second as it matures and new uses are discovered.

Swift Numerics modules are fine-grained.
For example, if you need support for Complex numbers, you can import ComplexModule[^1] as a standalone module:

```swift
import ComplexModule

let z = Complex<Double>.i
```

There is also a top-level `Numerics` module that re-exports the complete public interface of Swift Numerics:

```swift
import Numerics

// The entire Swift Numerics API is now available
```

Swift Numerics modules have minimal dependencies on other projects.

The current modules assume only the availability of the Swift and C standard libraries and the runtime support provided by compiler-rt.

Future expansion may assume the availability of other standard interfaces, such as [BLAS (Basic Linear Algebra Subprograms)](https://en.wikipedia.org/wiki/Basic_Linear_Algebra_Subprograms) and [LAPACK (Linear Algebra Package)](https://en.wikipedia.org/wiki/LAPACK), but modules with more specialized dependencies (or dependencies that are not available on all platforms supported by Swift) belong in a separate package.

Because we intend to make it possible to adopt Swift Numerics modules in the standard library at some future point, Swift Numerics uses the same license and contribution guidelines as the Swift project.

## Using Swift Numerics in your project

To use Swift Numerics in a SwiftPM project:

1. Add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/apple/swift-numerics", from: "1.1.0"),
```

2. Add `Numerics` as a dependency for your target:

```swift
.target(name: "MyTarget", dependencies: [
  .product(name: "Numerics", package: "swift-numerics"),
  "AnotherModule"
]),
```

3. Add `import Numerics` in your source code.

## Source stability

The Swift Numerics package is source stable; version numbers follow [Semantic Versioning](https://semver.org).
The public API of the `swift-numerics` package consists of non-underscored declarations that are marked either `public` or `usableFromInline` in modules re-exported by the top-level `Numerics` module.
Interfaces that aren't part of the public API may continue to change in any release, including patch releases. 

Note that contents of the `_NumericsShims` and `_TestSupport` modules, as well as contents of the `Tests` directory, explicitly are not public API.
The definitions therein may therefore change at whim, and the entire module may be removed in any new release.
If you have a use case that requires underscored operations, please raise an issue to request that they be made public API.

Future minor versions of the package may introduce changes to these rules as needed.

We'd like this package to quickly embrace Swift language and toolchain improvements that are relevant to its mandate.
Accordingly, from time to time, we expect that new versions of this package will require clients to upgrade to a more recent Swift toolchain release.
Requiring a new Swift release will only require a minor version bump.

## Contributing to Swift Numerics

Swift Numerics is a standalone library that is separate from the core Swift project, but it will sometimes act as a staging ground for APIs that will later be incorporated into the Swift Standard Library.
When that happens, such changes will be proposed to the Swift Standard Library using the established evolution process of the Swift project.

Swift Numerics uses GitHub issues to track bugs and features. We use pull requests for development.

### How to propose a new module

1. Raise an issue with the [new module] tag.
2. Raise a PR with an implementation sketch.
3. Once you have some consensus, ask an admin to create a feature branch against which PRs can be raised.
4. When the design has stabilized and is functional enough to be useful, raise a PR to merge the new module to main.

### How to propose a new feature for an existing module

1. Raise an issue with the [enhancement] tag.
2. Raise a PR with your implementation, and discuss the implementation there.
3. Once there is a consensus that the new feature is desirable and the design is suitable, it can be merged.

### How to fix a bug, or make smaller improvements

1. Raise a PR with your change. 
2. Make sure to add test coverage for whatever changes you are making.

### Forums

Questions about how to use Swift Numerics modules, or issues that are not clearly bugs can be discussed in the ["Swift Numerics" section of the Swift forums](https://forums.swift.org/c/related-projects/swift-numerics).

## Modules

1. [`RealModule`](Sources/RealModule/README.md)
2. [`ComplexModule`](Sources/ComplexModule/README.md)

## Future expansion

1. [Large Fixed-Width Integers](https://github.com/apple/swift-numerics/issues/4)
2. [Arbitrary-Precision Integers](https://github.com/apple/swift-numerics/issues/5)
3. [Shaped Arrays](https://github.com/apple/swift-numerics/issues/6)
4. [Decimal Floating-point](https://github.com/apple/swift-numerics/issues/7)

[^1]: The module is named `ComplexModule` instead of `Complex` because Swift is currently unable to use the fully-qualified name for types when a type and module have the same name (discussion here: https://forums.swift.org/t/pitch-fully-qualified-name-syntax/28482).
    This would prevent users of Swift Numerics who don't need generic types from doing things such as:

    ```swift
    import Complex
    // I know I only ever want Complex<Double>, so I shouldn't need the generic parameter.
    typealias Complex = Complex.Complex<Double> // This doesn't work, because name lookup fails.
    ```
    
    For this reason, modules that would have this ambiguity are suffixed with `Module` within Swift Numerics:
    
    ```swift
    import ComplexModule
    // I know I only ever want Complex<Double>, so I shouldn't need the generic parameter.
    typealias Complex = ComplexModule.Complex<Double>
    // But I can still refer to the generic type by qualifying the name if I need it occasionally:
    let a = ComplexModule.Complex<Float>
    ```

    The `Real` module does not contain a `Real` type, but does contain a `Real` protocol.
    Users may want to define their own `Real` type (and possibly re-export the `Real` module)--that is why the suffix is also applied there.
    New modules have to evaluate this decision carefully, but can err on the side of adding the suffix.
    It's expected that most users will simply `import Numerics`, so this isn't an issue for them.
