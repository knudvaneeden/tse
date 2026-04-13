// =======================================================================
// Program: Project Euler Problem 270 Solver
// Language: TSE SAL
// LLM: Google Gemini Pro
// Version: v1
// =======================================================================

integer dp_buf_id = 0
string buf_name[20] = "DP_Buffer"

// Russian Peasant Multiplication to safely prevent 32-bit signed overflow
// (a * b) max could be 10^16, but this limits intermediate adds to 2*10^8
integer proc mul_mod(integer a, integer b)
    integer res = 0
    a = a MOD 100000000
    while b > 0
        if (b MOD 2) == 1
            res = (res + a) MOD 100000000
        endif
        a = (a + a) MOD 100000000
        b = b / 2
    endwhile
    return(res)
end

// Identifies if chord vertices "u" and "v" lie on the same edge of the square
integer proc is_forbidden(integer u, integer v, integer N_val)
    integer k = 0
    integer start_val = 0
    integer end_val = 0
    integer u_in = 0
    integer v_in = 0

    for k = 0 to 3
        start_val = k * N_val
        end_val = (k + 1) * N_val

        u_in = 0
        if (u >= start_val) and (u <= end_val)
            u_in = 1
        endif
        // Edge 3 wraps around and includes vertex 0
        if (k == 3) and (u == 0)
            u_in = 1
        endif

        v_in = 0
        if (v >= start_val) and (v <= end_val)
            v_in = 1
        endif
        // Edge 3 wraps around and includes vertex 0
        if (k == 3) and (v == 0)
            v_in = 1
        endif

        if (u_in == 1) and (v_in == 1)
            return(1)
        endif
    endfor

    return(0)
end

// Fills an invisible buffer with 14400 zeros to emulate a 120x120 array memory
proc init_buffer()
    integer i = 0
    dp_buf_id = CreateBuffer(buf_name)
    for i = 1 to 14400
        AddLine("0")
    endfor
    GotoLine(1)
    KillLine()
end

proc main()
    integer N_val = 30
    integer M = 120 // 4 * 30 boundaries
    integer len_idx = 0
    integer i = 0
    integer j = 0
    integer k = 0
    integer sum = 0
    integer term = 0
    integer is_forb = 0
    integer answer = 0
    integer orig_buf = GetBufferId()
    integer i_M = 0
    integer k_M = 0

    init_buffer()
    GotoBufferId(dp_buf_id)

    // DP Array Base Cases (Polygon edges)
    for i = 0 to M - 2
        i_M = i * M
        GotoLine(i_M + (i + 1) + 1)
        BegLine()
        DelToEol()
        InsertText("1")
    endfor

    // Catalan / Polygon Triangulation Matrix DP calculation
    for len_idx = 2 to M - 1
        for i = 0 to M - len_idx - 1
            j = i + len_idx
            i_M = i * M

            is_forb = 0
            if len_idx < M - 1
                is_forb = is_forbidden(i, j, N_val)
            endif

            if is_forb == 1
                GotoLine(i_M + j + 1)
                BegLine()
                DelToEol()
                InsertText("0")
            else
                sum = 0
                for k = i + 1 to j - 1
                    k_M = k * M

                    // Retrieve dp(i, k)
                    GotoLine(i_M + k + 1)
                    term = Val(GetText(1, 255))

                    // Retrieve dp(k, j) and modular multiply
                    GotoLine(k_M + j + 1)
                    term = mul_mod(term, Val(GetText(1, 255)))

                    sum = (sum + term) MOD 100000000
                endfor

                GotoLine(i_M + j + 1)
                BegLine()
                DelToEol()
                InsertText(Str(sum))
            endif
        endfor
    endfor

    // Final Answer resides at (0, M-1) in the table matrix representation
    GotoLine(0 * M + (M - 1) + 1)
    answer = Val(GetText(1, 255))

    GotoBufferId(orig_buf)
    AbandonFile(dp_buf_id)

    CopyToWinClip(Str(answer))
    Warn(Str(answer))
    CopyToWinClip(Str(answer))
end
