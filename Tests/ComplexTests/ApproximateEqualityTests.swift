import Numerics
import XCTest

final class ElementaryFunctionTests: XCTestCase {
  
  func testSpecials<T: Real>(absolute tol: T) {
    let zero = Complex<T>.zero
    let inf = Complex<T>.infinity
    XCTAssertTrue(zero.isApproximatelyEqual(to: zero, absoluteTolerance: tol))
    XCTAssertTrue(zero.isApproximatelyEqual(to:-zero, absoluteTolerance: tol))
    XCTAssertTrue((-zero).isApproximatelyEqual(to: zero, absoluteTolerance: tol))
    XCTAssertTrue((-zero).isApproximatelyEqual(to:-zero, absoluteTolerance: tol))
    // Complex has a single point at infinity.
    XCTAssertTrue(inf.isApproximatelyEqual(to: inf, absoluteTolerance: tol))
    XCTAssertTrue(inf.isApproximatelyEqual(to:-inf, absoluteTolerance: tol))
    XCTAssertTrue((-inf).isApproximatelyEqual(to: inf, absoluteTolerance: tol))
    XCTAssertTrue((-inf).isApproximatelyEqual(to:-inf, absoluteTolerance: tol))
  }
  
  func testSpecials<T: Real>(relative tol: T) {
    let zero = Complex<T>.zero
    let inf = Complex<T>.infinity
    XCTAssertTrue(zero.isApproximatelyEqual(to: zero, relativeTolerance: tol))
    XCTAssertTrue(zero.isApproximatelyEqual(to:-zero, relativeTolerance: tol))
    XCTAssertTrue((-zero).isApproximatelyEqual(to: zero, relativeTolerance: tol))
    XCTAssertTrue((-zero).isApproximatelyEqual(to:-zero, relativeTolerance: tol))
    // Complex has a single point at infinity.
    XCTAssertTrue(inf.isApproximatelyEqual(to: inf, relativeTolerance: tol))
    XCTAssertTrue(inf.isApproximatelyEqual(to:-inf, relativeTolerance: tol))
    XCTAssertTrue((-inf).isApproximatelyEqual(to: inf, relativeTolerance: tol))
    XCTAssertTrue((-inf).isApproximatelyEqual(to:-inf, relativeTolerance: tol))
  }
  
  func testSpecials<T: Real>(_ type: T.Type) {
    XCTAssertTrue(Complex<T>.zero.isApproximatelyEqual(to: .zero))
    XCTAssertTrue(Complex<T>.zero.isApproximatelyEqual(to:-.zero))
    testSpecials(absolute: T.zero)
    testSpecials(absolute: T.greatestFiniteMagnitude)
    testSpecials(relative: T.ulpOfOne)
    testSpecials(relative: T(1))
  }
  
  func testFloat() {
    testSpecials(Float.self)
  }
  
  func testDouble() {
    testSpecials(Double.self)
  }
  
  func testFloat80() {
    testSpecials(Float80.self)
  }
}
