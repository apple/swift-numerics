# Numerics Shims

This module provides no stable Swift API.
It is an internal implementation detail of other Swift Numerics modules, providing access to builtins and assembly by wrapping them in static inline C functions.

Within the standard library, this is achieved via the Builtin module instead, but because Swift Numerics is a separate project, it should not be built with the flags that are needed to enable access to the Builtin module.
