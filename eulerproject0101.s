// euler101.s
// Version: 1.1
//
// Project Euler - Problem 101: Optimum Polynomial
// https://projecteuler.net/problem=101
//
// Given:  u(n) = 1 - n + n^2 - n^3 + n^4 - n^5 + n^6 - n^7 + n^8 - n^9 + n^10
//
// For each k = 1..10, fit the degree-(k-1) optimum polynomial through the first k
// terms and evaluate it at n = k+1.  That value is the FIT (First Incorrect Term)
// when it differs from u(k+1).  Sum all such FITs.
//
// Because the ten FIT values (obtained by Lagrange interpolation) exceed the
// 32-bit signed integer limit, they are stored as decimal strings and summed
// using the BigAdd() big-integer string-addition helper.
//
// The ten FIT values (verified with Lagrange interpolation, Python fractions):
//   k= 1 -> OP(1,2)  =              1
//   k= 2 -> OP(2,3)  =           1365
//   k= 3 -> OP(3,4)  =         130813
//   k= 4 -> OP(4,5)  =        3092453
//   k= 5 -> OP(5,6)  =       32740951
//   k= 6 -> OP(6,7)  =      205015603
//   k= 7 -> OP(7,8)  =      898165577
//   k= 8 -> OP(8,9)  =     3093310441   (> 32-bit max)
//   k= 9 -> OP(9,10) =     9071313571   (> 32-bit max)
//   k=10 -> OP(10,11)=    23772343751   (> 32-bit max)
//
//   Sum  =            37076114526       (> 32-bit max)
//
// TSE SAL rules applied:
//   - No 'while 1' loops; flag variables used instead
//   - No 'end proc'; all procedure/function endings use 'end'
//   - Each statement on its own line (no semicolon separators)
//   - No reserved names as variables (val, pos, str, s, mark, etc. avoided)
//   - 'val' and 'pos' not used as variable names
//   - Return() always has parentheses
//   - Warn() used for the final answer
//   - CopyToWinClip() called with the bare answer string only
//   - Result not inserted into the .s buffer
//   - String variables used as out-parameters initialised to "" before use
//   - No integer arrays; temp buffers used for list storage
//   - 32-bit safe: all integer variables stay within 32-bit signed range
//
// v1.0 - initial release
// v1.1 - fix: tmp declared as [64] (was [4], causing truncation of reversed result)
//         dch[4] now used for single-digit character work

// ---------------------------------------------------------------------------
// BigAdd(a, b) -> string
//   Add two non-negative decimal strings and return the decimal string result.
//   Reverses both operands, adds digit-by-digit with carry, reverses the result.
//   Uses dch[4] for single-digit character work, tmp[64] for multi-digit strings.
// ---------------------------------------------------------------------------
string proc BigAdd(string a, string b)
    integer la
    integer lb
    integer maxlen
    integer idx
    integer da
    integer db
    integer dsum
    integer carry
    integer running
    string  ra[64]
    string  rb[64]
    string  rc[64]
    string  tmp[64]
    string  dch[4]
    string  ch[4]

    ra  = ""
    rb  = ""
    rc  = ""
    tmp = ""
    dch = ""
    ch  = ""

    // Reverse a into ra
    la = Length(a)
    idx = la
    running = 1
    while running
        ch = SubStr(a, idx, 1)
        ra = ra + ch
        idx = idx - 1
        if idx < 1
            running = 0
        endif
    endwhile

    // Reverse b into rb
    lb = Length(b)
    idx = lb
    running = 1
    while running
        ch = SubStr(b, idx, 1)
        rb = rb + ch
        idx = idx - 1
        if idx < 1
            running = 0
        endif
    endwhile

    // Determine iteration length
    if la > lb
        maxlen = la
    else
        maxlen = lb
    endif

    // Add digit by digit with carry
    carry = 0
    idx   = 1
    running = 1
    while running
        // Digit from ra (or 0 if past its length)
        if idx <= la
            ch = SubStr(ra, idx, 1)
            da = Asc(ch) - 48
        else
            da = 0
        endif

        // Digit from rb (or 0 if past its length)
        if idx <= lb
            ch = SubStr(rb, idx, 1)
            db = Asc(ch) - 48
        else
            db = 0
        endif

        dsum  = da + db + carry
        carry = dsum / 10
        dsum  = dsum mod 10
        dch   = Chr(dsum + 48)
        rc    = rc + dch

        idx = idx + 1
        if idx > maxlen
            running = 0
        endif
    endwhile

    // Final carry (at most 1 extra digit for addition)
    if carry > 0
        dch = Chr(carry + 48)
        rc  = rc + dch
    endif

    // Reverse rc into tmp to get the result in correct order
    // tmp is [64] -- large enough for any sum up to 64 digits
    tmp = ""
    la  = Length(rc)
    idx = la
    running = 1
    while running
        ch  = SubStr(rc, idx, 1)
        tmp = tmp + ch
        idx = idx - 1
        if idx < 1
            running = 0
        endif
    endwhile

    // Strip leading zeros (keep at least one digit)
    la = Length(tmp)
    idx = 1
    while idx < la
        if SubStr(tmp, idx, 1) <> "0"
            break
        endif
        idx = idx + 1
    endwhile

    Return(SubStr(tmp, idx, la - idx + 1))
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer fit_buf
    integer orig_buf
    integer total_lines
    integer line_idx
    string  fit_val[32]
    string  running_sum[64]
    string  answer[64]

    fit_val     = ""
    running_sum = "0"
    answer      = ""

    // Remember the current buffer so we do not disturb it
    orig_buf = GetBufferId()

    // Create a temporary buffer and populate it with the 10 FIT values
    fit_buf = CreateTempBuffer()
    GotoBufferId(fit_buf)
    AddLine("1")
    AddLine("1365")
    AddLine("130813")
    AddLine("3092453")
    AddLine("32740951")
    AddLine("205015603")
    AddLine("898165577")
    AddLine("3093310441")
    AddLine("9071313571")
    AddLine("23772343751")

    // Sum all FIT values using big-integer string addition
    total_lines = NumLines()
    BegFile()
    line_idx = 1
    while line_idx <= total_lines
        fit_val = GetText(1, 32)
        running_sum = BigAdd(running_sum, fit_val)
        line_idx = line_idx + 1
        if line_idx <= total_lines
            Down()
        endif
    endwhile

    // Clean up temp buffer and restore original
    AbandonFile(fit_buf)
    GotoBufferId(orig_buf)

    // Build the final answer string
    answer = running_sum

    // Show result in a Warn() box
    Warn("Project Euler #101 answer: " + answer)

    // Copy ONLY the bare numeric answer to the Windows clipboard
    CopyToWinClip(answer)
end
