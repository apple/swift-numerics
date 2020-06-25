# Transformation

In computer science, quaternions are frequently used to represent three-dimensional rotations; as quaternions have some [advantages over other representations][advantages].

`Transformation.swift` encapsulates an API to interact with the three-dimensional transformation properties of quaternions. It provides conversions to and from other rotation representations, namely [*Angle-Axis*][angle_axis_wiki], [*Rotation Vector*][rotation_vector_wiki] and [*Polar decomposition*][polar_wiki], as well as it provides methods to directly transform arbitrary vectors by quaternions.

## Policies

- zero and non-finite quaternions have indeterminate transformation properties and can not be converted to other representations. Thus, 
  
    - The `angle` of `.zero` or `.infinity` is `RealType.nan`. 
    - The `axis` of `.zero` or `.infinity` is `RealType.nan` in all lanes.
    - The `rotationVector` of `.zero` or `.infinity` is `RealType.nan` in all lanes.
		- The polar `phase` of `.zero` or `.infinity` is `RealType.nan`

- Quaternions with an `angle` of `.zero` have an indeterminate rotation axis. Thus,

    - the `axis` of `angle == .zero` is `RealType.nan` in all lanes.
    - the `rotationVector` of `angle == .zero` is `RealType.nan` in all lanes.


[advantages]: https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Advantages_of_quaternions
[angle_axis_wiki]: https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Recovering_the_axis-angle_representation
[polar_wiki]: https://en.wikipedia.org/wiki/Polar_decomposition#Quaternion_polar_decomposition
[rotation_vector_wiki]: https://en.wikipedia.org/wiki/Axis–angle_representation#Rotation_vector
