// euler081.s
// Version: 1.4
//
// Project Euler - Problem 81
// Find the minimal path sum from top-left to bottom-right of an 80x80 matrix,
// moving only right or down.
//
// Algorithm:
//   Standard 2-D dynamic programming:
//     dp[0][0] = mat[0][0]
//     dp[0][c] = dp[0][c-1] + mat[0][c]              (first row: right only)
//     dp[r][0] = dp[r-1][0] + mat[r][0]              (first col: down only)
//     dp[r][c] = min(dp[r-1][c], dp[r][c-1]) + mat[r][c]
//
// Storage:
//   Two temporary buffers, 6400 lines each (80 rows x 80 cols, row-major).
//   Line index for cell (r,c) = r*80 + c + 1  (1-based TSE line numbers).
//   No integer arrays are used anywhere.
//
// String width:
//   Individual cell values fit in tok[20].
//   Matrix CSV rows are ~400 chars — they are NEVER loaded into a single
//   string.  Instead we scan character by character using CurrChar().
//
// TSE SAL rules observed:
//   1. No integer arrays      — replaced by temp buffers
//   2. No reserved names      — all variable names checked
//   3. Strings <= 255 chars   — longest string is ans_str[20]
//   4. 32-bit arithmetic only — max sum ~80*9999 = 799920
//   5. Warn() for final answer
//   6. CopyToWinClip() copies only the bare number string
//   7. Result is NOT written into any editor buffer
//   8. ALL return statements use parentheses: return() or return(expr)
//   9. Logical operators without dots: AND, OR, NOT  (not .AND. etc.)

// -----------------------------------------------------------------------
// Constants
// -----------------------------------------------------------------------
constant NROWS = 80
constant NCOLS = 80

// ASCII codes used in character scanning
constant ASCII_COMMA = 44    // ','
constant ASCII_CR    = 13    // carriage return (not a digit)
constant ASCII_ZERO  = 48    // '0'
constant ASCII_NINE  = 57    // '9'

// -----------------------------------------------------------------------
// Global buffer IDs (plain integers — no arrays)
// -----------------------------------------------------------------------
integer gbuf_mat   // 6400-line buffer holding raw matrix values
integer gbuf_dp    // 6400-line buffer holding DP accumulated sums

// -----------------------------------------------------------------------
// LineIdx: return the 1-based buffer line number for cell (rr, cc)
//   rr, cc are both 0-based
// -----------------------------------------------------------------------
integer proc LineIdx(integer rr, integer cc)
    return (rr * NCOLS + cc + 1)
end

// -----------------------------------------------------------------------
// SetBufVal: write integer vv to line lnidx of buffer bid
// -----------------------------------------------------------------------
proc SetBufVal(integer bid, integer lnidx, integer vv)
    integer prev_id
    prev_id = GetBufferId()
    GotoBufferId(bid)
    GotoLine(lnidx)
    BegLine()
    DelToEol()
    InsertText(Str(vv))
    GotoBufferId(prev_id)
end

// -----------------------------------------------------------------------
// GetBufVal: read the integer stored on line lnidx of buffer bid
// -----------------------------------------------------------------------
integer proc GetBufVal(integer bid, integer lnidx)
    integer prev_id
    integer rv
    prev_id = GetBufferId()
    GotoBufferId(bid)
    GotoLine(lnidx)
    BegLine()
    rv = Val(GetText(1, 20))
    GotoBufferId(prev_id)
    return (rv)
end

// -----------------------------------------------------------------------
// MinTwo: return the smaller of two 32-bit integers
// -----------------------------------------------------------------------
integer proc MinTwo(integer aa, integer bb)
    if aa <= bb
        return (aa)
    endif
    return (bb)
end

// -----------------------------------------------------------------------
// ReadMatrixFromBuf:
//   Parse the 80x80 CSV matrix from the open buffer src_id into gbuf_mat.
//   We scan each line one character at a time with CurrChar() / Right()
//   so that no string longer than 20 chars is ever needed.
//
//   CurrChar() returns:
//     >= 0   : ASCII code of the character under the cursor
//     -1     : cursor is past end-of-line (on the virtual EOL position)
// -----------------------------------------------------------------------
proc ReadMatrixFromBuf(integer src_id)
    integer prev_id
    integer rr          // matrix row  (0-based)
    integer cc          // matrix col  (0-based)
    integer chcode      // ASCII code from CurrChar()
    integer tokval      // integer being built from consecutive digit chars
    integer got_digit   // non-zero once we have accumulated at least one digit
    integer done_row    // flag: set to 1 when all NCOLS tokens are parsed

    prev_id = GetBufferId()
    GotoBufferId(src_id)
    BegFile()

    rr = 0
    while rr < NROWS
        GotoLine(rr + 1)
        BegLine()

        cc        = 0
        tokval    = 0
        got_digit = 0
        done_row  = 0

        while done_row == 0
            chcode = CurrChar()

            if chcode < 0
                // End-of-line: flush final token for this row
                if got_digit
                    SetBufVal(gbuf_mat, LineIdx(rr, cc), tokval)
                    cc = cc + 1
                endif
                done_row = 1

            elseif chcode == ASCII_COMMA
                // Comma: flush current token, start next
                if got_digit
                    SetBufVal(gbuf_mat, LineIdx(rr, cc), tokval)
                    cc = cc + 1
                endif
                tokval    = 0
                got_digit = 0
                Right()

            elseif chcode >= ASCII_ZERO AND chcode <= ASCII_NINE
                // Digit: accumulate  (Horner's method, no string needed)
                tokval    = tokval * 10 + (chcode - ASCII_ZERO)
                got_digit = 1
                Right()

            else
                // Any other character (space, CR, etc.) — skip
                Right()
            endif

            // Safety: if we have already stored all NCOLS tokens, stop
            if cc >= NCOLS
                done_row = 1
            endif
        endwhile

        rr = rr + 1
    endwhile

    GotoBufferId(prev_id)
