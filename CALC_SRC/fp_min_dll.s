/*
    FP_MIN_DLL.S version 1.0.0.0.7
    DLL declarations replacing the obsolete binary "FPLOW.BIN" block.

    Replace the binary/end declaration block at the top of FP_MIN.S with
    this DLL/end block, or rename this file to FP_MIN.S and append the
    high-level routines from the original FP_MIN.S after this block.
*/

dll "fplow.dll"
            proc PASCAL lsfpa(string Single) : "LSFPA"
    integer proc PASCAL ssfpa(var string Single) : "SSFPA"
            proc PASCAL ldfpa(string Double) : "LDFPA"
    integer proc PASCAL sdfpa(var string Double) : "SDFPA"
            proc PASCAL lefpa(string Extended) : "LEFPA"
    integer proc PASCAL sefpa(var string Extended) : "SEFPA"

            proc PASCAL lsfpo(string Single) : "LSFPO"
            proc PASCAL ldfpo(string Double) : "LDFPO"
            proc PASCAL lefpo(string Extended) : "LEFPO"

            proc PASCAL ltof(integer SignedLong) : "LTOF"
    integer proc PASCAL ftol(var integer SignedLong) : "FTOL"

            proc PASCAL fpadd() : "FPADD"
            proc PASCAL fpsub() : "FPSUB"
    integer proc PASCAL fpcmp() : "FPCMP"
            proc PASCAL fpmul() : "FPMUL"
            proc PASCAL fpdiv() : "FPDIV"

    integer proc PASCAL ftoa(var string Target, integer Wide, integer DecP) : "FTOA"
    integer proc PASCAL etoa(var string Target, integer Wide) : "ETOA"
            proc PASCAL atof(string Source) : "SAL_ATOF"
    integer proc PASCAL fpTextParse(var string Target, string Source) : "FPTEXTPARSE"
    integer proc PASCAL fpTextOperation(var string Target, string LeftText,
                                        string RightText, integer Operation) : "FPTEXTOPERATION"
    integer proc PASCAL fpTextFormat(var string Target, string ValueText,
                                     integer Wide, integer Decimals) : "FPTEXTFORMAT"
end
