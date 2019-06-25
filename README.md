# Swift-Numerics
  
## Introduction
Swift-numerics provides a set of modules that support numerical computing in Swift.
These modules fall broadly in two categories:
- API that is too specialized to go into the standard library, but which is sufficiently
general to be centralized in a single common package.
- API that is under active development toward future inclusion in the standard library
itself.
There is, of course, some overlap between these two categories, and API that begins 
in the first category may migrate towards the second as it matures.

There are two initial modules that we are seeding the package with, and plans for further
extension in the next few months. Proposals for modifications and additional content are
welcome, some discussion of that process will appear in this document as well.

## Process
Swift-numerics uses github issues to track bugs and features and pull requests for
development.

To propose a new module:
1. Raise an issue with the [new module] tag.
2. Raise a PR with an implementation sketch.
3. Iterate on the design, working with the community.
4. Once there is consensus on the basic design, we'll create a feature branch on which
further cooperative work can continue.
5. Once the basic design has stabilized and is functional enough to be generally useful,
raise a PR to merge the feature onto master.

To propose a new feature for an existing module:
1. Raise an issue with the [enhancement] tag.
2. Raise a PR with an implementation sketch.
3. Iterate on the design, working with the community.
4. Once you establish consensus that the change is wanted, we will merge it to master.

To fix a bug, or make smaller improvements:
1. Raise a PR with your change. Be sure to add test coverage for whatever changes you are making.

## Initial Modules
1. [ElementaryFunctions](#elfcn)
2. [Complex](#complex)

<a name="elfcn">

## Elementary Functions
This module implements [SE-0246].
It is being implemented here first to work around a few difficulties that we encountered
in adding these operations to the standard library:

- Swift does not yet have a way to back-deploy protocol conformances; this prevents
us from making this useful feature available on older Apple OS targets.

- The lack of means to back-deploy prevented us from obsoleting the existing concrete
math functions defined in the Darwin (Apple platforms), Glibc (Linux), and MSVCRT
(Windows) modules.

- There is an outstanding bug with name resolution, which causes the new static functions
(`Float.sin`) to shadow the existing free functions (`sin(_ x: Float) -> Float`) even
in contexts where static functions are not allowed, leading to a number of spurious errors.
See https://github.com/apple/swift/pull/25316 for discussion of how to fix this.

- There are some typechecker performance regressions (partially resulting from the issues
described above).

Placing this module in swift-numerics first gives the community a chance to address
some of the compiler limitations that this feature ran into *before* we land it in the standard
library (avoiding unnecessary source churn for projects that use these features), while also
making it available *right now*, including back-deployment to older Apple OS targets.

It also gives us a chance to iterate on the design and make changes that the community
decides are appropriate before locking in the ABI. We do not expect that major changes
will result from this process, but we may add or remove a few functions, add some 
constants, or modify names to improve clarity in use.

Further details can be found in the [SE-0246 proposal document][SE-0246] and in the
[`ElementaryFunctions` module](Sources/ElementaryFunctions/README.md).

[SE-0246]: https://github.com/apple/swift-evolution/blob/master/proposals/0246-mathable.md

### Dependencies:
- The C standard math library (`libm`) via the `NumericShims` module.

<a name="complex">
  
## Complex
This module provides a `Complex` number type generic over an underlying `RealType`:
```swift
public struct Complex<RealType> where RealType: Real {
  // ...
}
```
This module provides approximate feature parity and memory layout compatibility with C,
Fortran, and C++ complex types (although the importer cannot map the types for you,
buffers may be reinterpreted to shim API defined in other languages).

The usual arithmetic operators are provided for Complex numbers, as well as
multiplication and division of real-by-complex and conversion to and from polar
coordinates and many useful properties, plus conformances to the obvious usual
protocols: `Equatable`, `Hashable`, `Codable` (if the underlying `RealType` is),
`Numeric` (and hence `AdditiveArithmetic`).

Further details may be found in the [`Complex` module](Sources/Complex/README.md).

Additional work: https://github.com/apple/swift-numerics/issues/2

### Dependencies:
- The `ElementaryFunctions` module.

## Future expansion
1. [Approximate Equality](#approx)
2. [Large Integers](#bignum)
3. [Shaped Arrays](#shapedArray)
4. [Decimal Floating-point](#decimal)
5. [Float16](#fp16)

<a name="approx">

## Approximate Equality
https://github.com/apple/swift-numerics/issues/3

<a name="bignum">

## Large Integers
https://github.com/apple/swift-numerics/issues/4
https://github.com/apple/swift-numerics/issues/5

<a name="shapedArray">

## Shaped Arrays
https://github.com/apple/swift-numerics/issues/6

<a name="decimal">

## Decimal Floating-point
https://github.com/apple/swift-numerics/issues/7

<a name="fp16">

## Float16
https://github.com/apple/swift-numerics/issues/8
