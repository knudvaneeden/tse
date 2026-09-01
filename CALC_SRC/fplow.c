/*
 * FPLOW.DLL 1.0.0.0.7
 * Win32 replacement for the FPLOW.BIN interface used by FP_MIN.S.
 * Target compiler: Borland C++ Compiler 5.5 (bcc32).
 */

#include <windows.h>
#include <float.h>
#include <limits.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DLL_EXPORT __declspec(dllexport)
#define TSE_CALL __pascal
#define SAL_MAX_STRING 255

#pragma pack(push, 1)
typedef struct SalString {
    unsigned short len;
    unsigned char data[SAL_MAX_STRING];
} SalString;
#pragma pack(pop)

static long double fpa = 0.0L;
static long double fpo = 0.0L;

static void read_sal_text(const SalString *source, char *target, int targetSize)
{
    int count;
    if (targetSize <= 0) return;
    if (source == NULL) {
        target[0] = '\0';
        return;
    }
    count = (int) source->len;
    if (count > targetSize - 1) count = targetSize - 1;
    if (count > 0) memcpy(target, source->data, count);
    target[count] = '\0';
}

static int write_sal(SalString *target, int maximum, const void *data, int count)
{
    if (target == NULL || data == NULL || maximum < 0 || count < 0) return 0;
    if (maximum > SAL_MAX_STRING) maximum = SAL_MAX_STRING;
    if (count > maximum) return 0;
    if (count > 0) memcpy(target->data, data, count);
    target->len = (unsigned short) count;
    return 1;
}

static int finite_value(long double value)
{
    return _finite((double) value) != 0;
}

DLL_EXPORT void TSE_CALL lsfpa(const SalString *singleValue)
{
    float value = 0.0F;
    if (singleValue != NULL && singleValue->len >= 4)
        memcpy(&value, singleValue->data, 4);
    fpa = (long double) value;
}

DLL_EXPORT int TSE_CALL ssfpa(SalString *singleValue, int maximum)
{
    float value;
    if (!finite_value(fpa)) return 0;
    value = (float) fpa;
    if (!finite_value((long double) value)) return 0;
    return write_sal(singleValue, maximum, &value, 4);
}

DLL_EXPORT void TSE_CALL ldfpa(const SalString *doubleValue)
{
    double value = 0.0;
    if (doubleValue != NULL && doubleValue->len >= 8)
        memcpy(&value, doubleValue->data, 8);
    fpa = (long double) value;
}

DLL_EXPORT int TSE_CALL sdfpa(SalString *doubleValue, int maximum)
{
    double value;
    if (!finite_value(fpa)) return 0;
    value = (double) fpa;
    if (!_finite(value)) return 0;
    return write_sal(doubleValue, maximum, &value, 8);
}

DLL_EXPORT void TSE_CALL lefpa(const SalString *extendedValue)
{
    fpa = 0.0L;
    if (extendedValue != NULL && extendedValue->len >= 10)
        memcpy(&fpa, extendedValue->data, 10);
}

DLL_EXPORT int TSE_CALL sefpa(SalString *extendedValue, int maximum)
{
    if (!finite_value(fpa)) return 0;
    return write_sal(extendedValue, maximum, &fpa, 10);
}

DLL_EXPORT void TSE_CALL lsfpo(const SalString *singleValue)
{
    float value = 0.0F;
    if (singleValue != NULL && singleValue->len >= 4)
        memcpy(&value, singleValue->data, 4);
    fpo = (long double) value;
}

DLL_EXPORT void TSE_CALL ldfpo(const SalString *doubleValue)
{
    double value = 0.0;
    if (doubleValue != NULL && doubleValue->len >= 8)
        memcpy(&value, doubleValue->data, 8);
    fpo = (long double) value;
}

DLL_EXPORT void TSE_CALL lefpo(const SalString *extendedValue)
{
    fpo = 0.0L;
    if (extendedValue != NULL && extendedValue->len >= 10)
        memcpy(&fpo, extendedValue->data, 10);
}

DLL_EXPORT void TSE_CALL ltof(int signedLong)
{
    fpa = (long double) signedLong;
}

DLL_EXPORT int TSE_CALL ftol(int *signedLong)
{
    if (signedLong == NULL || !finite_value(fpa) ||
        fpa > (long double) LONG_MAX || fpa < (long double) LONG_MIN)
        return 0;
    *signedLong = (int) fpa;
    return 1;
}

DLL_EXPORT void TSE_CALL fpadd(void) { fpa += fpo; }
DLL_EXPORT void TSE_CALL fpsub(void) { fpa -= fpo; }
DLL_EXPORT void TSE_CALL fpmul(void) { fpa *= fpo; }
DLL_EXPORT void TSE_CALL fpdiv(void) { fpa /= fpo; }

