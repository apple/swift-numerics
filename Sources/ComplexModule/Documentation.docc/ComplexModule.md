# ``ComplexModule``

Types and operations for working with complex numbers.

## Representation

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

## Real-Complex arithmetic

Because the real numbers are a subset of the complex numbers, many
languages support arithmetic with mixed real and complex operands.
For example, C allows the following:
```c
#include <complex.h>
double r = 1;
double complex z = CMPLX(0, 2); // 2i
double complex w = r + z;       // 1 + 2i
```
The `Complex` type does not provide such mixed operators. There are two
reasons for this choice. First, Swift generally avoids mixed-type
arithmetic, period. Second, mixed-type arithmetic operators lead to
undesirable behavior in common expressions when combined with literal
type inference. Consider the following example:
```swift
let a: Double = 1
let b = 2*a
```
If we had a heterogeneous `*` operator defined, then if there's no prevailing
type context (i.e. we aren't in an extension on some type), the expression
`2*a` is ambiguous; `2` could be either a `Double` or `Complex<Double>`. In
a `Complex` context, the situation is even worse: `2*a` is inferred to have
type `Complex`.

Therefore, the `Complex` type does not have these operators. In order to write
the example from C above, you would use an explicit conversion:
```swift
import ComplexModule
let r = 1.0
let z = Complex<Double>(0, 2)
let w = Complex(r) + z
```
