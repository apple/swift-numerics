//===--- PowersOf2.swift --------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

internal typealias PowerOf2<T> = (power: Int, value: T)

/// `1, 2, 4, 8, 16, 32, 64, 128, 256, 512, etc…`
internal func PositivePowersOf2<T: FixedWidthInteger>(
  type: T.Type
) -> [PowerOf2<T>] {
  var result = [PowerOf2<T>]()
  result.reserveCapacity(T.bitWidth)

  var value = T(1)
  var power = 0
  result.append(PowerOf2(power: power, value: value))

  while true {
    let (newValue, overflow) = value.multipliedReportingOverflow(by: 2)
    if overflow {
      return result
    }

    value = newValue
    power += 1
    result.append(PowerOf2(power: power, value: value))
  }
}

/// `-1, -2, -4, -8, -16, -32, -64, -128, -256, -512, etc…`
internal func NegativePowersOf2<T: FixedWidthInteger>(
  type: T.Type
) -> [PowerOf2<T>] {
  assert(T.isSigned)

  var result = [PowerOf2<T>]()
  result.reserveCapacity(T.bitWidth)

  var value = T(-1)
  var power = 0
  result.append(PowerOf2(power: power, value: value))

  while true {
    let (newValue, overflow) = value.multipliedReportingOverflow(by: 2)
    if overflow {
      return result
    }

    value = newValue
    power += 1
    result.append(PowerOf2(power: power, value: value))
  }
}
