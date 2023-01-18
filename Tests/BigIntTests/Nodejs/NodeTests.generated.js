//===--- NodeTests.generated.js -------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

// ========================
// === Generate numbers ===
// ========================

// For 'int' tests we will use 2^33 range.
// If we are using tagged pointer to hide small int inside the pointer, then on
// 64bit platform Int32 is a natural choice. Using Int33 range for tests (linear
// distribution) makes it so that half of the tests are above and half below
// Int32 range.
const pow33 = 8589934592n;
const smiMax = pow33;
const smiMin = -pow33;

/**
 * Small integers.
 * We will return `2 * countButNotReally + 3` values (don't ask).
 *
 * @param {number} countButNotReally
 * @returns {bigint[]}
 */
function generateSmallInts(countButNotReally) {
  const result = [];

  result.push(0n);
  result.push(1n);
  result.push(-1n);

  const count = BigInt(countButNotReally);
  const step = smiMax / count;

  for (let i = BigInt(0); i < countButNotReally; i++) {
    const s = i * step;

    const fromMax = smiMax - s;
    result.push(fromMax);

    const fromMin = smiMin + s;
    result.push(fromMin);
  }

  return result;
}

/// 2^63 − 1 (max signed Int64)
const wordMax = 18446744073709551615n;
const wordMin = 0n;

/**
 * Big integers.
 * We will return `2 * countButNotReally + 5` values (don't ask).
 *
 * @param {number} countButNotReally
 * @returns {bigint[]}
 */
function generateBigInts(countButNotReally) {
  const result = [];

  result.push(0n);
  result.push(1n);
  result.push(-1n);
  result.push(wordMax);
  result.push(-wordMax);

  let word = 2n; // Start from '2' and go up
  const maxWordCount = 3;

  for (let i = 0; i < countButNotReally; i++) {
    const min1WordBecauseWeAlreadyAddedZero = 1
    const wordCount = (i % maxWordCount) + min1WordBecauseWeAlreadyAddedZero;

    let value = 1n;
    for (let j = 0; j < wordCount; j++) {
      value = value * wordMax + word;
      word += 1n;
    }

    result.push(value);
    result.push(-value);
  }

  return result;
}

// =========================
// === Cartesian product ===
// =========================

/**
 * @param {bigint[]} lhsValues
 * @param {bigint[]} rhsValues
 * @returns {{lhs: bigint[], rhs: bigint[]}[]}
 */
function cartesianProduct(lhsValues, rhsValues) {
  const result = [];

  for (const lhs of lhsValues) {
    for (const rhs of rhsValues) {
      result.push({ lhs, rhs });
    }
  }

  return result;
}

// ================
// === Printing ===
// ================

const smallInts = generateSmallInts(10);
const bigInts = generateBigInts(10);

const smallSmallPairs = cartesianProduct(smallInts, smallInts);
const smallBigPairs = cartesianProduct(smallInts, bigInts);
const bigSmallPairs = cartesianProduct(bigInts, smallInts);
const bigBigPairs = cartesianProduct(bigInts, bigInts);

/**
 * @param {string} name
 * @param {(value: bigint) => bigint} op
 */
function printUnaryOperationTests(name, op) {
  function print(name, testFn, values, op) {
    console.log();
    console.log(`  func test_${name}() {`);

    for (const value of values) {
      const expected = op(value);
      console.log(`    ${testFn}(value: "${value}", expecting: "${expected}")`);
    }

    console.log('  }');
  }

  const nameLower = name.toLowerCase();
  const testFn = `self.${nameLower}Test`;

  console.log();
  console.log(`  // MARK: - ${name}`);

  print(`${nameLower}_int`, testFn, smallInts, op);
  print(`${nameLower}_big`, testFn, bigInts, op);
}

/**
 * @param {string} name
 * @param {(lhs: bigint, rhs: bigint) => bigint} op
 */
function printBinaryOperationTests(name, op) {
  function print(name, testFn, values, op) {
    console.log();
    console.log(`  func test_${name}() {`);

    const isDiv = name.startsWith('div') || name.startsWith('mod');

    for (const { lhs, rhs } of values) {
      if (isDiv && rhs == 0n) {
        continue; // Well.. hello there!
      }

      const expected = op(lhs, rhs);
      console.log(`    ${testFn}(lhs: "${lhs}", rhs: "${rhs}", expecting: "${expected}")`);
    }
    console.log('  }');
  }

  const nameLower = name.toLowerCase();
  const testFn = `self.${nameLower}Test`;

  console.log();
  console.log(`  // MARK: - ${name}`);

  print(`${nameLower}_int_int`, testFn, smallSmallPairs, op);
  print(`${nameLower}_int_big`, testFn, smallBigPairs, op);
  print(`${nameLower}_big_int`, testFn, bigSmallPairs, op);
  print(`${nameLower}_big_big`, testFn, bigBigPairs, op);
}

