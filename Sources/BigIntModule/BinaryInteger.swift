extension BinaryInteger {
  @inlinable
  internal mutating func _invert() {
    self = ~self
  }
}
