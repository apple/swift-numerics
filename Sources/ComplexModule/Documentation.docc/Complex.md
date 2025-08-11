# ``Complex``

A Complex number type that conforms to `AlgebraicField`
(so all the normal arithmetic operations are available) and
`ElementaryFunctions` (so all the usual math functions are
available).

A `Complex` value is represented with two `RealType` values, corresponding to
the real and imaginary parts of the number.

You can access these Cartesian components using the real and imaginary
properties.

```swift
let z = Complex(1,-1) //  1 - i
let re = z.real       //  1
let im = z.imaginary  // -1
```

All `Complex` numbers with a non-finite component are treated as a single
"point at infinity," with infinite magnitude and indeterminant phase. Thus,
the real and imaginary parts of an infinity are nan.

```swift
let w = Complex<Double>.infinity
w == -w               // true
let re = w.real       // .nan
let im = w.imag       // .nan
```

See <doc:Infinity> for more details.

The ``magnitude`` property of a complex number is the infinity norm of the
value (a.k.a. “maximum norm” or “Чебышёв norm”). To get the two norm (a.k.a
"Euclidean norm"), use the ``length`` property. See <doc:Magnitude> for more
details.

## Topics 

### Real and imaginary parts

- ``real``
- ``imaginary``
- ``rawStorage``
- ``init(_:_:)``
- ``init(_:)-5aesj``
- ``init(imaginary:)``

### Phase, length and magnitude

- ``magnitude``
- ``length``
- ``lengthSquared``
- ``normalized``
- ``phase``
- ``polar``
- ``init(length:phase:)``

### Scaling by real numbers
- ``multiplied(by:)``
- ``divided(by:)``

### Complex-specific operations
- ``conjugate``

### Classification
- ``isZero``
- ``isSubnormal``
- ``isNormal``
- ``isFinite``
