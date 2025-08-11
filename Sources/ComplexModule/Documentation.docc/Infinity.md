# Zero and infinity

Semantics of `Complex` zero and infinity values, and important considerations
when porting code from other languages.

## Overview

Unlike C and C++'s complex types, `Complex` does not attempt to make a 
semantic distinction between different infinity and NaN values. Any `Complex`
datum with a non-finite component is treated as the "point at infinity" on 
the Riemann sphere--a value with infinite magnitude and unspecified phase.

As a consequence, all values with either component infinite or NaN compare
equal, and hash the same. Similarly, all zero values compare equal and hash
the same.

### Rationale

This choice has some drawbacks,¹ but also some significant advantages.
In particular, complex multiplication is the most common operation performed
with a complex type, and one would like to be able to use the usual naive 
arithmetic implementation, consisting of four real multiplications and two
real additions:

```
(a + bi) * (c + di) = (ac - bd) + (ad + bc)i
```

`Complex` can use this implementation, because we do not differentiate between
infinities and NaN values. C and C++, by contrast, cannot use this
implementation by default, because, for example:

```
(1 + ∞i) * (0 - 2i) = (1*0 - ∞*(-2)) + (1*(-2) + ∞*0)i
                    = (0 - ∞) + (-2 + nan)i
                    = -∞ + nan i
```

`Complex` treats this as "infinity", which is the correct result. C and C++
treat it as a nan value, however, which is incorrect; infinity multiplied
by a non-zero number should be infinity. Thus, C and C++ (by default) must
detect these special cases and fix them up, which makes multiplication a
more computationally expensive operation.²

### Footnotes:
¹ W. Kahan, Branch Cuts for Complex Elementary Functions, or Much Ado
About Nothing's Sign Bit. In A. Iserles and M.J.D. Powell, editors,
_Proceedings The State of Art in Numerical Analysis_, pages 165–211, 1987.

² This can be addressed in C programs by use of the `STDC CX_LIMITED_RANGE`
pragma, which instructs the compiler to simply not care about these cases.
Unfortunately, this pragma is not often used in real C or C++ programs
(though it does see some use in _libraries_). Programmers tend to specify
`-ffast-math` or maybe `-ffinite-math-only` instead, which has other
undesirable consequences.
