//===--- ElementaryFunctions.swift ----------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2019-2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

// Implementation goals, in order of priority:
//
// 1. Get the branch cuts right. We should match Kahan's /Much Ado/
//    paper for finite values.
// 2. Have good relative accuracy in the complex norm.
// 3. Preserve sign symmetries where possible.
// 4. Handle the point at infinity consistently with basic operations.
//    This means diverging from what C and C++ do for non-finite inputs.
// 5. Get good componentwise accuracy /when possible/. I don't know how
//    to do that for all of these functions off the top of my head, and
//    I don't think that other libraries have tried to do so in general,
//    so this is a research project. We should not sacrifice 1-4 for it.
//    Note that multiplication and division don't even provide good
//    componentwise relative accuracy, so it's _totally OK_ to not get
//    it for these functions too. But: it's a dynamite long-term research
//    project.
// 6. Give the best performance we can. We should care about performance,
//    but with lower precedence than the other considerations.

import RealModule

// TODO: uncomment conformance once all implementations are provided.
extension Complex /*: ElementaryFunctions */ {
  
  // MARK: - exp-like functions
  
  /// The complex exponential function e^z whose base `e` is the base of the natural logarithm.
  ///
  /// Mathematically, this operation can be expanded in terms of the `Real` operations `exp`,
  /// `cos` and `sin` as follows:
  /// ```
  /// exp(x + iy) = exp(x) exp(iy)
  ///             = exp(x) cos(y) + i exp(x) sin(y)
  /// ```
  /// Note that naive evaluation of this expression in floating-point would be prone to premature
  /// overflow, since `cos` and `sin` both have magnitude less than 1 for most inputs (i.e.
  /// `exp(x)` may be infinity when `exp(x) cos(y)` would not be.
  @inlinable
  public static func exp(_ z: Complex) -> Complex {
    guard z.isFinite else { return z }
    // If x < log(greatestFiniteMagnitude), then exp(x) does not overflow.
    // To protect ourselves against sketchy log or exp implementations in
    // an unknown host library, or slight rounding disagreements between
    // the two, subtract one from the bound for a little safety margin.
    guard z.x < RealType.log(.greatestFiniteMagnitude) - 1 else {
      let halfScale = RealType.exp(z.x/2)
      let phase = Complex(RealType.cos(z.y), RealType.sin(z.y))
      return phase.multiplied(by: halfScale).multiplied(by: halfScale)
    }
    return Complex(.cos(z.y), .sin(z.y)).multiplied(by: .exp(z.x))
  }
  
  @inlinable
  public static func expMinusOne(_ z: Complex) -> Complex {
    // exp(x + iy) - 1 = (exp(x) cos(y) - 1) + i exp(x) sin(y)
    //                   -------- u --------
    // Note that the imaginary part is just the usual exp(x) sin(y);
    // the only trick is computing the real part ("u"):
    //
    // u = exp(x) cos(y) - 1
    //   = exp(x) cos(y) - cos(y) + cos(y) - 1
    //   = (exp(x) - 1) cos(y) + (cos(y) - 1)
    //   = expMinusOne(x) cos(y) + cosMinusOne(y)
    //
    // Note: most implementations of expm1 for complex (e.g. Julia's)
    // factor the real part as follows instead:
    //
    //     exp(x) cosMinuxOne(y) + expMinusOne(x)
    //
    // The other implementation that is sometimes seen is:
    //
    //     expMinusOne(z) = 2*exp(z/2)*sinh(z/2)
    //
    // All three of these implementations provide good relative error
    // bounds _in the complex norm_, but the cosineMinusOne-based
    // implementation has the best _componentwise_ error characteristics,
    // which is why we use it here:
    //
    //     Implementation |        Real        |    Imaginary   |
    //     ---------------+--------------------+----------------+
    //          Ours      |    Hybrid bound    | Relative bound |
    //        Standard    |      No bound      | Relative bound |
    //       Half Angle   |    Hybrid bound    |  Hybrid bound  |
    //
    // FUTURE WORK: devise an algorithm that achieves good _relative_ error
    // in the real component as well. Doing this efficiently is a research
    // project--exp(x) cos(y) - 1 can be very nearly zero along a curve in
    // the complex plane, not only at zero. Evaluating it accurately
    // _without_ depending on arbitrary-precision exp and cos is an
    // interesting challenge.
    guard z.isFinite else { return z }
    // If exp(z) is close to the overflow boundary, we don't need to
    // worry about the "MinusOne" part of this function; we're just
    // computing exp(z). (Even when z.y is near a multiple of π/2,
    // it can't be close enough to overcome the scaling from exp(z.x),
    // so the -1 term is _always_ negligable). So we simply handle
    // these cases exactly the same as exp(z).
    guard z.x < RealType.log(.greatestFiniteMagnitude) - 1 else {
      let halfScale = RealType.exp(z.x/2)
      let phase = Complex(RealType.cos(z.y), RealType.sin(z.y))
      return phase.multiplied(by: halfScale).multiplied(by: halfScale)
    }
    // Special cases out of the way, evaluate as discussed above.
    return Complex(
      RealType._mulAdd(.cos(z.y), .expMinusOne(z.x), .cosMinusOne(z.y)),
      .exp(z.x) * .sin(z.y)
    )
  }
  
