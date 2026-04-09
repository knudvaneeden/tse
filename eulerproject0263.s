// Version: 4
// LLM: Google Gemini
// History:
// 1 - Initial version created by Google Gemini
// 2 - Fixed IF statement syntax to use proper ENDIF block structure
// 3 - Fixed string declaration to include maximum length brackets [255]
// 4 - Removed rules checklist buffer, outputting only the final answer

integer proc IsPrime(integer n)
    integer p = 5

    if n <= 1
        return( 0 )
    endif
    if n == 2
        return( 1 )
    endif
    if n == 3
        return( 1 )
    endif
    if (n MOD 2) == 0
        return( 0 )
    endif
    if (n MOD 3) == 0
        return( 0 )
    endif

    while (p * p) <= n
        if (n MOD p) == 0
            return( 0 )
        endif
        if (n MOD (p + 2)) == 0
            return( 0 )
        endif
        p = p + 6
    endwhile

    return( 1 )
end

integer proc IsPractical(integer x)
    integer limit = x
    integer sum_divs = 1
    integer count = 0
    integer p = 3
    integer term = 0
    integer p_sum = 0
    integer i = 0

    if x < 1
        return( 0 )
    endif
    if (x MOD 2) <> 0
        return( 0 )
    endif

    while (limit MOD 2) == 0
        limit = limit / 2
        count = count + 1
    endwhile

    term = 1
    sum_divs = 1
    while count > 0
        term = term * 2
        sum_divs = sum_divs + term
        count = count - 1
    endwhile

    p = 3
    while limit > 1 and (p * p) <= limit
        if p > sum_divs + 1
            return( 0 )
        endif
        if (limit MOD p) == 0
            count = 0
            while (limit MOD p) == 0
                limit = limit / p
                count = count + 1
            endwhile

            term = 1
            p_sum = 1
            i = 1
            while i <= count
                term = term * p
                p_sum = p_sum + term
                i = i + 1
            endwhile
            
            if (2147483647 / p_sum) < sum_divs
                sum_divs = 2147483647
            else
                sum_divs = sum_divs * p_sum
            endif
        endif
        p = p + 2
    endwhile

    if limit > 1
        if limit > sum_divs + 1
            return( 0 )
        endif
    endif

    return( 1 )
end

string proc AddBigInt(string a, string b)
    integer len_a = Length(a)
    integer len_b = Length(b)
    integer carry = 0
    integer sum = 0
    string result[255] = ""
    integer i = len_a
    integer j = len_b
    integer digit_a = 0
    integer digit_b = 0

    while i > 0 or j > 0 or carry > 0
        if i > 0
            digit_a = Val(SubStr(a, i, 1))
            i = i - 1
        else
            digit_a = 0
        endif

        if j > 0
            digit_b = Val(SubStr(b, j, 1))
            j = j - 1
        else
            digit_b = 0
        endif

        sum = digit_a + digit_b + carry
        carry = sum / 10
        sum = sum MOD 10
        result = Str(sum) + result
    endwhile

    return( result )
end

proc Main()
    integer m = 0
    integer n = 0
    integer found = 0
    string sum_paradises[255] = "0"

    while found < 4
        n = 840 * m + 20
        if n > 9
            if IsPractical(n - 8)
                if IsPractical(n + 8)
                    if IsPractical(n - 4)
                        if IsPractical(n + 4)
                            if IsPractical(n)
                                if IsPrime(n - 9)
                                    if IsPrime(n - 3)
                                        if IsPrime(n + 3)
                                            if IsPrime(n + 9)
                                                if not IsPrime(n - 7)
                                                    if not IsPrime(n - 1)
                                                        if not IsPrime(n + 1)
                                                            if not IsPrime(n + 7)
                                                                sum_paradises = AddBigInt(sum_paradises, Str(n))
                                                                found = found + 1
                                                            endif
                                                        endif
                                                    endif
                                                endif
                                            endif
                                        endif
                                    endif
                                endif
                            endif
                        endif
                    endif
                endif
            endif
        endif
        
        if found < 4
            n = 840 * m + 820
            if n > 9
                if IsPractical(n - 8)
                    if IsPractical(n + 8)
                        if IsPractical(n - 4)
                            if IsPractical(n + 4)
                                if IsPractical(n)
                                    if IsPrime(n - 9)
                                        if IsPrime(n - 3)
                                            if IsPrime(n + 3)
                                                if IsPrime(n + 9)
                                                    if not IsPrime(n - 7)
                                                        if not IsPrime(n - 1)
                                                            if not IsPrime(n + 1)
                                                                if not IsPrime(n + 7)
                                                                    sum_paradises = AddBigInt(sum_paradises, Str(n))
                                                                    found = found + 1
                                                                endif
                                                            endif
                                                        endif
                                                    endif
                                                endif
                                            endif
                                        endif
                                    endif
                                endif
                            endif
                        endif
                    endif
                endif
            endif
        endif
        
        m = m + 1
    endwhile

    CopyToWinClip(sum_paradises)
    Warn(sum_paradises)
    CopyToWinClip(sum_paradises)
end
