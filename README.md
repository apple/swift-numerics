# Swift-Numerics
  
## Introduction
Swift-numerics provides a set of modules that support numerical computing in Swift.
These modules fall broadly in two categories:

- API that is too specialized to go into the standard library, but which is sufficiently
general to be centralized in a single common package.
- API that is under active development toward possible future inclusion in the 
standard library.

There is some overlap between these two categories, and API that begins in the first
category may migrate to the second as it matures and new uses are discovered.

Swift-numerics modules are fine-grained; if a user needs support for Complex numbers,
they can import the Complex module without pulling in a module for linear algebra as well.

Swift-numerics modules have minimal dependencies on other projects. It assumes only
the availability of the Swift and C standard libraries, and the runtime support provided
by compiler-rt. Future expansion may assume the availability of other standard
interfaces such as BLAS and LAPACK, but modules with more specialized
dependencies probably belong in a separate package.

## Process
Swift-numerics changes are not expected to go through swift-evolution. For some
modules, swift-numerics may act as a staging area for the standard library, but in
those cases, the expectation is that swift-evolution review will take place at the point
that the module is proposed for inclusion. It's good to keep that process in mind, 
however, and document *why* you're making the decisions that you are, so that
reviewers can refer to those rationales when a module comes up for swift-evolution.

Swift-numerics uses github issues to track bugs and features, and pull requests for
development.

To propose a new module:
1. Raise an issue with the [new module] tag.
2. Raise a PR with an implementation sketch.
3. Once you have some consensus, ask an admin to create a feature branch against
which PRs can be raised.
4. When the design has stabilized and is functional enough to be useful, raise a PR
to merge the new module to master.

To propose a new feature for an existing module:
1. Raise an issue with the [enhancement] tag.
2. Raise a PR with an implementation, and discuss the implementation there.
3. Once there is consensus that the new feature is desirable and the design is suitable,
it can be merged.

To fix a bug, or make smaller improvements:
1. Raise a PR with your change. Be sure to add test coverage for whatever changes you are making.

## Modules
1. [ElementaryFunctions](Sources/ElementaryFunctions/README.md).
2. [Complex](Sources/Complex/README.md).

## Future expansion directions
1. [Approximate Equality](https://github.com/apple/swift-numerics/issues/3)
2. [Large Fixed-Width Integers](https://github.com/apple/swift-numerics/issues/4)
3. [Arbitrary-Precision Integers](https://github.com/apple/swift-numerics/issues/5)
4. [Shaped Arrays](https://github.com/apple/swift-numerics/issues/6)
4. [Decimal Floating-point](https://github.com/apple/swift-numerics/issues/7)
5. [Float16](https://github.com/apple/swift-numerics/issues/8)
