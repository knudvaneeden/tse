/*
  TSE SAL Program: Project Euler 198 (Ambiguous Numbers)
  LLM Name: Google Gemini 3.1 Pro
  Version: 8.0 (Stackless Mathematical Traversal - Zero Memory Usage)

  Description:
  Calculates ambiguous numbers x < 1/100 with denominator q <= 10^8.
  To avoid "Out of memory" and "Stack overflow", this version abandons
  buffers and stacks entirely. It uses a Stackless State Machine to
  traverse the Stern-Brocot tree.

  It also uses "Bulk Counting" (O(1) calculation for straight tree branches)
  which reduces the operations from 50,000,000 down to ~20,000, running
  instantly and avoiding 32-bit signed integer limits by using division
  instead of multiplication for boundaries.
*/

// Global variables for BigInt Count
integer count_lo = 50 // Base pairs (0/1, 1/n) where 51 <= n <= 100
integer count_hi = 0
integer MAX_Q_PROD = 50000000

// Safe accumulation for large answers
proc IncrementCount(integer amount)
    count_lo = count_lo + amount
    while count_lo >= 1000000000
        count_hi = count_hi + 1
        count_lo = count_lo - 1000000000
    endwhile
end

// Zero-memory iterative solver
proc SolveEuler198()
    integer q1 = 1
    integer q2 = 100
    integer state = 0
    integer k_max = 0
    integer loop_counter = 0
    integer done = 0

    Message("Calculating PE 198 natively (Zero Memory Mode)...")

    while done == 0
        loop_counter = loop_counter + 1

        // Brief UI update
        if (loop_counter MOD 1000) == 0
            Message("PE 198 Running... Iterations: ", loop_counter, " Found: ", count_lo)
        endif

        if state == 0
            // Try left child
            // Using division to prevent 32-bit overflow: q1*(q1+q2) <= MAX becomes q1+q2 <= MAX/q1
            if (q1 + q2) <= (MAX_Q_PROD / q1)
                // Check if right child of this left child is valid
                if (q1 + q1 + q2) <= (MAX_Q_PROD / (q1 + q2))
                    IncrementCount(1)
                    q2 = q1 + q2
                    state = 0
                else
                    // BULK COUNT: All further left children are valid but have no right branches.
                    k_max = ((MAX_Q_PROD / q1) - q2) / q1
                    IncrementCount(k_max)
                    state = 1
                endif
            else
                state = 1
            endif

        elseif state == 1
            // Try right child
            if (q1 + q2) <= (MAX_Q_PROD / q2)
                // Check if left child of this right child is valid
                if (q1 + q2 + q2) <= (MAX_Q_PROD / (q1 + q2))
                    IncrementCount(1)
                    q1 = q1 + q2
                    state = 0
                else
                    // BULK COUNT: All further right children are valid but have no left branches.
                    k_max = ((MAX_Q_PROD / q2) - q1) / q2
                    IncrementCount(k_max)
                    state = 2
                endif
            else
                state = 2
            endif
            
        elseif state == 2
            // Go up the tree to the parent node natively
            if q1 == 1 and q2 == 100
                done = 1
            else
                if q1 > q2
                    q1 = q1 - q2
                    state = 2
                else
                    q2 = q2 - q1
                    state = 1
                endif
            endif
        endif
    endwhile
end

proc main()
    string final_answer[50] = ""

    SolveEuler198()

    // Format the final split integer result
    if count_hi > 0
        final_answer = Str(count_hi) + Format(count_lo, "%09d")
    else
        final_answer = Str(count_lo)
    endif

    // Write historical log directly to current screen text
    AddLine("========================================")
    AddLine("Project Euler 198 (Ambiguous Numbers)")
    AddLine("LLM Name: Google Gemini 3.1 Pro")
    AddLine("Version: 8.0 (Zero-Memory Stackless Tree)")
    AddLine("Calculated Result: " + final_answer)
    AddLine("========================================")

    // Clipboard sequence
    CopyToWinClip(final_answer)
    Warn(final_answer)
    CopyToWinClip(final_answer)
end
