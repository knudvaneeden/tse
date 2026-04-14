// Project Euler 278 Solver
// Version: 5
// LLM: Google Gemini (Pro Mode)

// Custom Integer Square Root to replace the missing Sqrt() function
integer proc IntegerSqrt(integer n)
    integer root = 0
    if n < 0
        return(0)
    endif
    while (root + 1) * (root + 1) <= n
        root = root + 1
    endwhile
    return(root)
end

// Adds two numeric strings: res = a + b
string proc AddStrings(string a, string b)
    integer i = Length(a)
    integer j = Length(b)
    integer carry = 0
    integer sum_val = 0
    string res[255] = ""
    string char_a[1] = ""
    string char_b[1] = ""

    while i > 0 or j > 0 or carry > 0
        char_a = "0"
        char_b = "0"
        if i > 0
            char_a = SubStr(a, i, 1)
            i = i - 1
        endif
        if j > 0
            char_b = SubStr(b, j, 1)
            j = j - 1
        endif
        sum_val = Val(char_a) + Val(char_b) + carry
        carry = sum_val / 10
        res = Str(sum_val MOD 10) + res
    endwhile
    return(res)
end

// Fast BigInt string multiplication by integer: res = a * b
string proc MultStrInt(string a, integer b)
    integer i = Length(a)
    integer carry = 0
    integer current_digit = 0
    integer prod = 0
    string res[255] = ""
    string char_a[1] = ""
    
    if b == 0 or a == "0"
        return("0")
    endif

    while i > 0
        char_a = SubStr(a, i, 1)
        current_digit = Val(char_a)
        prod = (current_digit * b) + carry
        carry = prod / 10
        res = Str(prod MOD 10) + res
        i = i - 1
    endwhile
    
    while carry > 0
        res = Str(carry MOD 10) + res
        carry = carry / 10
    endwhile
    
    return(res)
end

// Calculates Frobenius number for p, q, r using formula:
// f(p, q, r) = p*q*(r-1) + r*(p*(q-1) - q)
string proc GetFrobenius(integer p, integer q, integer r)
    integer pq = p * q
    integer inner = (p * (q - 1)) - q
    string partA[255] = MultStrInt(Str(pq), r - 1)
    string partB[255] = MultStrInt(Str(inner), r)
    return(AddStrings(partA, partB))
end

// Helper to get an integer from our "Prime Array" buffer
integer proc GetPrime(integer index, integer buffer_id)
    integer p_val = 0
    PushPosition()
    GotoBufferId(buffer_id)
    GotoLine(index)
    p_val = Val(GetText(1, 255))
    PopPosition()
    return(p_val)
end

proc Main()
    integer prime_buf = 0
    integer num_p = 0
    integer i = 0
    integer j = 0
    integer k = 0
    integer n = 0
    integer limit = 5000
    integer is_p = 0
    integer p = 0
    integer q = 0
    integer r = 0
    string total_sum[255] = "0"
    string current_f[255] = ""

    // Create a temporary buffer to act as an array for primes
    prime_buf = CreateTempBuffer()

    // Sieve/Find primes up to 5000 and store in buffer
    for i = 2 to limit
        is_p = 1
        for n = 2 to IntegerSqrt(i)
            if i MOD n == 0
                is_p = 0
                break
            endif
        endfor
        if is_p == 1
            num_p = num_p + 1
            PushPosition()
            GotoBufferId(prime_buf)
            AddLine(Str(i))
            PopPosition()
        endif
    endfor

    // Main calculation triple loop
    for i = 1 to num_p - 2
        p = GetPrime(i, prime_buf)
        for j = i + 1 to num_p - 1
            q = GetPrime(j, prime_buf)
            for k = j + 1 to num_p
                r = GetPrime(k, prime_buf)
                current_f = GetFrobenius(p, q, r)
                total_sum = AddStrings(total_sum, current_f)
            endfor
        endfor
    endfor

    // Final result handling
    CopyToWinClip(total_sum)
    Warn(total_sum)
    CopyToWinClip(total_sum)

    // Output result to current buffer
    InsertText(total_sum)

    // Clean up
    AbandonFile(prime_buf)
end
