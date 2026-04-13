// Version 3
// Created by Google Gemini (Pro Mode)
// Project Euler problem 269

integer dp0_low_buf = 0
integer dp0_high_buf = 0
integer dp1_low_buf = 0
integer dp1_high_buf = 0

integer R1 = 0
integer R2 = 0
integer R3 = 0
integer R4 = 0
integer R5 = 0
integer R6 = 0

integer mult1 = 0
integer mult2 = 0
integer mult3 = 0
integer mult4 = 0
integer mult5 = 0
integer mult6 = 0

integer cur_v1 = 0
integer cur_v2 = 0
integer cur_v3 = 0
integer cur_v4 = 0
integer cur_v5 = 0
integer cur_v6 = 0

integer proc getR(integer j)
    if (j == 1) return (R1) endif
    if (j == 2) return (R2) endif
    if (j == 3) return (R3) endif
    if (j == 4) return (R4) endif
    if (j == 5) return (R5) endif
    if (j == 6) return (R6) endif
    return (0)
end

proc setR(integer j, integer val_in)
    if (j == 1) R1 = val_in endif
    if (j == 2) R2 = val_in endif
    if (j == 3) R3 = val_in endif
    if (j == 4) R4 = val_in endif
    if (j == 5) R5 = val_in endif
    if (j == 6) R6 = val_in endif
end

integer proc getMult(integer j)
    if (j == 1) return (mult1) endif
    if (j == 2) return (mult2) endif
    if (j == 3) return (mult3) endif
    if (j == 4) return (mult4) endif
    if (j == 5) return (mult5) endif
    if (j == 6) return (mult6) endif
    return (0)
end

proc setMult(integer j, integer val_in)
    if (j == 1) mult1 = val_in endif
    if (j == 2) mult2 = val_in endif
    if (j == 3) mult3 = val_in endif
    if (j == 4) mult4 = val_in endif
    if (j == 5) mult5 = val_in endif
    if (j == 6) mult6 = val_in endif
end

integer proc getCurV(integer j)
    if (j == 1) return (cur_v1) endif
    if (j == 2) return (cur_v2) endif
    if (j == 3) return (cur_v3) endif
    if (j == 4) return (cur_v4) endif
    if (j == 5) return (cur_v5) endif
    if (j == 6) return (cur_v6) endif
    return (0)
end

proc setCurV(integer j, integer val_in)
    if (j == 1) cur_v1 = val_in endif
    if (j == 2) cur_v2 = val_in endif
    if (j == 3) cur_v3 = val_in endif
    if (j == 4) cur_v4 = val_in endif
    if (j == 5) cur_v5 = val_in endif
    if (j == 6) cur_v6 = val_in endif
end

integer proc getShift(integer k)
    if (k == 1) return (100) endif
    if (k == 2) return (8) endif
    if (k == 3) return (5) endif
    if (k == 4) return (4) endif
    if (k == 5) return (4) endif
    if (k == 6) return (3) endif
    if (k == 7) return (3) endif
    if (k == 8) return (3) endif
    if (k == 9) return (3) endif
    return (0)
end

integer proc getSize(integer k)
    if (k == 1) return (202) endif
    if (k == 2) return (20) endif
    if (k == 3) return (12) endif
    if (k == 4) return (10) endif
    if (k == 5) return (10) endif
    if (k == 6) return (8) endif
    if (k == 7) return (8) endif
    if (k == 8) return (8) endif
    if (k == 9) return (8) endif
    return (1)
end

string proc formatBigInt(integer high_val, integer low_val)
    string low_str[15] = Str(low_val)
    
    while (Length(low_str) < 8)
        low_str = "0" + low_str
    endwhile
    
    if (high_val == 0)
        return (Str(low_val))
    endif
    
    return (Str(high_val) + low_str)
end

proc clearDP(integer buf_id, integer max_val)
    integer i = 1
    
    GotoBufferId(buf_id)
    EmptyBuffer()
    while (i <= max_val + 1)
        AddLine("0")
        i = i + 1
    endwhile
end

integer proc getDP(integer buf_id, integer index)
    GotoBufferId(buf_id)
    GotoLine(index)
    return (Val(GetText(1, 255)))
end

proc setDP(integer buf_id, integer index, integer val_in)
    GotoBufferId(buf_id)
    GotoLine(index)
    DelLine()
    InsertLine(Str(val_in))
end