  // cosh(x + iy) = cosh(x) cos(y) + i sinh(x) sin(y).
  //
  // Like exp, cosh is entire, so we do not need to worry about where
  // branch cuts fall. Also like exp, cancellation never occurs in the
  // evaluation of the naive expression, so all we need to be careful
  // about is the behavior near the overflow boundary.
  //
  // Fortunately, if |x| >= -log(ulpOfOne), cosh(x) and sinh(x) are
  // both just exp(|x|)/2, and we already know how to compute that.
  //
  // This function and sinh should stay in sync; if you make a
  // modification here, you should almost surely make a parallel
  // modification to sinh below.
  @inlinable @inline(__always)
  public static func cosh(_ z: Complex) -> Complex {
    guard z.isFinite else { return z }
    guard z.x.magnitude < -RealType.log(.ulpOfOne) else {
      let phase = Complex(RealType.cos(z.y), RealType.sin(z.y))
      let firstScale = RealType.exp(z.x.magnitude/2)
      let secondScale = firstScale/2
      return phase.multiplied(by: firstScale).multiplied(by: secondScale)
    }
    // Future optimization opportunity: expm1 is faster than cosh/sinh
    // on most platforms, and division is now commonly pipelined, so we
    // might replace the check above with a much more conservative one,
    // and then evaluate cosh(x) and sinh(x) as
    //
    // cosh(x) = 1 + 0.5*expm1(x)*expm1(x) / (1 + expm1(x))
    // sinh(x) = expm1(x) + 0.5*expm1(x) / (1 + expm1(x))
    //
    // This won't be a _big_ win except on platforms with a crappy sinh
    // and cosh, and for those we should probably just provide our own
    // implementations of _those_, so for now let's keep it simple and
    // obviously correct.
    return Complex(
      RealType.cosh(z.x) * RealType.cos(z.y),
      RealType.sinh(z.x) * RealType.sin(z.y)
    )
  }
  
  // sinh(x + iy) = sinh(x) cos(y) + i cosh(x) sinh(y)
  //
  // See cosh above for algorithm details.
  @inlinable @inline(__always)
  public static func sinh(_ z: Complex) -> Complex {
    guard z.isFinite else { return z }
    guard z.x.magnitude < -RealType.log(.ulpOfOne) else {
      let phase = Complex(RealType.cos(z.y), RealType.sin(z.y))
      let firstScale = RealType.exp(z.x.magnitude/2)
      let secondScale = RealType(signOf: z.x, magnitudeOf: firstScale/2)
      return phase.multiplied(by: firstScale).multiplied(by: secondScale)
    }
    return Complex(
      RealType.sinh(z.x) * RealType.cos(z.y),
      RealType.cosh(z.x) * RealType.sin(z.y)
    )
  }
  
