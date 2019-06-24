#define HEADER_SHIM static inline __attribute__((__always_inline__))

// MARK: - math functions for float

HEADER_SHIM float swift_cosf(float x) {
  return __builtin_cosf(x);
}

HEADER_SHIM float swift_sinf(float x) {
  return __builtin_sinf(x);
}

HEADER_SHIM float swift_tanf(float x) {
  return __builtin_tanf(x);
}

HEADER_SHIM float swift_acosf(float x) {
  return __builtin_acosf(x);
}

HEADER_SHIM float swift_asinf(float x) {
  return __builtin_asinf(x);
}

HEADER_SHIM float swift_atanf(float x) {
  return __builtin_atanf(x);
}

HEADER_SHIM float swift_coshf(float x) {
  return __builtin_coshf(x);
}

HEADER_SHIM float swift_sinhf(float x) {
  return __builtin_sinhf(x);
}

HEADER_SHIM float swift_tanhf(float x) {
  return __builtin_tanhf(x);
}

HEADER_SHIM float swift_acoshf(float x) {
  return __builtin_acoshf(x);
}

HEADER_SHIM float swift_asinhf(float x) {
  return __builtin_asinhf(x);
}

HEADER_SHIM float swift_atanhf(float x) {
  return __builtin_atanhf(x);
}

HEADER_SHIM float swift_expf(float x) {
  return __builtin_expf(x);
}

HEADER_SHIM float swift_expm1f(float x) {
  return __builtin_expm1f(x);
}

HEADER_SHIM float swift_logf(float x) {
  return __builtin_logf(x);
}

HEADER_SHIM float swift_log1pf(float x) {
  return __builtin_log1pf(x);
}

HEADER_SHIM float swift_powf(float x, float y) {
  return __builtin_powf(x, y);
}

HEADER_SHIM float swift_atan2f(float y, float x) {
  return __builtin_atan2f(y, x);
}

HEADER_SHIM float swift_erff(float x) {
  return __builtin_erff(x);
}

HEADER_SHIM float swift_erfcf(float x) {
  return __builtin_erfcf(x);
}

HEADER_SHIM float swift_exp2f(float x) {
  return __builtin_exp2f(x);
}

HEADER_SHIM float swift_hypotf(float x, float y) {
#if defined(_WIN32)
  extern float _hypotf(float, float);
  return _hypotf(x, y);
#else
  return __builtin_hypotf(x, y);
#endif
}

HEADER_SHIM float swift_gammaf(float x) {
  return __builtin_tgammaf(x);
}

HEADER_SHIM float swift_log2f(float x) {
  return __builtin_log2f(x);
}

HEADER_SHIM float swift_log10f(float x) {
  return __builtin_log10f(x);
}

#if !defined _WIN32
HEADER_SHIM float swift_lgammaf(float x) {
#if __APPLE__
  extern float lgammaf_r(float, int *);
#endif
  int _;
  return lgammaf_r(x, &_);
}
#endif

// MARK: - math functions for double

HEADER_SHIM double swift_cos(double x) {
  return __builtin_cos(x);
}

HEADER_SHIM double swift_sin(double x) {
  return __builtin_sin(x);
}

HEADER_SHIM double swift_tan(double x) {
  return __builtin_tan(x);
}

HEADER_SHIM double swift_acos(double x) {
  return __builtin_acos(x);
}

HEADER_SHIM double swift_asin(double x) {
  return __builtin_asin(x);
}

HEADER_SHIM double swift_atan(double x) {
  return __builtin_atan(x);
}

HEADER_SHIM double swift_cosh(double x) {
  return __builtin_cosh(x);
}

HEADER_SHIM double swift_sinh(double x) {
  return __builtin_sinh(x);
}

HEADER_SHIM double swift_tanh(double x) {
  return __builtin_tanh(x);
}

HEADER_SHIM double swift_acosh(double x) {
  return __builtin_acosh(x);
}

HEADER_SHIM double swift_asinh(double x) {
  return __builtin_asinh(x);
}

HEADER_SHIM double swift_atanh(double x) {
  return __builtin_atanh(x);
}

HEADER_SHIM double swift_exp(double x) {
  return __builtin_exp(x);
}

