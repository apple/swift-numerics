# ``ElementaryFunctions``

 A type that has elementary functions (`sin`, `cos`, etc.) available.

## Overview

An ["elementary function"][elfn] is a function built up from powers, roots,
exponentials, logarithms, trigonometric functions (sin, cos, tan) and
their inverses, and the hyperbolic functions (sinh, cosh, tanh) and their
inverses.

Conformance to this protocol means that all of these building blocks are
available as static functions on the type.

```swift
let x: Float = 1
let y = Float.sin(x) // 0.84147096
```

`ElementaryFunctions` conformance implies `AdditiveArithmetic`, so addition
and subtraction and the `zero` property are also available.

``RealFunctions`` refines this protocol and adds additional functions that
are primarily used with real numbers, such as ``RealFunctions/atan2(y:x:)``
and ``RealFunctions/exp10(_:)``.

``Real`` conforms to `RealFunctions` and `FloatingPoint`, and is the
protocol that you will use most often for generic code.

## Topics

There are a few families of functions defined by `ElementaryFunctions`:

### Exponential functions
- ``exp(_:)``
- ``expMinusOne(_:)``

### Logarithmetic functions
- ``log(_:)``
- ``log(onePlus:)``

### Power and root functions:
- ``pow(_:_:)-9imp6``
- ``pow(_:_:)-2qmul``
- ``sqrt(_:)``
- ``root(_:_:)``

### Trigonometric functions
- ``cos(_:)``
- ``sin(_:)``
- ``tan(_:)``

### Inverse trigonometric functions
- ``acos(_:)``
- ``asin(_:)``
- ``atan(_:)``

### Hyperbolic functions
- ``cosh(_:)``
- ``sinh(_:)``
- ``tanh(_:)``

### Inverse hyperbolic functions
- ``acosh(_:)``
- ``asinh(_:)``
- ``atanh(_:)``

 [elfn]: http://en.wikipedia.org/wiki/Elementary_function