DLL_EXPORT int TSE_CALL fpcmp(void)
{
    if (fpa < fpo) return -1;
    if (fpa > fpo) return 1;
    return 0;
}

DLL_EXPORT int TSE_CALL ftoa(SalString *target, int maximum, int wide, int decimalPlaces)
{
    char format[32];
    char result[512];
    int count;
    if (wide < 1 || wide > SAL_MAX_STRING || decimalPlaces < 0 ||
        decimalPlaces > 99 || !finite_value(fpa))
        return 0;
    sprintf(format, "%%%d.%dLf", wide, decimalPlaces);
    sprintf(result, format, fpa);
    count = (int) strlen(result);
    if (count > wide) {
        memset(result, '#', wide);
        result[wide] = '\0';
        count = wide;
    }
    return write_sal(target, maximum, result, count);
}

DLL_EXPORT int TSE_CALL etoa(SalString *target, int maximum, int wide)
{
    char format[32];
    char result[512];
    int precision;
    int count;
    if (wide < 1 || wide > SAL_MAX_STRING || !finite_value(fpa)) return 0;
    precision = wide - 8;
    if (precision < 1) precision = 1;
    if (precision > 18) precision = 18;
    sprintf(format, "%%%d.%dLE", wide, precision);
    sprintf(result, format, fpa);
    count = (int) strlen(result);
    if (count > wide) {
        memset(result, '#', wide);
        result[wide] = '\0';
        count = wide;
    }
    return write_sal(target, maximum, result, count);
}

DLL_EXPORT void TSE_CALL sal_atof(const SalString *source)
{
    char text[SAL_MAX_STRING + 1];
    read_sal_text(source, text, sizeof(text));
    fpa = 0.0L;
    if (sscanf(text, "%Lf", &fpa) != 1)
        fpa = 0.0L;
}

/* Text-based interface used by FP_MIN.S 1.0.0.0.7 and later. */
DLL_EXPORT int TSE_CALL fptextparse(SalString *target, int maximum,
                                    const SalString *source)
{
    char text[SAL_MAX_STRING + 1];
    char result[96];
    long double value;
    read_sal_text(source, text, sizeof(text));
    if (sscanf(text, "%Lf", &value) != 1 || !finite_value(value)) return 0;
    sprintf(result, "%.18Lg", value);
    return write_sal(target, maximum, result, (int) strlen(result));
}

DLL_EXPORT int TSE_CALL fptextoperation(SalString *target, int maximum,
                                        const SalString *leftText,
                                        const SalString *rightText, int operation)
{
    char left[96];
    char right[96];
    char result[96];
    long double leftValue;
    long double rightValue;
    long double answer;
    read_sal_text(leftText, left, sizeof(left));
    read_sal_text(rightText, right, sizeof(right));
    if (sscanf(left, "%Lf", &leftValue) != 1 ||
        sscanf(right, "%Lf", &rightValue) != 1) return 0;
    switch (operation) {
        case 1: answer = leftValue + rightValue; break;
        case 2: answer = leftValue - rightValue; break;
        case 3: answer = leftValue * rightValue; break;
        case 4:
            if (rightValue == 0.0L) return 0;
            answer = leftValue / rightValue;
            break;
        default: return 0;
    }
    if (!finite_value(answer)) return 0;
    sprintf(result, "%.18Lg", answer);
    return write_sal(target, maximum, result, (int) strlen(result));
}

DLL_EXPORT int TSE_CALL fptextformat(SalString *target, int maximum,
                                     const SalString *valueText,
                                     int wide, int decimalPlaces)
{
    char text[96];
    char format[32];
    char result[512];
    long double value;
    int count;
    read_sal_text(valueText, text, sizeof(text));
    if (sscanf(text, "%Lf", &value) != 1 || !finite_value(value) ||
        wide < 1 || wide > SAL_MAX_STRING) return 0;
    if (decimalPlaces >= 0) {
        if (decimalPlaces > 99) return 0;
        sprintf(format, "%%%d.%dLf", wide, decimalPlaces);
        sprintf(result, format, value);
    } else {
        sprintf(format, "%%%d.9LE", wide);
        sprintf(result, format, value);
    }
    count = (int) strlen(result);
    if (count > wide) {
        sprintf(format, "%%%d.9LE", wide);
        sprintf(result, format, value);
        count = (int) strlen(result);
    }
    if (count > wide) return 0;
    return write_sal(target, maximum, result, count);
}

BOOL WINAPI DllEntryPoint(HINSTANCE instance, DWORD reason, LPVOID reserved)
{
    (void) instance;
    (void) reason;
    (void) reserved;
    return TRUE;
}