  // tanh(z) = sinh(z) / cosh(z)
  @inlinable
  public static func tanh(_ z: Complex) -> Complex {
    guard z.isFinite else { return z }
    // Note that when |x| is larger than -log(.ulpOfOne),
    // sinh(x + iy) == ±cosh(x + iy), so tanh(x + iy) is just ±1.
    guard z.x.magnitude < -RealType.log(.ulpOfOne) else {
      return Complex(
        RealType(signOf: z.x, magnitudeOf: 1),
        RealType(signOf: z.y, magnitudeOf: 0)
      )
    }
    // Now we have z in a vertical strip where exp(x) is reasonable,
    // and y is finite, so we can simply evaluate sinh(z) and cosh(z).
    //
    // TODO: Kahan uses a different expression for evaluation here; it
    // isn't strictly necessary for numerics reasons--it's to avoid
    // doing the complex division, but it probably provides better
    // componentwise error bounds, and is likely more efficient (because
    // it avoids the complex division, which is painful even when well-
    // scaled). This suffices to get us up and running.
    return sinh(z) / cosh(z)
  }
  
  // cos(z) = cosh(iz)
  public static func cos(_ z: Complex) -> Complex {
    return cosh(Complex(-z.y, z.x))
  }
  
  // sin(z) = -i*sinh(iz)
  public static func sin(_ z: Complex) -> Complex {
    let w = sinh(Complex(-z.y, z.x))
    return Complex(w.y, -w.x)
  }
  
  // tan(z) = -i*tanh(iz)
  public static func tan(_ z: Complex) -> Complex {
    let w = tanh(Complex(-z.y, z.x))
    return Complex(w.y, -w.x)
  }
  
  // MARK: - log-like functions
  @inlinable
  public static func log(_ z: Complex) -> Complex {
    // If z is zero or infinite, the phase is undefined, so the result is
    // the single exceptional value.
    guard z.isFinite && !z.isZero else { return .infinity }
    // Otherwise, try computing lengthSquared; if the result is normal,
    // we can just take its log to get the real part of the result.
    let r2 = z.lengthSquared
    let θ = z.phase
    if r2.isNormal { return Complex(.log(r2)/2, θ) }
    // z is finite, but z.lengthSquared is not normal. Rescale and recompute.
    let w = z.divided(by: z.magnitude)
    return Complex(.log(z.magnitude) + .log(w.lengthSquared)/2, θ)
  }
  
  @inlinable
  public static func log(onePlus z: Complex) -> Complex {
    // Nevin proposed the idea for this implementation on the Swift forums:
    // https://forums.swift.org/t/elementaryfunctions-compliance-for-complex/37903/3
    //
    // Here's a quick explainer on why it works: in exact arithmetic,
    //
    //      log(1+z) = (log |1+z|, atan2(y, 1+x))
    //
    // where x and y are the real and imaginary parts of z, respectively.
    //
    // The first thing to note is that the expression for the imaginary
    // part works fine as is. If cancellation occurs (because x ≈ -1),
    // then 1+x is exact, and so we have good componentwise relative
    // accuracy. Otherwise, x is bounded away from -1 and 1+x has good
    // relative accuracy, and therefore so does atan2(y, 1+x).
    //
    // So the real part is the hard part (no surprise, just like expPlusOne).
    // Nevin's clever idea is simply to take advantage of the expansion:
    //
    //     Re(log 1+z) = (log 1+z + Conj(log 1+z))/2
    //
    // Log commutes with conjugation, so this becomes:
    //
    //     Re(log 1+z) = (log 1+z + log 1+z̅)/2
    //                 = log((1+z)(1+z̅)/2
    //                 = log(1+z+z̅+zz̅)/2
    //
    // This behaves well close to zero, because the z+z̅ term dominates
    // and is computed exactly. Away from zero, cancellation occurs near
    // the circle x(x+2) + y^2 = 0, but everywhere along this curve we
    // have |Im(log 1+z)| >= π/2, so the relative error in the complex
    // norm is well-controlled. We can take advantage of FMA to further
    // reduce the cancellation error and recover a good error bound.
    //
    // The other common implementation choice for log1p is Kahan's trick:
    //
    //     w := 1+z
    //     return z/(w-1) * log(w)
    //
    // But this actually doesn't do as well as Nevin's approach does,
    // and requires a complex division, which we want to avoid when we
    // can do so.
    var a = 2*z.x
    // We want to add the larger term first (contra usual guidance for
    // floating-point error optimization), because we're optimizing for
    // the catastrophic cancellation case; when that happens adding the
    // larger term via FMA is always exact. When cancellation doesn't
    // happen, the simple relative error bound carries through the
    // rest of the computation.
    let large = max(z.x.magnitude, z.y.magnitude)
    let small = min(z.x.magnitude, z.y.magnitude)
    a.addProduct(large, large)
    a.addProduct(small, small)
    // If r2 overflowed, then |z| ≫ 1, and so log(1+z) = log(z).
    guard a.isFinite else { return log(z) }
    // Unlike log(z), we do not need to worry about what happens if a
    // underflows.
    return Complex(
      RealType.log(onePlus: a)/2,
      RealType.atan2(y: z.y, x: 1+z.x)
    )
  }
  
