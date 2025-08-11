# ``ComplexModule``

Types and operations for working with complex numbers.

## Overview

### Representation

The `Complex` type is generic over an associated `RealType`; complex numbers
are represented as two `RealType` values, the real and imaginary parts of the
number.

```
let z = Complex<Double>(1, 2)
let re = z.real
let im = z.imaginary
```

### Memory layout

A `Complex` value is stored as two `RealType` values arranged consecutively
in memory. Thus it has the same memory layout as:
- A Fortran complex value built on the corresponding real type (as used
by BLAS and LAPACK).
- A C struct with real and imaginary parts and nothing else (as used by
computational libraries predating C99).
- A C99 `_Complex` value built on the corresponding real type.
- A C++ `std::complex` value built on the corresponding real type.
Functions taking complex arguments in these other languages are not
automatically converted on import, but you can safely write shims that
map them into Swift types by converting pointers.

### Real-Complex arithmetic

Because the real numbers are a subset of the complex numbers, many
languages support arithmetic with mixed real and complex operands.
For example, C allows the following:

```c
#include <complex.h>
double r = 1;
double complex z = CMPLX(0, 2); // 2i
double complex w = r + z;       // 1 + 2i
```

The `Complex` type does not provide such mixed operators:

```swift
let r = 1.0
let z = Complex(imaginary: 2.0)
let w = r + z // error: binary operator '+' cannot be applied to operands of type 'Double' and 'Complex<Double>'
```

In order to write the example from C above in Swift, you have to perform an
explicit conversion:

```swift
let r = 1.0
let z = Complex(imaginary: 2.0)
let w = Complex(r) + z // OK
```

There are two reasons for this choice. Most importantly, Swift generally avoids
mixed-type arithmetic. Second, if we _did_ provide such heterogeneous operators,
it would lead to undesirable behavior in common expressions when combined with
literal type inference. Consider the following example:

```swift
let a: Double = 1
let b = 2*a
```

`b` ought to have type `Double`, but if we did have a Complex-by-Real `*` 
operation, `2*a` would either be ambiguous (if there were no type context),
or be inferred to have type `Complex<Double>` (if the expression appeared
in the context of an extension defined on `Complex`).

Note that we _do_ provide heterogeneous multiplication and division by a real
value, spelled as ``Complex/divided(by:)`` and ``Complex/multiplied(by:)``
to avoid ambiguity.

```swift
let z = Complex<Double>(1,3)
let w = z.multiplied(by: 2)
```

These operations are generally more efficient than converting the scale to
a complex number and then using `*` or `/`.