HEADER_SHIM double swift_expm1(double x) {
  return __builtin_expm1(x);
}

HEADER_SHIM double swift_log(double x) {
  return __builtin_log(x);
}

HEADER_SHIM double swift_log1p(double x) {
  return __builtin_log1p(x);
}

HEADER_SHIM double swift_pow(double x, double y) {
  return __builtin_pow(x, y);
}

HEADER_SHIM double swift_atan2(double y, double x) {
  return __builtin_atan2(y, x);
}

HEADER_SHIM double swift_erf(double x) {
  return __builtin_erf(x);
}

HEADER_SHIM double swift_erfc(double x) {
  return __builtin_erfc(x);
}

HEADER_SHIM double swift_exp2(double x) {
  return __builtin_exp2(x);
}

HEADER_SHIM double swift_hypot(double x, double y) {
  return __builtin_hypot(x, y);
}

HEADER_SHIM double swift_gamma(double x) {
  return __builtin_tgamma(x);
}

HEADER_SHIM double swift_log2(double x) {
  return __builtin_log2(x);
}

HEADER_SHIM double swift_log10(double x) {
  return __builtin_log10(x);
}

#if !defined _WIN32
HEADER_SHIM double swift_lgamma(double x) {
#if __APPLE__
  extern double lgamma_r(double, int *);
#endif
  int _;
  return lgamma_r(x, &_);
}
#endif

// MARK: - math functions for float80
#if !defined _WIN32 && (defined __i386__ || defined __x86_64__)
HEADER_SHIM long double swift_cosl(long double x) {
  return __builtin_cosl(x);
}

HEADER_SHIM long double swift_sinl(long double x) {
  return __builtin_sinl(x);
}

HEADER_SHIM long double swift_tanl(long double x) {
  return __builtin_tanl(x);
}

HEADER_SHIM long double swift_acosl(long double x) {
  return __builtin_acosl(x);
}

HEADER_SHIM long double swift_asinl(long double x) {
  return __builtin_asinl(x);
}

HEADER_SHIM long double swift_atanl(long double x) {
  return __builtin_atanl(x);
}

HEADER_SHIM long double swift_coshl(long double x) {
  return __builtin_coshl(x);
}

HEADER_SHIM long double swift_sinhl(long double x) {
  return __builtin_sinhl(x);
}

HEADER_SHIM long double swift_tanhl(long double x) {
  return __builtin_tanhl(x);
}

HEADER_SHIM long double swift_acoshl(long double x) {
  return __builtin_acoshl(x);
}

HEADER_SHIM long double swift_asinhl(long double x) {
  return __builtin_asinhl(x);
}

HEADER_SHIM long double swift_atanhl(long double x) {
  return __builtin_atanhl(x);
}

HEADER_SHIM long double swift_expl(long double x) {
  return __builtin_expl(x);
}

HEADER_SHIM long double swift_expm1l(long double x) {
  return __builtin_expm1l(x);
}

HEADER_SHIM long double swift_logl(long double x) {
  return __builtin_logl(x);
}

HEADER_SHIM long double swift_log1pl(long double x) {
  return __builtin_log1pl(x);
}

HEADER_SHIM long double swift_powl(long double x, long double y) {
  return __builtin_powl(x, y);
}

HEADER_SHIM long double swift_atan2l(long double y, long double x) {
  return __builtin_atan2l(y, x);
}

HEADER_SHIM long double swift_erfl(long double x) {
  return __builtin_erfl(x);
}

HEADER_SHIM long double swift_erfcl(long double x) {
  return __builtin_erfcl(x);
}

HEADER_SHIM long double swift_exp2l(long double x) {
  return __builtin_exp2l(x);
}

HEADER_SHIM long double swift_hypotl(long double x, long double y) {
  return __builtin_hypotl(x, y);
}

HEADER_SHIM long double swift_gammal(long double x) {
  return __builtin_tgammal(x);
}

HEADER_SHIM long double swift_log2l(long double x) {
  return __builtin_log2l(x);
}

HEADER_SHIM long double swift_log10l(long double x) {
  return __builtin_log10l(x);
}

HEADER_SHIM long double swift_lgammal(long double x) {
  extern long double lgammal_r(long double, int *);
  int _;
  return lgammal_r(x, &_);
}
#endif
