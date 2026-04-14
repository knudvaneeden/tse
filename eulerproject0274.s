// Project Euler Problem 274
// Language: TSE SAL
// Author/LLM: Google Gemini Pro
// Version: 2

integer sum0 = 0
integer sum1 = 0
integer sum2 = 0

proc AddToSum(integer m)
    sum0 = sum0 + m
    if sum0 >= 100000000
        sum1 = sum1 + (sum0 / 100000000)
        sum0 = sum0 MOD 100000000
        if sum1 >= 100000000
            sum2 = sum2 + (sum1 / 100000000)
            sum1 = sum1 MOD 100000000
        endif
    endif
end

integer proc IsPrime(integer n)
    integer i = 5
    while (i * i) <= n
        if (n MOD i) == 0
            return(0)
        endif
        if (n MOD (i + 2)) == 0
            return(0)
        endif
        i = i + 6
    endwhile
    return(1)
end

string proc GetSum()
    string s0[255] = Str(sum0)
    string s1[255] = Str(sum1)
    string s2[255] = Str(sum2)

    if sum2 > 0
        while Length(s1) < 8
            s1 = "0" + s1
        endwhile
        while Length(s0) < 8
            s0 = "0" + s0
        endwhile
        return(s2 + s1 + s0)
    elseif sum1 > 0
        while Length(s0) < 8
            s0 = "0" + s0
        endwhile
        return(s1 + s0)
    else
        return(s0)
    endif
end

proc Main()
    integer limit = 10000000
    integer p = 7
    integer add_step = 4
    integer m = 0
    integer k = 0
    integer p_mod_10 = 0
    string result_str[255] = ""

    // Base case p=3, which gives m=1
    AddToSum(1)

    while p < limit
        if (p MOD 5) <> 0
            if IsPrime(p)
                p_mod_10 = p MOD 10
                if p_mod_10 == 1
                    k = 9
                elseif p_mod_10 == 3
                    k = 3
                elseif p_mod_10 == 7
                    k = 7
                elseif p_mod_10 == 9
                    k = 1
                endif

                m = ((k * p) + 1) / 10
                AddToSum(m)
            endif
        endif

        // Advance to next candidate, strictly skipping multiples of 2 and 3 (6k +/- 1 pattern)
        p = p + add_step
        if add_step == 4
            add_step = 2
        else
            add_step = 4
        endif
    endwhile

    result_str = GetSum()

    CopyToWinClip(result_str)
    Warn(result_str)
    CopyToWinClip(result_str)
end
