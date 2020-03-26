# Approximate Equality

[SE-0259] proposed an API for "Approximate Equality for Floating Point" that would allow floating point values
to be tested for equality within an approximate tolerance. It was returned for revision to account for feedback
during the review and to provide a more uniform handling of zero (Details: [Forums Post](forums)).  
`ApproximateEquality` provides that API as a separate module so that you can evaluate and refine it and to find the
best approach to that API before going through another evolution proposal.

[SE-0259]: https://github.com/apple/swift-evolution/blob/master/proposals/0259-approximately-equal.md
[forums]: https://forums.swift.org/t/se-0259-approximate-equality-for-floating-point/23627