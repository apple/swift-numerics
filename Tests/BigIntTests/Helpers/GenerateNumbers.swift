//===--- GenerateNumbers.swift --------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

@testable import BigIntModule

internal func generateInts(approximateCount: Int) -> [Int] {
  assert(approximateCount > 0, "[generateInts] Negative 'approximateCount'.")

  var result = [Int]()
  result.append(0)
  result.append(1)
  result.append(-1)

  // 'Int' has smaller range on the positive side, so we will use it to calculate 'step'.
  let approximateCountHalf = approximateCount / 2
  let step = Int.max / approximateCountHalf

  // 1st iteration will append 'Int.min' and 'Int.max'
  for i in 0..<approximateCountHalf {
    let s = i * step

    let fromMax = Int.max - s
    result.append(fromMax)

    let fromMin = Int.min + s
    result.append(fromMin)
  }

  return result
}

internal func generateBigInts(approximateCount: Int,
                              maxWordCount: Int = 3) -> [BigIntPrototype] {
  assert(approximateCount > 0, "[generateBigInts] Negative 'approximateCount'.")
  assert(maxWordCount > 0, "[generateBigInts] Negative 'maxWordCount'.")

  typealias Word = BigIntPrototype.Word
  var result = [BigIntPrototype]()

  result.append(BigIntPrototype(.positive, magnitude: [])) //  0
  result.append(BigIntPrototype(.positive, magnitude: [1])) //  1
  result.append(BigIntPrototype(.negative, magnitude: [1])) // -1

  // All words = Word.max
  for count in 1...maxWordCount {
    let magnitude = Array(repeating: Word.max, count: count)
    result.append(BigIntPrototype(.positive, magnitude: magnitude))
    result.append(BigIntPrototype(.negative, magnitude: magnitude))
  }

  let approximateCountHalf = approximateCount / 2
  var word = Word.max / 2 // Start from half and go up by 1

  for i in 0..<approximateCountHalf {
    let min1WordBecauseWeAlreadyAddedZero = 1
    let wordCount = (i % maxWordCount) + min1WordBecauseWeAlreadyAddedZero

    var words = [Word]()
    for _ in 0..<wordCount {
      words.append(word)
      word += 1
    }

    result.append(BigIntPrototype(.positive, magnitude: words))
    result.append(BigIntPrototype(.negative, magnitude: words))
  }

  return result
}