proc Main()
    integer total_ans_low = 0
    integer total_ans_high = 10000000 // 10^15 combinations ending in 0
    integer d0 = 1
    integer num_roots = 0
    integer k = 1
    integer max_states = 1
    integer j = 1
    integer s = 0
    integer start_state = 0
    integer v_val = 0
    integer shifted_v = 0
    integer step = 1
    integer val0_low = 0
    integer val0_high = 0
    integer s_copy = 0
    integer d = 0
    integer valid_next = 0
    integer next_state = 0
    integer new_v_val = 0
    integer true_v = 0
    integer diff = 0
    integer is_div = 0
    integer raw_new_v = 0
    integer next_idx = 0
    integer cur1_low = 0
    integer cur1_high = 0
    integer c_low = 0
    integer c_high = 0
    integer fin_val0_low = 0
    integer fin_val0_high = 0
    integer state_end_copy = 0
    integer is_valid_end = 0
    integer v_end = 0
    string final_ans[30] = ""

    dp0_low_buf = CreateBuffer("dp0_low")
    dp0_high_buf = CreateBuffer("dp0_high")
    dp1_low_buf = CreateBuffer("dp1_low")
    dp1_high_buf = CreateBuffer("dp1_high")

    while (d0 <= 9)
        num_roots = 0
        k = 1
        while (k <= 9)
            if ((d0 MOD k) == 0)
                num_roots = num_roots + 1
                setR(num_roots, k)
            endif
            k = k + 1
        endwhile

        max_states = 1
        j = 1
        while (j <= num_roots)
            setMult(j, max_states)
            max_states = max_states * getSize(getR(j))
            j = j + 1
        endwhile

        clearDP(dp0_low_buf, max_states)
        clearDP(dp0_high_buf, max_states)

        start_state = 0
        j = 1
        while (j <= num_roots)
            v_val = d0 / getR(j)
            shifted_v = v_val + getShift(getR(j))
            start_state = start_state + shifted_v * getMult(j)
            j = j + 1
        endwhile

        setDP(dp0_low_buf, start_state + 1, 1)

        step = 1
        while (step <= 15)
            clearDP(dp1_low_buf, max_states)
            clearDP(dp1_high_buf, max_states)

            s = 0
            while (s < max_states)
                val0_low = getDP(dp0_low_buf, s + 1)
                val0_high = getDP(dp0_high_buf, s + 1)

                if (val0_low > 0 or val0_high > 0)
                    s_copy = s
                    j = 1
                    while (j <= num_roots)
                        setCurV(j, s_copy MOD getSize(getR(j)))
                        s_copy = s_copy / getSize(getR(j))
                        j = j + 1
                    endwhile

                    d = 0
                    while (d <= 9)
                        valid_next = 0
                        next_state = 0
                        j = 1
                        while (j <= num_roots)
                            new_v_val = getSize(getR(j)) - 1
                            if (getCurV(j) <> (getSize(getR(j)) - 1))
                                true_v = getCurV(j) - getShift(getR(j))
                                diff = d - true_v
                                is_div = 0
                                
                                if (diff >= 0)
                                    if ((diff MOD getR(j)) == 0) is_div = 1 endif
                                else
                                    if (((-diff) MOD getR(j)) == 0) is_div = 1 endif
                                endif

                                if (is_div == 1)
                                    raw_new_v = diff / getR(j)
                                    if (raw_new_v >= -getShift(getR(j)) and raw_new_v < (getSize(getR(j)) - 1 - getShift(getR(j))))
                                        new_v_val = raw_new_v + getShift(getR(j))
                                        valid_next = 1
                                    endif
                                endif
                            endif
                            next_state = next_state + new_v_val * getMult(j)
                            j = j + 1
                        endwhile

                        if (valid_next == 1)
                            next_idx = next_state + 1
                            cur1_low = getDP(dp1_low_buf, next_idx)
                            cur1_high = getDP(dp1_high_buf, next_idx)

                            cur1_low = cur1_low + val0_low
                            cur1_high = cur1_high + val0_high
                            
                            if (cur1_low >= 100000000)
                                cur1_low = cur1_low - 100000000
                                cur1_high = cur1_high + 1
                            endif

                            setDP(dp1_low_buf, next_idx, cur1_low)
                            setDP(dp1_high_buf, next_idx, cur1_high)
                        endif
                        d = d + 1
                    endwhile
                endif
                s = s + 1
            endwhile

            s = 0
            while (s < max_states)
                c_low = getDP(dp1_low_buf, s + 1)
                c_high = getDP(dp1_high_buf, s + 1)
                setDP(dp0_low_buf, s + 1, c_low)
                setDP(dp0_high_buf, s + 1, c_high)
                s = s + 1
            endwhile
            step = step + 1
        endwhile

        s = 0
        while (s < max_states)
            fin_val0_low = getDP(dp0_low_buf, s + 1)
            fin_val0_high = getDP(dp0_high_buf, s + 1)

            if (fin_val0_low > 0 or fin_val0_high > 0)
                state_end_copy = s
                is_valid_end = 0
                j = 1
                while (j <= num_roots)
                    v_end = state_end_copy MOD getSize(getR(j))
                    state_end_copy = state_end_copy / getSize(getR(j))
                    if (v_end <> (getSize(getR(j)) - 1))
                        if ((v_end - getShift(getR(j))) == 0)
                            is_valid_end = 1
                        endif
                    endif
                    j = j + 1
                endwhile

                if (is_valid_end == 1)
                    total_ans_low = total_ans_low + fin_val0_low
                    total_ans_high = total_ans_high + fin_val0_high
                    if (total_ans_low >= 100000000)
                        total_ans_low = total_ans_low - 100000000
                        total_ans_high = total_ans_high + 1
                    endif
                endif
            endif
            s = s + 1
        endwhile

        d0 = d0 + 1
    endwhile

    GotoBufferId(dp0_low_buf)
    AbandonFile()
    GotoBufferId(dp0_high_buf)
    AbandonFile()
    GotoBufferId(dp1_low_buf)
    AbandonFile()
    GotoBufferId(dp1_high_buf)
    AbandonFile()

    final_ans = formatBigInt(total_ans_high, total_ans_low)

    CopyToWinClip(final_ans)
    Warn(final_ans)
    CopyToWinClip(final_ans)
end
