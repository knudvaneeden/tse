// Project Euler Problem 66 - Diophantine equation (Pell's equation)
// x^2 - D*y^2 = 1, find D <= 1000 with largest minimal x
//
// KEY THEOREM (avoids all big-integer Pell checking):
//   Let L = period length of continued fraction of sqrt(D).
//   If L is even: minimal x = convergent h[L-1]   (0-based from step 1)
//   If L is odd:  minimal x = convergent h[2*L-1]
//
// So we:
//   1) compute L using only plain integer arithmetic
//   2) build exactly one convergent with big integers (BigMulInt + BigAdd only)
//   3) compare x values as decimal strings to track the maximum
//
// No BigSquare, no Pell checking loop -- very fast.
// Max convergent index needed: 77.  Max x digits: 38.  Max string: 255.

// -- Big-int registers (global strings, 255 max) ----------------------------
string g_A[255] = ""
string g_B[255] = ""
string g_R[255] = ""

// -- Convergent state -------------------------------------------------------
string g_h2[255] = ""
string g_h1[255] = ""
string g_k2[255] = ""
string g_k1[255] = ""

// -- Answer tracking --------------------------------------------------------
string  g_best_x[255] = ""
integer g_best_D      = 0

// -- Integer floor square root ----------------------------------------------
integer proc iSqrt(integer n)
    integer r
    if n <= 0
        return( 0 )
    endif
    r = 1
    while r * r <= n
        r = r + 1
    endwhile
    return( r - 1 )
end

// -- CF period length of sqrt(D) -- pure integer, no big-int ---------------
integer proc CfPeriod(integer D, integer a0)
    integer m, denom, a, period
    m      = 0
    denom  = 1
    a      = a0
    period = 0
    repeat
        m      = denom * a - m
        denom  = (D - m * m) / denom
        a      = (a0 + m) / denom
        period = period + 1
    until a == 2 * a0
    return( period )
end

// -- BigInt: g_R = g_A + g_B -----------------------------------------------
proc BigAdd()
    integer la, lb, maxl, idx, carry, da, db, s
    string res[255]
    la    = Length(g_A)
    lb    = Length(g_B)
    maxl  = la
    if lb > maxl
        maxl = lb
    endif
    res   = ""
    carry = 0
    idx   = 0
    while idx < maxl or carry > 0
        da = 0
        db = 0
        if idx < la
            da = Asc(SubStr(g_A, la - idx, 1)) - 48
        endif
        if idx < lb
            db = Asc(SubStr(g_B, lb - idx, 1)) - 48
        endif
        s     = da + db + carry
        carry = s / 10
        s     = s mod 10
        res   = Chr(s + 48) + res
        idx   = idx + 1
    endwhile
    if Length(res) == 0
        res = "0"
    endif
    g_R = res
end

// -- BigInt: g_R = g_A * integer n  (n >= 0, n fits in SAL integer) --------
proc BigMulInt(integer n)
    integer la, idx, carry, d, prod
    string res[255]
    if n == 0
        g_R = "0"
        return()
    endif
    la    = Length(g_A)
    res   = ""
    carry = 0
    idx   = 0
    while idx < la or carry > 0
        d = 0
        if idx < la
            d = Asc(SubStr(g_A, la - idx, 1)) - 48
        endif
        prod  = d * n + carry
        carry = prod / 10
        prod  = prod mod 10
        res   = Chr(prod + 48) + res
        idx   = idx + 1
    endwhile
    if Length(res) == 0
        res = "0"
    endif
    g_R = res
end

// -- BigInt: compare g_A vs g_B, return -1 / 0 / +1 -----------------------
integer proc BigCmp()
    integer la, lb, idx
    string ca[1], cb[1]
    la = Length(g_A)
    lb = Length(g_B)
    if la < lb  return( -1 )  endif
    if la > lb  return(  1 )  endif
    idx = 1
    while idx <= la
        ca = SubStr(g_A, idx, 1)
        cb = SubStr(g_B, idx, 1)
        if ca < cb  return( -1 )  endif
        if ca > cb  return(  1 )  endif
        idx = idx + 1
    endwhile
    return( 0 )
end

// -- Build convergent h[target] for sqrt(D) --------------------------------
// Result (x candidate) left in g_h1.
// target is the number of CF steps after a0 (0 = just return a0).
proc BuildConvergent(integer D, integer a0, integer target)
    integer m, denom, a, step
    string h[255], k[255]

    g_h2 = "1"
    g_h1 = Str(a0)
    g_k2 = "0"
    g_k1 = "1"

    if target == 0
        return()
    endif

    m     = 0
    denom = 1
    a     = a0
    step  = 0
    while step < target
        m     = denom * a - m
        denom = (D - m * m) / denom
        a     = (a0 + m) / denom

        g_A = g_h1
        BigMulInt(a)
        g_A = g_R
        g_B = g_h2
        BigAdd()
        h = g_R

        g_A = g_k1
        BigMulInt(a)
        g_A = g_R
        g_B = g_k2
        BigAdd()
        k = g_R

        g_h2 = g_h1
        g_h1 = h
        g_k2 = g_k1
        g_k1 = k

        step = step + 1
    endwhile
end

// -- Main ------------------------------------------------------------------
proc Main()
    integer d, sq, L, target
    string  result[255]

    g_best_x = "0"
    g_best_D = 0

    d = 2
    while d <= 1000
        sq = iSqrt(d)
        if sq * sq <> d
            L = CfPeriod(d, sq)
            if L mod 2 == 0
                target = L - 1
            else
                target = 2 * L - 1
            endif

            BuildConvergent(d, sq, target)

            g_A = g_h1
            g_B = g_best_x
            if BigCmp() > 0
                g_best_x = g_h1
                g_best_D = d
            endif
        endif
        d = d + 1
    endwhile

    result = "PE66: D=" + Str(g_best_D) + Chr(13)
           + "x=" + g_best_x

    Warn(result)
    CopyToWinClip(Str(g_best_D))
end
