import RealModule
import XCTest

final class ElementaryFunctionTests: XCTestCase {
  
  func testSpecials<T: Real>(tolerance tol: Tolerance<T>) {
    XCTAssertTrue(T.zero.approximatelyEquals(.zero, tolerance: tol))
    XCTAssertTrue( T.zero.approximatelyEquals(-.zero, tolerance: tol))
    XCTAssertTrue((-T.zero).approximatelyEquals(.zero, tolerance: tol))
    XCTAssertTrue((-T.zero).approximatelyEquals(-.zero, tolerance: tol))
    XCTAssertTrue( T.infinity.approximatelyEquals(.infinity, tolerance: tol))
    XCTAssertTrue((-T.infinity).approximatelyEquals(-.infinity, tolerance: tol))
    XCTAssertFalse( T.infinity.approximatelyEquals(.greatestFiniteMagnitude, tolerance: tol))
    XCTAssertFalse( T.greatestFiniteMagnitude.approximatelyEquals(.infinity, tolerance: tol))
    XCTAssertFalse((-T.infinity).approximatelyEquals(-.greatestFiniteMagnitude, tolerance: tol))
    XCTAssertFalse((-T.greatestFiniteMagnitude).approximatelyEquals(-.infinity, tolerance: tol))
    XCTAssertFalse( T.infinity.approximatelyEquals(-.infinity, tolerance: tol))
    XCTAssertFalse((-T.infinity).approximatelyEquals(.infinity, tolerance: tol))
    XCTAssertFalse( T.nan.approximatelyEquals(.nan, tolerance: tol))
  }
  
  func testSpecials<T: Real>(_ type: T.Type) {
    XCTAssertTrue( T.zero.approximatelyEquals(.zero))
    XCTAssertTrue( T.zero.approximatelyEquals(-.zero))
    XCTAssertTrue((-T.zero).approximatelyEquals(.zero))
    XCTAssertTrue((-T.zero).approximatelyEquals(-.zero))
    testSpecials(tolerance: .absolute(T.leastNormalMagnitude))
    testSpecials(tolerance: .absolute(T.greatestFiniteMagnitude))
    testSpecials(tolerance: .relative(T.ulpOfOne))
    testSpecials(tolerance: .relative(T(1).nextDown))
  }
  
  func testDefaults<T: Real>(_ type: T.Type) {
    let e = T.sqrt(.ulpOfOne)
    XCTAssertTrue(T(1).approximatelyEquals(1 + e))
    XCTAssertTrue(T(1).approximatelyEquals(1 - e/2))
    XCTAssertFalse(T(1).approximatelyEquals(1 + 2*e))
    XCTAssertFalse(T(1).approximatelyEquals(1 - e))
    XCTAssertTrue(T(1).approximatelyEquals(1 + e, tolerance: .relative()))
    XCTAssertTrue(T(1).approximatelyEquals(1 - e/2, tolerance: .relative()))
    XCTAssertFalse(T(1).approximatelyEquals(1 + 2*e, tolerance: .relative()))
    XCTAssertFalse(T(1).approximatelyEquals(1 - e, tolerance: .relative()))
    XCTAssertTrue(T(1).approximatelyEquals((1 + e).nextDown, tolerance: .absolute(e)))
    XCTAssertTrue(T(1).approximatelyEquals((1 - e).nextUp, tolerance: .absolute(e)))
    XCTAssertFalse(T(1).approximatelyEquals((1 + e).nextUp, tolerance: .absolute(e)))
    XCTAssertFalse(T(1).approximatelyEquals((1 - e).nextDown, tolerance: .absolute(e)))
  }
  
  func testRandom<T>(_ type: T.Type) where T: FixedWidthFloatingPoint & Real {
    var g = SystemRandomNumberGenerator()
    // Generate a bunch of random values in a small interval and a tolerance
    // and use them to check that various properties that we would like to
    // hold actually do.
    var values = [1] + (0 ..< 64).map { _ in T.random(in: 1 ..< 2, using: &g) } + [2]
    values.sort()
    // We have 66 values in 1 ... 2, so if we use a tolerance of around 1/64,
    // at least some of the pairs will compare equal with tolerance.
    let tol = T.random(in: 1/64 ... 1/32, using: &g)
    // We're going to walk the values in order, validating that some common-
    // sense properties hold.
    for i in values.indices {
      // reflexivity
      XCTAssertTrue(values[i].approximatelyEquals(values[i], tolerance: .absolute(tol)))
      for j in i ..< values.endIndex {
        // commutativity
        XCTAssertTrue(
          values[i].approximatelyEquals(values[j], tolerance: .relative(tol)) ==
          values[j].approximatelyEquals(values[i], tolerance: .relative(tol))
        )
        XCTAssertTrue(
          values[i].approximatelyEquals(values[j], tolerance: .absolute(tol)) ==
          values[j].approximatelyEquals(values[i], tolerance: .absolute(tol))
        )
        // scale invariance for relative comparisons
        let scale = T(
          sign:.plus,
          exponent: T.Exponent.random(in: T.leastNormalMagnitude.exponent ... T.greatestFiniteMagnitude.exponent),
          significand: 1
        )
        XCTAssertTrue(
          (scale*values[i]).approximatelyEquals(scale*values[j], tolerance: .relative(tol)) ==
          (scale*values[j]).approximatelyEquals(scale*values[i], tolerance: .relative(tol))
        )
      }
      // if a ≤ b ≤ c, and a ≈ c, then a ≈ b and b ≈ c
      for t in [Tolerance.relative(tol), .absolute(tol)] {
        guard let left = values.firstIndex(where: {
          values[i].approximatelyEquals($0, tolerance: t)
        }) else { continue }
        let right = values.lastIndex {
          values[i].approximatelyEquals($0, tolerance: t)
        }! // don't need guard because we found left
        for j in left ... right {
          XCTAssertTrue(values[i].approximatelyEquals(values[j], tolerance: t))
        }
      }
    }
  }
  
  func testFloat() {
    testSpecials(Float.self)
    testDefaults(Float.self)
    testRandom(Float.self)
  }
  
  func testDouble() {
    testSpecials(Double.self)
    testDefaults(Double.self)
    testRandom(Double.self)
  }
  
  func testFloat80() {
    testSpecials(Float80.self)
    testDefaults(Float80.self)
    testRandom(Float80.self)
  }
}
