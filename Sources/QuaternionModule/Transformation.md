# Transformation

`Transformation.swift` encapsulates an API for working with other representations of transformations, such as [*Angle-Axis*][angle_axis_wiki], [*Polar*][polar_wiki] and [*Rotation Vector*][rotation_vector_wiki]. The API provides operations to convert from these representations to `Quaternion` and vice versa.  
Additionally, the API provides a method to directly rotate an arbitrary vector by a quaternion and thus avoids the calculation of an intermediate representation to any other form in the process.

## Policies

- zero and non-finite quaternions have indeterminate transformation properties and can not be converted to another representation. Thus, 
  
    - The `angle` property of `.zero` or `.infinity` is `RealType.nan`. 
    - The `axis` property of `.zero` or `.infinity` is `RealType.nan` in all lanes.
    - The `rotationVector` property of `.zero` or `.infinity` is `RealType.nan` in all lanes.

- Quaternions with `angle == .zero` have an indeterminate axis. Thus,

    - the `axis` property of `angle == .zero` is `RealType.nan` in all lanes.
    - the `rotationVector` property of `angle == .zero` is `RealType.nan` in all lanes.


[angle_axis_wiki]: https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Recovering_the_axis-angle_representation
[polar_wiki]: https://en.wikipedia.org/wiki/Polar_decomposition#Quaternion_polar_decomposition
[rotation_vector_wiki]: https://en.wikipedia.org/wiki/Axis–angle_representation#Rotation_vector

