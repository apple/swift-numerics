#include <complex.h>
// double complex
typedef struct {
    double real;
    double imag;
} _CCD;
_CCD _cexp(_CCD z) {
    double complex cz = cexp(CMPLX(z.real, z.imag));
    return (_CCD){ creal(cz), cimag(cz) };
}
_CCD _clog(_CCD z) {
    double complex cz = clog(CMPLX(z.real, z.imag));
    return (_CCD){ creal(cz), cimag(cz) };
}
_CCD _cpow(_CCD z, _CCD w) {
    double complex cz = cpow(CMPLX(z.real, z.imag), CMPLX(w.real, w.imag));
    return (_CCD){ creal(cz), cimag(cz) };
}
_CCD _csqrt(_CCD z) {
    double complex cz = csqrt(CMPLX(z.real, z.imag));
    return (_CCD){ creal(cz), cimag(cz) };
}
_CCD _csin(_CCD z) {
    double complex cz = csin(CMPLX(z.real, z.imag));
    return (_CCD){ creal(cz), cimag(cz) };
}
_CCD _ccos(_CCD z) {
    double complex cz = ccos(CMPLX(z.real, z.imag));
    return (_CCD){ creal(cz), cimag(cz) };
}
_CCD _ctan(_CCD z) {
    double complex cz = ctan(CMPLX(z.real, z.imag));
    return (_CCD){ creal(cz), cimag(cz) };
}
_CCD _casin(_CCD z) {
    double complex cz = casin(CMPLX(z.real, z.imag));
    return (_CCD){ creal(cz), cimag(cz) };
}
_CCD _cacos(_CCD z) {
    double complex cz = cacos(CMPLX(z.real, z.imag));
    return (_CCD){ creal(cz), cimag(cz) };
}
_CCD _catan(_CCD z) {
    double complex cz = catan(CMPLX(z.real, z.imag));
    return (_CCD){ creal(cz), cimag(cz) };
}
_CCD _csinh(_CCD z) {
    double complex cz = csinh(CMPLX(z.real, z.imag));
    return (_CCD){ creal(cz), cimag(cz) };
}
_CCD _ccosh(_CCD z) {
    double complex cz = ccosh(CMPLX(z.real, z.imag));
    return (_CCD){ creal(cz), cimag(cz) };
}
_CCD _ctanh(_CCD z) {
    double complex cz = ctanh(CMPLX(z.real, z.imag));
    return (_CCD){ creal(cz), cimag(cz) };
}
_CCD _casinh(_CCD z) {
    double complex cz = casinh(CMPLX(z.real, z.imag));
    return (_CCD){ creal(cz), cimag(cz) };
}
_CCD _cacosh(_CCD z) {
    double complex cz = cacosh(CMPLX(z.real, z.imag));
    return (_CCD){ creal(cz), cimag(cz) };
}
_CCD _catanh(_CCD z) {
    double complex cz = catanh(CMPLX(z.real, z.imag));
    return (_CCD){ creal(cz), cimag(cz) };
}
// float complex
typedef struct {
    float real;
    float imag;
} _CCF;
_CCF _cexpf(_CCF z) {
    float complex cz = cexpf(CMPLXF(z.real, z.imag));
    return (_CCF){ crealf(cz), cimagf(cz) };
}
_CCF _clogf(_CCF z) {
    float complex cz = clogf(CMPLXF(z.real, z.imag));
    return (_CCF){ crealf(cz), cimagf(cz) };
}
_CCF _cpowf(_CCF z, _CCF w) {
    float complex cz = cpowf(CMPLXF(z.real, z.imag), CMPLXF(w.real, w.imag));
    return (_CCF){ crealf(cz), cimagf(cz) };
}
_CCF _csqrtf(_CCF z) {
    float complex cz = csqrtf(CMPLXF(z.real, z.imag));
    return (_CCF){ crealf(cz), cimagf(cz) };
}
_CCF _csinf(_CCF z) {
    float complex cz = csinf(CMPLXF(z.real, z.imag));
    return (_CCF){ crealf(cz), cimagf(cz) };
}
_CCF _ccosf(_CCF z) {
    float complex cz = ccosf(CMPLXF(z.real, z.imag));
    return (_CCF){ crealf(cz), cimagf(cz) };
}
_CCF _ctanf(_CCF z) {
    float complex cz = ctanf(CMPLXF(z.real, z.imag));
    return (_CCF){ crealf(cz), cimagf(cz) };
}
_CCF _casinf(_CCF z) {
    float complex cz = casinf(CMPLXF(z.real, z.imag));
    return (_CCF){ crealf(cz), cimagf(cz) };
}
_CCF _cacosf(_CCF z) {
    float complex cz = cacosf(CMPLXF(z.real, z.imag));
    return (_CCF){ crealf(cz), cimagf(cz) };
}
_CCF _catanf(_CCF z) {
    float complex cz = catanf(CMPLXF(z.real, z.imag));
    return (_CCF){ crealf(cz), cimagf(cz) };
}
_CCF _csinhf(_CCF z) {
    float complex cz = csinhf(CMPLXF(z.real, z.imag));
    return (_CCF){ crealf(cz), cimagf(cz) };
}
_CCF _ccoshf(_CCF z) {
    float complex cz = ccoshf(CMPLXF(z.real, z.imag));
    return (_CCF){ crealf(cz), cimagf(cz) };
}
_CCF _ctanhf(_CCF z) {
    float complex cz = ctanhf(CMPLXF(z.real, z.imag));
    return (_CCF){ crealf(cz), cimagf(cz) };
}
_CCF _casinhf(_CCF z) {
    float complex cz = casinhf(CMPLXF(z.real, z.imag));
    return (_CCF){ crealf(cz), cimagf(cz) };
}
_CCF _cacoshf(_CCF z) {
    float complex cz = cacoshf(CMPLXF(z.real, z.imag));
    return (_CCF){ crealf(cz), cimagf(cz) };
}
_CCF _catanhf(_CCF z) {
    float complex cz = catanhf(CMPLXF(z.real, z.imag));
    return (_CCF){ crealf(cz), cimagf(cz) };
}
