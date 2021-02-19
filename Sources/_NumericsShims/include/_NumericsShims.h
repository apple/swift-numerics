//===--- NumericsShims.h --------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

#define HEADER_SHIM static inline __attribute__((__always_inline__))

// This header uses most of the libm functions, but we don't want to end up
// exporting the libm declarations to modules that include NumericsShims, so
// we don't want to actually #include <math.h>.
//
// For most of the functions, we can get around this by using __builtin_func
// instead of func, since the compiler knows about these operations, but for
// the non-standard extensions, we need to include our own declarations. This
// is a little bit risky, in that we might end up missing an attribute that
// gets added and effects calling conventions, etc, but that's expected to be
// exceedingly rare.
//
// Still, we'll eventually want to find a better solution to this problem,
// especially if people start using this package on systems that are not
// Darwin or Ubuntu.

// MARK: - math functions for float
HEADER_SHIM float libm_cosf(float x) {
  return __builtin_cosf(x);
}

HEADER_SHIM float libm_sinf(float x) {
  return __builtin_sinf(x);
}

HEADER_SHIM float libm_tanf(float x) {
  return __builtin_tanf(x);
}

HEADER_SHIM float libm_acosf(float x) {
  return __builtin_acosf(x);
}

HEADER_SHIM float libm_asinf(float x) {
  return __builtin_asinf(x);
}

HEADER_SHIM float libm_atanf(float x) {
  return __builtin_atanf(x);
}

HEADER_SHIM float libm_coshf(float x) {
  return __builtin_coshf(x);
}

HEADER_SHIM float libm_sinhf(float x) {
  return __builtin_sinhf(x);
}

HEADER_SHIM float libm_tanhf(float x) {
  return __builtin_tanhf(x);
}

HEADER_SHIM float libm_acoshf(float x) {
  return __builtin_acoshf(x);
}

HEADER_SHIM float libm_asinhf(float x) {
  return __builtin_asinhf(x);
}

HEADER_SHIM float libm_atanhf(float x) {
  return __builtin_atanhf(x);
}

HEADER_SHIM float libm_expf(float x) {
  return __builtin_expf(x);
}

HEADER_SHIM float libm_expm1f(float x) {
  return __builtin_expm1f(x);
}

HEADER_SHIM float libm_logf(float x) {
  return __builtin_logf(x);
}

HEADER_SHIM float libm_log1pf(float x) {
  return __builtin_log1pf(x);
}

HEADER_SHIM float libm_powf(float x, float y) {
  return __builtin_powf(x, y);
}

HEADER_SHIM float libm_cbrtf(float x) {
  return __builtin_cbrtf(x);
}

HEADER_SHIM float libm_atan2f(float y, float x) {
  return __builtin_atan2f(y, x);
}

HEADER_SHIM float libm_erff(float x) {
  return __builtin_erff(x);
}

HEADER_SHIM float libm_erfcf(float x) {
  return __builtin_erfcf(x);
}

HEADER_SHIM float libm_exp2f(float x) {
  return __builtin_exp2f(x);
}

#if __APPLE__
HEADER_SHIM float libm_exp10f(float x) {
  extern float __exp10f(float);
  return __exp10f(x);
}
#endif

HEADER_SHIM float libm_hypotf(float x, float y) {
#if defined(_WIN32)
  extern float _hypotf(float, float);
  return _hypotf(x, y);
#else
  return __builtin_hypotf(x, y);
#endif
}

HEADER_SHIM float libm_tgammaf(float x) {
  return __builtin_tgammaf(x);
}

HEADER_SHIM float libm_log2f(float x) {
  return __builtin_log2f(x);
}

HEADER_SHIM float libm_log10f(float x) {
  return __builtin_log10f(x);
}

#if !defined _WIN32
HEADER_SHIM float libm_lgammaf(float x, int *signp) {
  extern float lgammaf_r(float, int *);
  return lgammaf_r(x, signp);
}
#endif

// MARK: - math functions for double

HEADER_SHIM double libm_cos(double x) {
  return __builtin_cos(x);
}

HEADER_SHIM double libm_sin(double x) {
  return __builtin_sin(x);
}

HEADER_SHIM double libm_tan(double x) {
  return __builtin_tan(x);
}

HEADER_SHIM double libm_acos(double x) {
  return __builtin_acos(x);
}

HEADER_SHIM double libm_asin(double x) {
  return __builtin_asin(x);
}

HEADER_SHIM double libm_atan(double x) {
  return __builtin_atan(x);
}

HEADER_SHIM double libm_cosh(double x) {
  return __builtin_cosh(x);
}

HEADER_SHIM double libm_sinh(double x) {
  return __builtin_sinh(x);
}

HEADER_SHIM double libm_tanh(double x) {
  return __builtin_tanh(x);
}

HEADER_SHIM double libm_acosh(double x) {
  return __builtin_acosh(x);
}

HEADER_SHIM double libm_asinh(double x) {
  return __builtin_asinh(x);
}

HEADER_SHIM double libm_atanh(double x) {
  return __builtin_atanh(x);
}

HEADER_SHIM double libm_exp(double x) {
  return __builtin_exp(x);
}

