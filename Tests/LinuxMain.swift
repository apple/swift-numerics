import XCTest

@testable import ComplexTests
@testable import RealTests

XCTMain([
    testCase(ArithmeticBenchmarkTests.testDivisionByConstant),
    testCase(ArithmeticBenchmarkTests.testReciprocal),
    testCase(ArithmeticBenchmarkTests.testDivisionByConstantC),
    testCase(ArithmeticBenchmarkTests.testMultiplication),
    testCase(ArithmeticBenchmarkTests.testMultiplicationC),
    testCase(ArithmeticBenchmarkTests.testDivision),
    testCase(ArithmeticBenchmarkTests.testDivisionC),
    testCase(ArithmeticBenchmarkTests.testDivisionPoorScaling),
    testCase(ArithmeticBenchmarkTests.testDivisionPoorScalingC),
    testCase(ArithmeticBenchmarkTests.testMultiplicationPoorScaling),
    testCase(ArithmeticBenchmarkTests.testMultiplicationPoorScalingC),
    testCase(PropertyTests.testProperties),
    testCase(PropertyTests.testEquatableHashable),
    testCase(ArithmeticTests.testPolar),
    testCase(ArithmeticTests.testBaudinSmith),
    testCase(RealTests.testFloat),
    testCase(RealTests.testDouble),
    testCase(RealTests.testFloat80)
])
