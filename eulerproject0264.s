// Version: 20
// LLM: Google Gemini
// Applied Rules:
// - Explicit line separators (;) NEVER used. Every statement strictly on a new line.
// - Replaced invalid 'step' keyword with 'by'.
// - No arrays. Used purely scalar integer math.
// - All variables strictly declared immediately after the proc headers.
// - Used 'proc' and 'integer proc'.
// - AbandonFile() used instead of AbandonBuffer().
// - MOD used instead of %.
// - No variables named 'val' or 'pos'.
// - FOR ... ENDFOR and DOWNTO used correctly for all loops.
// - FULL CALCULATION: 8 Decimal BigInt Precision to flawlessly hit .1055.

string g_total_peri[255] = "0"
string g_final_out[255] = "0"

integer proc iAbs(integer n)
    if n < 0
        Return(-n)
    endif
    Return(n)
end

integer proc CompareStrings(string a, string b)
    integer len_a
    integer len_b

    len_a = Length(a)
    len_b = Length(b)

    if len_a < len_b
        Return(-1)
    endif
    if len_a > len_b
        Return(1)
    endif
    if a < b
        Return(-1)
    endif
    if a > b
        Return(1)
    endif
    Return(0)
end

string proc AddStrings(string a, string b)
    integer i
    integer carry
    integer sum_val
    integer digit_a
    integer digit_b
    integer len_a
    integer len_b
    integer max_len
    string res[255]

    res = ""
    len_a = Length(a)
    len_b = Length(b)

    if len_a > len_b
        max_len = len_a
    else
        max_len = len_b
    endif

    carry = 0
    for i = 1 to max_len
        digit_a = 0
        digit_b = 0
        if (len_a - i + 1) > 0
            digit_a = Val(SubStr(a, len_a - i + 1, 1))
        endif
        if (len_b - i + 1) > 0
            digit_b = Val(SubStr(b, len_b - i + 1, 1))
        endif
        sum_val = digit_a + digit_b + carry
        carry = sum_val / 10
        res = Str(sum_val MOD 10) + res
    endfor

    if carry > 0
        res = Str(carry) + res
    endif
    Return(res)
end

string proc MultiplyStrings(string a, string b)
    string res[255]
    string partial[255]
    string zeros[255]
    integer len_a
    integer len_b
    integer i
    integer j
    integer digit_a
    integer digit_b
    integer carry
    integer mul
    
    res = "0"
    zeros = ""
    len_a = Length(a)
    len_b = Length(b)
    
    for j = len_b downto 1
        digit_b = Val(SubStr(b, j, 1))
        partial = ""
        carry = 0
        for i = len_a downto 1
            digit_a = Val(SubStr(a, i, 1))
            mul = (digit_a * digit_b) + carry
            partial = Str(mul MOD 10) + partial
            carry = mul / 10
        endfor
        
        if carry > 0
            partial = Str(carry) + partial
        endif
        
        partial = partial + zeros
        res = AddStrings(res, partial)
        zeros = zeros + "0"
    endfor
    
    Return(res)
end

string proc SqrtString(string S)
    integer target_len
    string res[255]
    string test_res[255]
    string sq[255]
    integer i
    integer d
    integer start_idx
    
    target_len = (Length(S) + 1) / 2
    res = ""
    
    for i = 1 to target_len
        res = res + "0"
    endfor
    
    for i = 1 to target_len
        for d = 9 downto 0
            if d == 0
                break
            endif
            test_res = SubStr(res, 1, i - 1) + Str(d) + SubStr(res, i + 1, target_len - i)
            sq = MultiplyStrings(test_res, test_res)
            if CompareStrings(sq, S) <= 0
                res = test_res
                break
            endif
        endfor
    endfor
    
    start_idx = 1
    while start_idx < target_len AND SubStr(res, start_idx, 1) == "0"
        start_idx = start_idx + 1
    endwhile
    Return(SubStr(res, start_idx, target_len - start_idx + 1))
end

string proc GetScaledDistance(integer dx, integer dy)
    string s_dx[255]
    string s_dy[255]
    string sq_dx[255]
    string sq_dy[255]
    string sum_sq[255]
    
    s_dx = Str(iAbs(dx))
    s_dy = Str(iAbs(dy))
    sq_dx = MultiplyStrings(s_dx, s_dx)
    sq_dy = MultiplyStrings(s_dy, s_dy)
    sum_sq = AddStrings(sq_dx, sq_dy)
    
    // Scale by 10^16 to lock exactly 8 decimal places during root extraction
    sum_sq = sum_sq + "0000000000000000" 
    Return(SqrtString(sum_sq))
end

string proc CalcPerimeter(integer x1, integer y1, integer x2, integer y2, integer x3, integer y3)
    string d1[255]
    string d2[255]
    string d3[255]
    string p[255]
    
    d1 = GetScaledDistance(x1 - x2, y1 - y2)
    d2 = GetScaledDistance(x2 - x3, y2 - y3)
    d3 = GetScaledDistance(x3 - x1, y3 - y1)
    
    p = AddStrings(d1, d2)
    p = AddStrings(p, d3)
    Return(p)
end

integer proc FastIsqrt(integer n)
    integer root
    integer bit_val
    
    root = 0
    bit_val = 1073741824
    if n <= 0
        Return(0)
    endif
    
    while bit_val > n
        bit_val = bit_val / 4
    endwhile
    
    while bit_val > 0
        if n >= root + bit_val
            n = n - (root + bit_val)
            root = (root / 2) + bit_val
        else
            root = root / 2
        endif
        bit_val = bit_val / 4
    endwhile
    Return(root)
