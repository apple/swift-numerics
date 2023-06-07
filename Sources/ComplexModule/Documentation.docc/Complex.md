# ``Complex``

## Topics

### Real and imaginary parts

A `Complex` value is represented with two `RealType` values, corresponding to
the real and imaginary parts of the number:
```swift
let z = Complex(1,-1) //  1 - i
let re = z.real       //  1
let im = z.imaginary  // -1
```
All `Complex` numbers with a non-finite component is treated as a single
"point at infinity," with infinite magnitude and indeterminant phase. Thus,
the real and imaginary parts of an infinity are nan.
```swift
let w = Complex<Double>.infinity
w == -w               // true
let re = w.real       // .nan
let im = w.imag       // .nan
```
See <doc:Infinity> for more details.

- ``init(_:_:)``
- ``init(_:)-5aesj``
- ``init(imaginary:)``
- ``real``
- ``imaginary``

### Magnitude and norms

See the article <doc:Magnitude> for more details.

- ``magnitude``
- ``length``
- ``lengthSquared``
- ``normalized``

### Polar representations

- ``init(length:phase:)``
- ``phase``
- ``length``
- ``polar``

### Conversions from other types

- ``init(_:)-4csd3``
- ``init(_:)-80jml``
- ``init(exactly:)-767k9``