function printDivModTests() {
  function print(name, testFn, values) {
    console.log();
    console.log(`  func test_${name}() {`);

    for (const { lhs, rhs } of values) {
      if (rhs == 0n) {
        continue; // Well.. hello there!
      }

      const div = lhs / rhs;
      const mod = lhs % rhs;
      console.log(`    ${testFn}(lhs: "${lhs}", rhs: "${rhs}", div: "${div}", mod: "${mod}")`);
    }
    console.log('  }');
  }

  const name = 'DivMod';
  const nameLower = 'divMod';
  const testFn = `self.${nameLower}Test`;

  console.log();
  console.log(`  // MARK: - ${name}`);

  print(`${nameLower}_int_int`, testFn, smallSmallPairs);
  print(`${nameLower}_int_big`, testFn, smallBigPairs);
  print(`${nameLower}_big_int`, testFn, bigSmallPairs);
  print(`${nameLower}_big_big`, testFn, bigBigPairs);
}

const exponents = [0n, 1n, 2n, 3n, 5n, 10n];

function printPowerTests() {
  function print(name, testFn, values) {
    console.log();
    console.log(`  func test_${name}() {`);

    for (const value of values) {
      for (const exponent of exponents) {
        const result = value ** exponent;
        console.log(`    ${testFn}(base: "${value}", exponent: ${exponent}, expecting: "${result}")`);
      }
    }
    console.log('  }');
  }

  const name = 'Power';
  const nameLower = 'power';
  const testFn = `self.${nameLower}Test`;

  console.log();
  console.log(`  // MARK: - ${name}`);

  print(`${nameLower}_int`, testFn, smallInts);
  print(`${nameLower}_big`, testFn, bigInts);
}

/**
 *
 * @param {string} name
 * @param {(value: bigint, count: bigint) => bigint} op
 */
function printShiftOperationTests(name, op) {
  function printShiftTest(name, testFn, values, count, op) {
    console.log();
    console.log(`  func test_${name}() {`);

    for (const value of values) {
      const expected = op(value, count);
      console.log(`    ${testFn}(value: "${value}", count: ${count}, expecting: "${expected}")`);
    }

    console.log('  }');
  }

  const nameLower = name.toLowerCase();
  const testFn = `self.shift${name}Test`;

  const lessThanWord = 5n;
  const word = 64n;
  const moreThanWord = 64n + 64n - 7n;

  console.log();
  console.log(`  // MARK: - Shift ${nameLower}`);
  console.log();
  console.log(`  // Following tests assume: assert(Word.bitWidth == 64)`);
  console.log(`  // Even if this is not the case then the tests should still pass.`);

  printShiftTest(`shift${name}_int_lessThanWord`, testFn, smallInts, lessThanWord, op);
  printShiftTest(`shift${name}_int_word`, testFn, smallInts, word, op);
  printShiftTest(`shift${name}_int_moreThanWord`, testFn, smallInts, moreThanWord, op);

  printShiftTest(`shift${name}_big_lessThanWord`, testFn, bigInts, lessThanWord, op);
  printShiftTest(`shift${name}_big_word`, testFn, bigInts, word, op);
  printShiftTest(`shift${name}_big_moreThanWord`, testFn, bigInts, moreThanWord, op);
}

// ============
// === Main ===
// ============

console.log(`\
//===--- NodeTests.generated.swift ----------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//
// Automatically generated. DO NOT EDIT!
// To regenerate:
// node NodeTests.generated.js > NodeTests.generated.swift
//===----------------------------------------------------------------------===//

import XCTest

// swiftlint:disable file_length
// swiftlint:disable line_length
// swiftlint:disable function_body_length

extension NodeTests {`);

printUnaryOperationTests('Plus', (a) => a);
printUnaryOperationTests('Minus', (a) => -a);
printUnaryOperationTests('Invert', (a) => ~a);

printBinaryOperationTests('Add', (a, b) => a + b);
printBinaryOperationTests('Sub', (a, b) => a - b);
printBinaryOperationTests('Mul', (a, b) => a * b);
printBinaryOperationTests('Div', (a, b) => a / b);
printBinaryOperationTests('Mod', (a, b) => a % b);

printDivModTests();
printPowerTests();

printBinaryOperationTests('And', (a, b) => a & b);
printBinaryOperationTests('Or', (a, b) => a | b);
printBinaryOperationTests('Xor', (a, b) => a ^ b);

printShiftOperationTests('Left', (a, b) => a << b);
printShiftOperationTests('Right', (a, b) => a >> b);

console.log('}');