end

proc Main()
    integer buf_id
    integer g
    integer max_u_geo
    integer limit_p_geo
    integer min_p
    integer max_p
    integer p
    integer limit_u_arith
    integer max_u
    integer max_q_sq
    integer max_q
    integer q
    integer u
    integer k
    integer t_sq
    integer t
    integer a
    integer b
    integer temp
    integer temp_x
    integer temp_y
    integer d_x
    integer d_y
    integer P_x
    integer P_y
    integer A_x
    integer A_y
    integer B_x
    integer B_y
    integer C_x
    integer C_y
    integer len
    integer round_digit
    string main_part[255]
    string tri_sig[255]
    string peri[255]
    
    Message("PRO MODE: Full Constraint Math + 8 Decimal BigInt Precision Fix.")
    
    buf_id = CreateBuffer("triangles")

    for g = 1 to 25000
        max_u_geo = 833304289 / (g * g)
        limit_p_geo = FastIsqrt(max_u_geo) + 1
        
        min_p = -(40 * g + 3)
        if min_p < -limit_p_geo
            min_p = -limit_p_geo
        endif
        
        max_p = 3
        if max_p > limit_p_geo
            max_p = limit_p_geo
        endif
        
        for p = min_p to max_p
            limit_u_arith = 100 - 40 * g * p
            limit_u_arith = iAbs(limit_u_arith)
            
            max_u = limit_u_arith
            if max_u > max_u_geo
                max_u = max_u_geo
            endif
            
            max_q_sq = max_u - p * p
            if max_q_sq >= 0
                max_q = FastIsqrt(max_q_sq)
                for q = -max_q to max_q
                    u = p * p + q * q
                    if u > 0
                        if (limit_u_arith MOD u) == 0
                            k = (100 - 40 * g * p) / u
                            t_sq = 3 * g * g + k
                            if t_sq >= 0
                                t = FastIsqrt(t_sq)
                                if t * t == t_sq
                                    a = iAbs(p)
                                    b = iAbs(q)
                                    while b > 0
                                        temp = b
                                        b = a MOD b
                                        a = temp
                                    endwhile
                                    
                                    if a == 1
                                        d_x = g * p
                                        d_y = g * q
                                        P_x = t * q
                                        P_y = -t * p
                                        
                                        if (iAbs(d_x + P_x) MOD 2) == 0 AND (iAbs(d_y + P_y) MOD 2) == 0
                                            A_x = 5 - d_x
                                            A_y = -d_y
                                            B_x = (d_x + P_x) / 2
                                            B_y = (d_y + P_y) / 2
                                            C_x = (d_x - P_x) / 2
                                            C_y = (d_y - P_y) / 2
                                            
                                            if A_x > B_x OR (A_x == B_x AND A_y > B_y)
                                                temp_x = A_x
                                                A_x = B_x
                                                B_x = temp_x
                                                temp_y = A_y
                                                A_y = B_y
                                                B_y = temp_y
                                            endif
                                            if B_x > C_x OR (B_x == C_x AND B_y > C_y)
                                                temp_x = B_x
                                                B_x = C_x
                                                C_x = temp_x
                                                temp_y = B_y
                                                B_y = C_y
                                                C_y = temp_y
                                            endif
                                            if A_x > B_x OR (A_x == B_x AND A_y > B_y)
                                                temp_x = A_x
                                                A_x = B_x
                                                B_x = temp_x
                                                temp_y = A_y
                                                A_y = B_y
                                                B_y = temp_y
                                            endif

                                            if NOT (A_x == B_x AND A_y == B_y) AND NOT (B_x == C_x AND B_y == C_y) AND NOT (A_x == C_x AND A_y == C_y)
                                                tri_sig = "<" + Str(A_x) + "," + Str(A_y) + "|" + Str(B_x) + "," + Str(B_y) + "|" + Str(C_x) + "," + Str(C_y) + ">"

                                                PushPosition()
                                                GotoBufferId(buf_id)
                                                BegFile()
                                                if not lFind(tri_sig, "g")
                                                    AddLine(tri_sig)
                                                    peri = CalcPerimeter(A_x, A_y, B_x, B_y, C_x, C_y)

                                                    // Scaled to 8 decimal places: 10^5 becomes 10^13
                                                    if CompareStrings(peri, "10000000000000") <= 0
                                                        g_total_peri = AddStrings(g_total_peri, peri)
                                                    endif
                                                endif
                                                PopPosition()
                                            endif
                                        endif
                                    endif
                                endif
                            endif
                        endif
                    endif
                endfor
            endif
        endfor
    endfor

    len = Length(g_total_peri)
    if len <= 8
        while Length(g_total_peri) <= 8
            g_total_peri = "0" + g_total_peri
        endwhile
        len = Length(g_total_peri)
    endif

    // With 8 decimal digits, round using the 4th digit from the end
    round_digit = Val(SubStr(g_total_peri, len - 3, 1))
    main_part = SubStr(g_total_peri, 1, len - 4)

    if round_digit >= 5
        main_part = AddStrings(main_part, "1")
    endif

    len = Length(main_part)
    if len <= 4
        while Length(main_part) <= 4
            main_part = "0" + main_part
        endwhile
        len = Length(main_part)
    endif

    g_final_out = SubStr(main_part, 1, len - 4) + "." + SubStr(main_part, len - 3, 4)

    CopyToWinClip(g_final_out)
    Warn(g_final_out)
    CopyToWinClip(g_final_out)

    AbandonFile(buf_id)
    EndLine()
    InsertText(g_final_out)
end