end

// -----------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------
proc Main()
    integer src_id        // buffer ID of the open matrix file
    integer rr            // row index   (0-based)
    integer cc            // col index   (0-based)
    integer above_val     // DP value from the cell directly above
    integer left_val      // DP value from the cell to the left
    integer mat_val       // raw value read from gbuf_mat
    integer dp_val        // DP value being written
    integer ans_val       // final answer (dp[79][79])
    string  ans_str[20]   // string form of the answer

    // ------------------------------------------------------------------
    // Step 1: load the matrix file from disk into a buffer
    // ------------------------------------------------------------------
    src_id = GetBufferId("p081_matrix.txt")
    if src_id == 0
        src_id = EditFile("p081_matrix.txt")
    endif
    if src_id == 0
        Warn("euler081: Could not load p081_matrix.txt - check it is in the TSE working directory.")
        return()
    endif

    // ------------------------------------------------------------------
    // Step 2: allocate gbuf_mat — 6400 lines, each initialised to "0"
    //   CreateTempBuffer() gives us exactly 1 blank line already.
    //   We use BegLine()+DelToEol()+InsertText() for line 1, then
    //   AddLine() for lines 2 through 6400.
    // ------------------------------------------------------------------
    gbuf_mat = CreateTempBuffer()
    GotoBufferId(gbuf_mat)
    BegLine()
    DelToEol()
    InsertText("0")
    rr = 1
    while rr < NROWS * NCOLS
        AddLine("0")
        rr = rr + 1
    endwhile

    // ------------------------------------------------------------------
    // Step 3: allocate gbuf_dp — same structure
    // ------------------------------------------------------------------
    gbuf_dp = CreateTempBuffer()
    GotoBufferId(gbuf_dp)
    BegLine()
    DelToEol()
    InsertText("0")
    rr = 1
    while rr < NROWS * NCOLS
        AddLine("0")
        rr = rr + 1
    endwhile

    // ------------------------------------------------------------------
    // Step 4: parse the matrix file into gbuf_mat
    // ------------------------------------------------------------------
    ReadMatrixFromBuf(src_id)

    // ------------------------------------------------------------------
    // Step 5: fill the DP table
    // ------------------------------------------------------------------

    // Cell (0, 0)
    dp_val = GetBufVal(gbuf_mat, LineIdx(0, 0))
    SetBufVal(gbuf_dp, LineIdx(0, 0), dp_val)

    // First row — can only arrive from the left
    cc = 1
    while cc < NCOLS
        mat_val  = GetBufVal(gbuf_mat, LineIdx(0, cc))
        left_val = GetBufVal(gbuf_dp,  LineIdx(0, cc - 1))
        dp_val   = left_val + mat_val
        SetBufVal(gbuf_dp, LineIdx(0, cc), dp_val)
        cc = cc + 1
    endwhile

    // First column — can only arrive from above
    rr = 1
    while rr < NROWS
        mat_val   = GetBufVal(gbuf_mat, LineIdx(rr, 0))
        above_val = GetBufVal(gbuf_dp,  LineIdx(rr - 1, 0))
        dp_val    = above_val + mat_val
        SetBufVal(gbuf_dp, LineIdx(rr, 0), dp_val)
        rr = rr + 1
    endwhile

    // Interior cells — min of above or left, plus current cell value
    rr = 1
    while rr < NROWS
        cc = 1
        while cc < NCOLS
            mat_val   = GetBufVal(gbuf_mat, LineIdx(rr, cc))
            above_val = GetBufVal(gbuf_dp,  LineIdx(rr - 1, cc))
            left_val  = GetBufVal(gbuf_dp,  LineIdx(rr,     cc - 1))
            dp_val    = MinTwo(above_val, left_val) + mat_val
            SetBufVal(gbuf_dp, LineIdx(rr, cc), dp_val)
            cc = cc + 1
        endwhile
        rr = rr + 1
    endwhile

    // ------------------------------------------------------------------
    // Step 6: retrieve the answer from dp[79][79]
    // ------------------------------------------------------------------
    ans_val = GetBufVal(gbuf_dp, LineIdx(NROWS - 1, NCOLS - 1))
    ans_str = Str(ans_val)

    // ------------------------------------------------------------------
    // Step 7: discard both temp buffers (no save prompt)
    // ------------------------------------------------------------------
    AbandonFile(gbuf_mat)
    AbandonFile(gbuf_dp)

    // ------------------------------------------------------------------
    // Step 8: deliver the result
    //   - CopyToWinClip()  receives ONLY the bare number (ans_str)
    //   - Warn()           shows the full message to the user
    //   - The result is NOT inserted into any editor buffer
    // ------------------------------------------------------------------
    CopyToWinClip(ans_str)
    Warn("Project Euler #81 answer: " + ans_str)

end