HEADER_SHIM double libm_expm1(double x) {
  return __builtin_expm1(x);
}

HEADER_SHIM double libm_log(double x) {
  return __builtin_log(x);
}

HEADER_SHIM double libm_log1p(double x) {
  return __builtin_log1p(x);
}

HEADER_SHIM double libm_pow(double x, double y) {
  return __builtin_pow(x, y);
}

HEADER_SHIM double libm_cbrt(double x) {
  return __builtin_cbrt(x);
}

HEADER_SHIM double libm_atan2(double y, double x) {
  return __builtin_atan2(y, x);
}

HEADER_SHIM double libm_erf(double x) {
  return __builtin_erf(x);
}

HEADER_SHIM double libm_erfc(double x) {
  return __builtin_erfc(x);
}

HEADER_SHIM double libm_exp2(double x) {
  return __builtin_exp2(x);
}

#if __APPLE__
HEADER_SHIM double libm_exp10(double x) {
  extern double __exp10(double);
  return __exp10(x);
}
#endif

HEADER_SHIM double libm_hypot(double x, double y) {
  return __builtin_hypot(x, y);
}

HEADER_SHIM double libm_tgamma(double x) {
  return __builtin_tgamma(x);
}

HEADER_SHIM double libm_log2(double x) {
  return __builtin_log2(x);
}

HEADER_SHIM double libm_log10(double x) {
  return __builtin_log10(x);
}

#if !defined _WIN32
HEADER_SHIM double libm_lgamma(double x, int *signp) {
  extern double lgamma_r(double, int *);
  return lgamma_r(x, signp);
}
#endif

// MARK: - math functions for float80
#if !defined _WIN32 && (defined __i386__ || defined __x86_64__)
HEADER_SHIM long double libm_cosl(long double x) {
  return __builtin_cosl(x);
}

HEADER_SHIM long double libm_sinl(long double x) {
  return __builtin_sinl(x);
}

HEADER_SHIM long double libm_tanl(long double x) {
  return __builtin_tanl(x);
}

HEADER_SHIM long double libm_acosl(long double x) {
  return __builtin_acosl(x);
}

HEADER_SHIM long double libm_asinl(long double x) {
  return __builtin_asinl(x);
}

HEADER_SHIM long double libm_atanl(long double x) {
  return __builtin_atanl(x);
}

HEADER_SHIM long double libm_coshl(long double x) {
  return __builtin_coshl(x);
}

HEADER_SHIM long double libm_sinhl(long double x) {
  return __builtin_sinhl(x);
}

HEADER_SHIM long double libm_tanhl(long double x) {
  return __builtin_tanhl(x);
}

HEADER_SHIM long double libm_acoshl(long double x) {
  return __builtin_acoshl(x);
}

HEADER_SHIM long double libm_asinhl(long double x) {
  return __builtin_asinhl(x);
}

HEADER_SHIM long double libm_atanhl(long double x) {
  return __builtin_atanhl(x);
}

HEADER_SHIM long double libm_expl(long double x) {
  return __builtin_expl(x);
}

HEADER_SHIM long double libm_expm1l(long double x) {
  return __builtin_expm1l(x);
}

HEADER_SHIM long double libm_logl(long double x) {
  return __builtin_logl(x);
}

HEADER_SHIM long double libm_log1pl(long double x) {
  return __builtin_log1pl(x);
}

HEADER_SHIM long double libm_powl(long double x, long double y) {
  return __builtin_powl(x, y);
}

HEADER_SHIM long double libm_cbrtl(long double x) {
  return __builtin_cbrtl(x);
}

HEADER_SHIM long double libm_atan2l(long double y, long double x) {
  return __builtin_atan2l(y, x);
}

HEADER_SHIM long double libm_erfl(long double x) {
  return __builtin_erfl(x);
}

HEADER_SHIM long double libm_erfcl(long double x) {
  return __builtin_erfcl(x);
}

HEADER_SHIM long double libm_exp2l(long double x) {
  return __builtin_exp2l(x);
}

HEADER_SHIM long double libm_hypotl(long double x, long double y) {
  return __builtin_hypotl(x, y);
}

HEADER_SHIM long double libm_tgammal(long double x) {
  return __builtin_tgammal(x);
}

HEADER_SHIM long double libm_log2l(long double x) {
  return __builtin_log2l(x);
}

HEADER_SHIM long double libm_log10l(long double x) {
  return __builtin_log10l(x);
}

HEADER_SHIM long double libm_lgammal(long double x, int *signp) {
  extern long double lgammal_r(long double, int *);
  return lgammal_r(x, signp);
}
#endif

// MARK: - fast mul-add inlines
/// a*b + c evaluated _either_ as two operations or fma, whichever is faster.
HEADER_SHIM float _numerics_muladdf(float a, float b, float c) {
#pragma STDC FP_CONTRACT ON
  return a*b + c;
}

/// a*b + c evaluated _either_ as two operations or fma, whichever is faster.
HEADER_SHIM double _numerics_muladd(double a, double b, double c) {
#pragma STDC FP_CONTRACT ON
  return a*b + c;
}

// No long-double muladd operation, because no one has built an FMA for it
// (except for Itanium, which Swift doesn't support).
