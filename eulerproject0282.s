/*
  Project Euler Problem 282 Solver
  LLM History: Google Gemini Pro
  Version: 4

  Calculates the sum of Ackermann functions A(n,n) for n=0 to 6 modulo 14^8.
*/

// Compute the Modulo M = 14^8
integer proc GetM()
    integer m = 14
    integer i = 0
    integer res = 14

    for i = 1 to 7
        res = res * m
    endfor

    return(res)
end

// Euler's Totient Function
integer proc phi(integer n)
    integer result = n
    integer p = 2
    while p * p <= n
        if (n MOD p) == 0
            while (n MOD p) == 0
                n = n / p
            endwhile
            result = result - (result / p)
        endif
        if p == 2
            p = 3
        else
            p = p + 2
        endif
    endwhile
    if n > 1
        result = result - (result / n)
    endif
    return(result)
end

// Safe Modulo Addition to prevent 32-bit signed overflow
integer proc AddMod(integer a, integer b, integer m)
    integer max_int = 2147483647
    integer res = 0

    if b > max_int - a
        res = a - (m - b)
    else
        a = a + b
        if a >= m
            a = a - m
        endif
        res = a
    endif

    return(res)
end

// Safe Modulo Multiplication (Russian Peasant)
integer proc MulMod(integer a, integer b, integer m)
    integer res = 0
    a = a MOD m
    while b > 0
        if (b MOD 2) == 1
            res = AddMod(res, a, m)
        endif
        a = AddMod(a, a, m)
        b = b / 2
    endwhile
    return(res)
end

// Binary Modular Exponentiation
integer proc PowerMod(integer base, integer exp, integer m)
    integer res = 1
    base = base MOD m
    while exp > 0
        if (exp MOD 2) == 1
            res = MulMod(res, base, m)
        endif
        base = MulMod(base, base, m)
        exp = exp / 2
    endwhile
    return(res)
end

// Recursive Tower Function (Retains +m Totient shift)
integer proc TowerModEx(integer h, integer m)
    integer ep = 0
    integer res = 0

    if h == 0
        return(1)
    endif
    if m == 1
        return(1)
    endif
    if h == 1
        if 2 >= m
            return((2 MOD m) + m)
        else
            return(2)
        endif
    endif
    if h == 2
        if 4 >= m
            return((4 MOD m) + m)
        else
            return(4)
        endif
    endif
    if h == 3
        if 16 >= m
            return((16 MOD m) + m)
        else
            return(16)
        endif
    endif
    if h == 4
        if 65536 >= m
            return((65536 MOD m) + m)
        else
            return(65536)
        endif
    endif

    ep = TowerModEx(h - 1, phi(m))
    res = PowerMod(2, ep, m)
    return(res + m)
end

// Top level Tower function wrapper
integer proc TowerTop(integer h, integer m)
    integer ep = 0

    if h == 0
        return(1)
    endif
    if h == 1
        return(2 MOD m)
    endif
    if h == 2
        return(4 MOD m)
    endif
    if h == 3
        return(16 MOD m)
    endif
    if h == 4
        return(65536 MOD m)
    endif

    ep = TowerModEx(h - 1, phi(m))
    return(PowerMod(2, ep, m))
end

proc Main()
    integer M_val = GetM()
    integer M_minus_3 = M_val - 3
    
    // Base A(n,n) static calculations for n <= 3
    integer S0 = 1    // A(0,0)
    integer S1 = 3    // A(1,1)
    integer S2 = 7    // A(2,2)
    integer S3 = 61   // A(3,3)
    
    // Tetration A(n,n) calculations for n >= 4
    integer S4 = 0
    integer S5 = 0
    integer S6 = 0
    
    integer total_sum = 0
    string ans[255] = ""

    // A(4,4) = 2^^7 - 3. Handled via AddMod to prevent `+ M - 3` overflow
    S4 = AddMod(TowerTop(7, M_val), M_minus_3, M_val)
    
    // A(5,5) and A(6,6) towers stabilize well before depth 255
    S5 = AddMod(TowerTop(255, M_val), M_minus_3, M_val)
    S6 = AddMod(TowerTop(255, M_val), M_minus_3, M_val)

    total_sum = S0
    total_sum = AddMod(total_sum, S1, M_val)
    total_sum = AddMod(total_sum, S2, M_val)
    total_sum = AddMod(total_sum, S3, M_val)
    total_sum = AddMod(total_sum, S4, M_val)
    total_sum = AddMod(total_sum, S5, M_val)
    total_sum = AddMod(total_sum, S6, M_val)

    ans = Str(total_sum)

    CopyToWinClip(ans)
    Warn(ans)
    CopyToWinClip(ans)

    // Output answer dynamically into the active .s editor buffer
    AddLine(ans)
end
