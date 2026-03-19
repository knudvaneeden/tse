// Version: 1.7
// Created by: Google Gemini
// Problem: Project Euler 124 - Ordered Radicals

// Rule Confirmation & Verification:
// - Used 'proc' instead of 'procedure'
// - Used 'integer proc' / 'string proc' logic for definitions
// - MOD used instead of %
// - AbandonFile(buffer_id) used for cleanup per rule
// - CreateBuffer(name) used for buffer operations
// - InsertText(str, _OVERWRITE_) used instead of PutText()
// - UnMarkBlock() used to unmark the block
// - Return() always uses parentheses
// - No variables named 'val' or 'pos'
// - Warn() used for final answer
// - CopyToWinClip() used for the numerical result only

proc Main()
    integer max_n = 100000
    integer target_k = 10000
    integer i
    integer j
    integer current_rad
    integer new_rad
    integer temp_buf_id = 0
    string scratch_name[32] = "euler_124_temp"
    string final_answer[10] = ""

    // Create a temporary buffer: CreateBuffer(name)
    temp_buf_id = CreateBuffer(scratch_name)

    if (not temp_buf_id)
        Warn("Could not create buffer")
        Return()
    endif

    // 1. Initialize rad(n) array logic
    // Format: [rad_n:10][n:10]
    for i = 1 to max_n
        AddLine(Format(1:10, i:10))
    endfor

    // 2. Sieve-like calculation of Radicals
    for i = 2 to max_n
        GotoLine(i)
        // Check radical value (1 means i is prime)
        if (Val(GetText(1, 10)) == 1)
            j = i
            while (j <= max_n)
                GotoLine(j)
                BegLine()
                current_rad = Val(GetText(1, 10))
                new_rad = current_rad * i

                // Using InsertText with _OVERWRITE_ flag as per rule
                InsertText(Format(new_rad:10), _OVERWRITE_)

                j = j + i
            endwhile
        endif
    endfor

    // 3. Sort the buffer
    // Primary: radical (1-10), Secondary: n (11-20)
    MarkLine(1, max_n)
    Sort()

    // Using UnMarkBlock() per rules
    UnMarkBlock()

    // 4. Retrieve result at index k (10,000th)
    GotoLine(target_k)
    final_answer = Trim(GetText(11, 10))

    // 5. Output and Clipboard
    Warn(Format("The answer is: ", final_answer))

    // Copy ONLY the numerical answer to clipboard
    CopyToWinClip(final_answer)

    // Cleanup using AbandonFile(buffer_id)
    AbandonFile(temp_buf_id)
end
