// euler080.s
// Version: 1.0
// Project Euler - Problem 80: Square root digital expansion
//
// For the first 100 natural numbers, find the total of the digital sums
// of the first 100 decimal digits for all the irrational square roots.
//
// Algorithm: Frazer Jarvis digit-by-digit integer square root.
//   To get 100 decimal digits of sqrt(n), we use the Jarvis algorithm
//   which naturally produces them digit by digit using only integer ops.
//
// All big integers are held as local decimal digit strings (MSB first).
// Max digit string length needed: ~102 chars (well within 255-char limit).
//
// TSE SAL constraints respected:
//   - No integer arrays  (only local string variables + CreateTempBuffer
//                         for workspace buffer ID; buffer lines not needed
//                         here since all bignum state fits in local strings)
//   - No reserved names  (avoided: val, str, old, len, line, text, copy,
//                         delete, insert, find, mark, etc.)
//   - All strings <= 255 chars
//   - 32-bit integers only (used only for small counters and digit values)
//   - Warn() for final answer
//   - CopyToWinClip() only the bare numeric answer
//   - No paste of result into the .s buffer
//   - Version number included

// ---------- global ----------
integer g_total            // accumulator for grand total

// ---------- big-integer helpers ----------
// Big integers represented as decimal digit strings, most-significant first.
// All arithmetic is performed character-by-character.

// Remove leading zeros, keeping at least "0"
string proc TrimLeadZeros(string dstr)
    string tmp[255] = dstr
    while (Length(tmp) > 1) and (tmp[1] == "0")
        tmp = SubStr(tmp, 2, Length(tmp) - 1)
    endwhile
    return(tmp)
end

// Compare two big-integer strings: returns -1 if aa<bb, 0 if equal, 1 if aa>bb
integer proc BigCmp(string aa, string bb)
    string abig[255] = TrimLeadZeros(aa)
    string bbig[255] = TrimLeadZeros(bb)
    integer la = Length(abig)
    integer lb = Length(bbig)
    integer ci = 0
    if la < lb
        return(-1)
    endif
    if la > lb
        return(1)
    endif
    ci = 1
    while ci <= la
        if Asc(abig[ci]) < Asc(bbig[ci])
            return(-1)
        endif
        if Asc(abig[ci]) > Asc(bbig[ci])
            return(1)
        endif
        ci = ci + 1
    endwhile
    return(0)
end

// Add two big-integer strings, return sum string
string proc BigAdd(string aa, string bb)
    string abig[255] = TrimLeadZeros(aa)
    string bbig[255] = TrimLeadZeros(bb)
    string rstr[255] = ""
    integer la = Length(abig)
    integer lb = Length(bbig)
    integer carry = 0
    integer idx_a = la
    integer idx_b = lb
    integer dsum = 0
    string cdig[1] = ""
    while (idx_a >= 1) or (idx_b >= 1) or (carry > 0)
        dsum = carry
        if idx_a >= 1
            dsum = dsum + Asc(abig[idx_a]) - 48
            idx_a = idx_a - 1
        endif
        if idx_b >= 1
            dsum = dsum + Asc(bbig[idx_b]) - 48
            idx_b = idx_b - 1
        endif
        carry = dsum / 10
        dsum = dsum mod 10
        cdig = Chr(dsum + 48)
        rstr = cdig + rstr
    endwhile
    if Length(rstr) == 0
        rstr = "0"
    endif
    return(rstr)
end

// Subtract bbig from abig (abig >= bbig assumed), return result string
string proc BigSub(string aa, string bb)
    string abig[255] = TrimLeadZeros(aa)
    string bbig[255] = TrimLeadZeros(bb)
    string rstr[255] = ""
    integer la = Length(abig)
    integer lb = Length(bbig)
    integer borrow = 0
    integer idx_a = la
    integer idx_b = lb
    integer ddiff = 0
    string cdig[1] = ""
    while idx_a >= 1
        ddiff = Asc(abig[idx_a]) - 48 - borrow
        if idx_b >= 1
            ddiff = ddiff - (Asc(bbig[idx_b]) - 48)
            idx_b = idx_b - 1
        endif
        if ddiff < 0
            ddiff = ddiff + 10
            borrow = 1
        else
            borrow = 0
        endif
        cdig = Chr(ddiff + 48)
        rstr = cdig + rstr
        idx_a = idx_a - 1
    endwhile
    return(TrimLeadZeros(rstr))
