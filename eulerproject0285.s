/*
    Project Euler problem 285
    Version: 3
    Created by: Google Gemini
*/

integer proc IsZero(string s)
    integer i = 1
    while i <= Length(s)
        if SubStr(s, i, 1) <> "0" and SubStr(s, i, 1) <> "."
            return (0)
        endif
        i = i + 1
    endwhile
    return (1)
end

string proc PadPrec(string inS, integer prec)
    string s[255] = inS
    integer dotP = Pos(".", s)
    integer frac = 0
    if dotP == 0
        s = s + "."
        dotP = Length(s)
    endif

    frac = Length(s) - dotP
    while frac < prec
        s = s + "0"
        frac = frac + 1
    endwhile

    if frac > prec
        s = SubStr(s, 1, dotP + prec)
    endif
    return (s)
end

string proc AddStr(string inA, string inB)
    string a[255] = inA
    string b[255] = inB
    integer dotA = 0
    integer dotB = 0
    integer i = 0
    integer carry = 0
    integer sumVal = 0
    string res[255] = ""
    string cA[255] = ""
    string cB[255] = ""

    a = PadPrec(a, 15)
    b = PadPrec(b, 15)

    dotA = Pos(".", a)
    dotB = Pos(".", b)
    while dotA < dotB
        a = "0" + a
        dotA = dotA + 1
    endwhile
    while dotB < dotA
        b = "0" + b
        dotB = dotB + 1
    endwhile

    i = Length(a)
    while i > 0
        cA = SubStr(a, i, 1)
        if cA == "."
            res = "." + res
        else
            cB = SubStr(b, i, 1)
            sumVal = Val(cA) + Val(cB) + carry
            carry = sumVal / 10
            res = Str(sumVal MOD 10) + res
        endif
        i = i - 1
    endwhile

    if carry > 0
        res = Str(carry) + res
    endif
    return (res)
end

string proc SubStrMath(string inA, string inB)
    string a[255] = inA
    string b[255] = inB
    integer dotA = 0
    integer dotB = 0
    integer i = 0
    integer borrow = 0
    integer diffVal = 0
    string res[255] = ""
    string cA[255] = ""
    string cB[255] = ""

    a = PadPrec(a, 15)
    b = PadPrec(b, 15)
    
    dotA = Pos(".", a)
    dotB = Pos(".", b)
    while dotA < dotB
        a = "0" + a
        dotA = dotA + 1
    endwhile
    while dotB < dotA
        b = "0" + b
        dotB = dotB + 1
    endwhile
    
    i = Length(a)
    while i > 0
        cA = SubStr(a, i, 1)
        if cA == "."
            res = "." + res
        else
            cB = SubStr(b, i, 1)
            diffVal = Val(cA) - Val(cB) - borrow
            if diffVal < 0
                diffVal = diffVal + 10
                borrow = 1
            else
                borrow = 0
            endif
            res = Str(diffVal) + res
        endif
        i = i - 1
    endwhile
    
    while Length(res) > 2 and SubStr(res, 1, 1) == "0" and SubStr(res, 2, 1) <> "."
        res = SubStr(res, 2, Length(res) - 1)
    endwhile
    
    return (res)
end

string proc MulInt(string s, integer m)
    integer i = Length(s)
    integer carry = 0
    integer prodVal = 0
    string res[255] = ""
    string ch[255] = ""
    
    while i > 0
        ch = SubStr(s, i, 1)
        if ch == "."
            res = "." + res
        else
            prodVal = Val(ch) * m + carry
            carry = prodVal / 10
            res = Str(prodVal MOD 10) + res
        endif
        i = i - 1
    endwhile
    
    if carry > 0
        res = Str(carry) + res
    endif
    return (res)
end

string proc DivInt(string inS, integer d)
    string s[255] = inS
    integer i = 1
    integer len = 0
    integer remVal = 0
    integer v = 0
    string res[255] = ""
    string ch[255] = ""
    
    s = PadPrec(s, 15)
    len = Length(s)
    
    while i <= len
        ch = SubStr(s, i, 1)
        if ch == "."
            res = res + "."
        else
            remVal = remVal * 10 + Val(ch)
            v = remVal / d
            remVal = remVal MOD d
            res = res + Str(v)
        endif
        i = i + 1
    endwhile
    
    res = PadPrec(res, 15)
    while Length(res) > 2 and SubStr(res, 1, 1) == "0" and SubStr(res, 2, 1) <> "."
        res = SubStr(res, 2, Length(res) - 1)
    endwhile
    
    return (res)
end

string proc CalcG(integer twoR)
    string base[255] = PadPrec(Str(twoR - 1), 15)
    string Tm[255] = DivInt(PadPrec("2", 15), 3 * twoR)
    string sumT[255] = Tm
    integer m = 1
    integer num = 0
    integer den2 = 0
    
    while IsZero(Tm) == 0
        num = 4 * (2*m - 1) * (2*m + 1)
        den2 = (2*m + 2) * (2*m + 3)
        
        Tm = MulInt(Tm, num)
        Tm = DivInt(Tm, twoR)
        Tm = DivInt(Tm, twoR)
        Tm = DivInt(Tm, den2)
        
        if IsZero(Tm)
            break
        endif
        
        sumT = AddStr(sumT, Tm)
        m = m + 1
    endwhile
    
    return (SubStrMath(base, sumT))
end

proc Main()
    string pi[255] = PadPrec("3.141592653589793", 15)
    string pi_half[255] = DivInt(pi, 2)
    string pi_9[255] = MulInt(pi, 9)
    string pi_9_16[255] = DivInt(pi_9, 16)

    string g1_5[255] = CalcG(3)
    string totalE[255] = SubStrMath(pi_9_16, g1_5)
    string g_prev[255] = g1_5
    string g_next[255] = ""
    string diffG[255] = ""
    string term2[255] = ""
    string Ek[255] = ""

    integer k = 2
    string finalAns[255] = ""
    string nextDigit[255] = ""

    while k <= 100000
        g_next = CalcG(2*k + 1)
        diffG = SubStrMath(g_next, g_prev)
        term2 = DivInt(diffG, k)
        Ek = SubStrMath(pi_half, term2)
        totalE = AddStr(totalE, Ek)

        g_prev = g_next
        k = k + 1
    endwhile

    finalAns = SubStr(totalE, 1, Pos(".", totalE) + 5)
    nextDigit = SubStr(totalE, Pos(".", totalE) + 6, 1)

    if Val(nextDigit) >= 5
        totalE = AddStr(totalE, "0.000010000000000")
        finalAns = SubStr(totalE, 1, Pos(".", totalE) + 5)
    endif

    CopyToWinClip(finalAns)
    Warn(finalAns)
    CopyToWinClip(finalAns)
end