  public static func acos(_ z: Complex) -> Complex {
    fatalError()
  }
  
  // asin(z) = -i*asinh(iz)
  public static func asin(_ z: Complex) -> Complex {
    let w = asinh(Complex(-z.y, z.x))
    return Complex(w.y, -w.x)
  }
  
  // atan(z) = -i*atanh(iz)
  public static func atan(_ z: Complex) -> Complex {
    let w = atanh(Complex(-z.y, z.x))
    return Complex(w.y, -w.x)
  }
  
  public static func acosh(_ z: Complex) -> Complex {
    fatalError()
  }
  
  public static func asinh(_ z: Complex) -> Complex {
    fatalError()
  }
  
  public static func atanh(_ z: Complex) -> Complex {
    fatalError()
  }
  
  // MARK: - pow-like functions
  public static func pow(_ z: Complex, _ w: Complex) -> Complex {
    return exp(w * log(z))
  }
  
  public static func pow(_ z: Complex, _ n: Int) -> Complex {
    if z.isZero { return .zero }
    // TODO: this implementation is not quite correct, because n may be
    // rounded in conversion to RealType. This only effects very extreme
    // cases, so we'll leave it alone for now.
    //
    // Note that this does not have the same problems that a similar
    // implementation for a real type would have, because there's no
    // parity/sign interaction in the complex plane.
    return exp(log(z).multiplied(by: RealType(n)))
  }
  
  public static func sqrt(_ z: Complex) -> Complex {
    let lengthSquared = z.lengthSquared
    if lengthSquared.isNormal {
      // If |z|^2 doesn't overflow, then define u and v by:
      //
      //    u = sqrt((|z|+|x|)/2)
      //    v = y/2u
      //
      // If x is positive, the result is just w = (u, v). If x is negative,
      // the result is (|v|, copysign(u, y)) instead.
      let norm = RealType.sqrt(lengthSquared)
      let u = RealType.sqrt((norm + abs(z.x))/2)
      let v: RealType = z.y / (2*u)
      if z.x.sign == .plus {
        return Complex(u, v)
      } else {
        return Complex(abs(v), RealType(signOf: z.y, magnitudeOf: u))
      }
    }
    // Handle edge cases:
    if z.isZero { return Complex(0, z.y) }
    if !z.isFinite { return z }
    // z is finite but badly-scaled. Rescale and replay by factoring out
    // the larger of x and y.
    let scale = RealType.maximum(abs(z.x), abs(z.y))
    return Complex.sqrt(z.divided(by: scale)).multiplied(by: .sqrt(scale))
  }
  
  public static func root(_ z: Complex, _ n: Int) -> Complex {
    if z.isZero { return .zero }
    // TODO: this implementation is not quite correct, because n may be
    // rounded in conversion to RealType. This only effects very extreme
    // cases, so we'll leave it alone for now.
    //
    // Note that this does not have the same problems that a similar
    // implementation for a real type would have, because there's no
    // parity/sign interaction in the complex plane.
    return exp(log(z).divided(by: RealType(n)))
  }
}