end

// Multiply big-integer string by 10 (append one zero)
string proc BigMul10(string aa)
    string abig[255] = TrimLeadZeros(aa)
    if abig == "0"
        return("0")
    endif
    return(abig + "0")
end

// Multiply big-integer string by 100 (append two zeros)
string proc BigMul100(string aa)
    string abig[255] = TrimLeadZeros(aa)
    if abig == "0"
        return("0")
    endif
    return(abig + "00")
end

// ---------- Jarvis digit-by-digit square root ----------
// Returns the first 100 decimal digits of sqrt(nval) as a string
// (digits include the integer part, no decimal point).
//
// Method: run the Jarvis algorithm until b >= 10^101.
// Then b / 10  (drop last char) gives a 101-digit integer whose
// first 100 digits ARE the first 100 decimal digits of sqrt(nval).
//
// Jarvis recurrence (integer only):
//   a = nval * 5,  b = 5
//   while b < 10^101:
//     if a >= b:  a -= b;  b += 10
//     else:       a *= 100;  b = b*10 - 45
//
string proc JarvisSqrt(integer nval)
    string prec_str[255] = "1"   // will become 10^101
    string aval[255] = ""
    string bval[255] = ""
    string bval_tmp[255] = ""
    integer prec_idx = 0
    // Build 10^101  ("1" followed by 101 zeros, total 102 chars <= 255)
    prec_idx = 0
    while prec_idx < 101
        prec_str = prec_str + "0"
        prec_idx = prec_idx + 1
    endwhile
    // Initialise
    aval = Str(nval * 5)   // nval <= 99, so nval*5 <= 495 - fits int32
    bval = "5"
    // Run until bval >= prec_str
    while BigCmp(bval, prec_str) < 0
        if BigCmp(aval, bval) >= 0
            aval = BigSub(aval, bval)
            bval = BigAdd(bval, "10")
        else
            aval = BigMul100(aval)
            bval_tmp = BigMul10(bval)
            bval = BigSub(bval_tmp, "45")
        endif
    endwhile
    // Divide bval by 10: drop last character to get 101-digit result
    bval_tmp = TrimLeadZeros(bval)
    if Length(bval_tmp) > 1
        bval_tmp = SubStr(bval_tmp, 1, Length(bval_tmp) - 1)
    endif
    return(TrimLeadZeros(bval_tmp))
end

// ---------- Sum first 100 digits of a digit string ----------
integer proc SumFirst100Digits(string dstr)
    string trimmed[255] = TrimLeadZeros(dstr)
    integer dsum = 0
    integer klim = 0
    integer kk = 0
    klim = Length(trimmed)
    if klim > 100
        klim = 100
    endif
    kk = 1
    while kk <= klim
        dsum = dsum + Asc(trimmed[kk]) - 48
        kk = kk + 1
    endwhile
    return(dsum)
end

// ---------- Perfect square check ----------
integer proc IsPerfectSquare(integer nv)
    integer rr = 1
    while rr * rr < nv
        rr = rr + 1
    endwhile
    return(rr * rr == nv)
end

// ---------- Main ----------
proc Main()
    integer orig_buf = GetBufferId()
    integer ncur = 0
    integer dsval = 0
    string ans_str[30] = ""

    g_total = 0

    ncur = 2
    while ncur <= 99
        if not IsPerfectSquare(ncur)
            dsval = SumFirst100Digits(JarvisSqrt(ncur))
            g_total = g_total + dsval
        endif
        ncur = ncur + 1
    endwhile

    // Return to the buffer that was active before
    GotoBufferId(orig_buf)

    // Prepare the answer string
    ans_str = Str(g_total)

    // Show answer in a Warn() dialog box
    Warn("Project Euler #80 answer: " + ans_str)

    // Copy ONLY the bare numeric answer to the Windows clipboard
    CopyToWinClip(ans_str)

end
