# Transformation

`Rotation.swift` encapsulates an API for working with other forms of rotation representations, such as *Angle/Axis*, *Polar* or *Rotation Vector*. The API provides conversion from these representations to `Quaternion` and vice versa. Additionally, the API provides a method to directly rotate an arbitrary vector by a quaternion and thus avoids the calculation of an intermediate representation to any other form in the process.

## Policies
 - zero and non-finite quaternions have an indeterminate angle and axis. Thus,
   the `angle` property of `.zero` or `.infinity` is `RealType.nan`, and the
   `axis` property of `.zero` or `.infinity` is `.nan` in all lanes.
 - Quaternions with `angle == .zero` have an indeterminate axis. Thus, the
   `axis` property is `.nan` in all lanes.
