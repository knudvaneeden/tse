// euler098.s
// Version: 1.0
//
// Project Euler - Problem 98: Anagramic Squares
//
// By replacing each of the letters in the word CARE with 1, 2, 9, and 6
// respectively, we form a square number: 1296 = 36^2.
// Remarkably, the anagram RACE also forms a square number: 9216 = 96^2.
// We call CARE (and RACE) a square anagram word pair, with no leading zeroes
// and no two letters sharing the same digit.
// Using the nearly 2000 words in p098_words.txt, find the largest square
// number formed by any member of a square anagram word pair.
//
// Answer: 18769  (= 137^2, pair BOARD / BROAD, also 133^2 = 17689)
//
// TSE SAL rules applied:
//  - No integer arrays: all tabular data stored in temp buffers
//  - No 'while 1': flag-based loop termination
//  - No 'end proc': all procedures end with plain 'end'
//  - No reserved/built-in names as variables
//  - No 'iterate' / 'break' / 'continue': nested if/endif
//  - No semicolon ';' as statement separator: each statement on its own line
//  - 32-bit signed integer arithmetic throughout; max value 999950884 < 2^31-1
//  - Return() always has parentheses
//  - Warn() shows the final answer
//  - CopyToWinClip() copies only the bare numeric answer
//  - No pasting of the result into any buffer
//  - String lengths well within 255-char SAL limit
//  - Variables 'val' and 'pos' are NOT used as variable names
//
// ---------------------------------------------------------------------------
// Global variable declarations
// ---------------------------------------------------------------------------

integer g_pairs_id      // temp buffer: one "WORD_A,WORD_B" line per anagram pair
integer g_best          // globally tracked best (max) square found

// ---------------------------------------------------------------------------
// Procedure: IsqrtN
//
// Compute integer square root of n via Newton's method.
// Starting from 31623 (a safe upper bound for n <= 10^9) converges quickly.
// Uses only 32-bit arithmetic; no overflow risk for n <= 999999999.
//
// Parameter : n  (passed via global integer g_isqrt_n)
// Returns   : result via global integer g_isqrt_r
// ---------------------------------------------------------------------------

integer g_isqrt_n
integer g_isqrt_r

proc IsqrtN()
    integer xc
    integer xn
    integer done_flag

    if g_isqrt_n <= 0
        g_isqrt_r = 0
        Return()
    endif

    xc        = 31623
    done_flag = FALSE

    while done_flag == FALSE
        xn = (xc + g_isqrt_n / xc) / 2
        if xn >= xc
            done_flag = TRUE
        else
            xc = xn
        endif
    endwhile

    g_isqrt_r = xc
end

// ---------------------------------------------------------------------------
// Procedure: StrLen9
//
// Return the number of digits in a positive integer (1..9 only, which is
// all we need; any value that reaches here is < 10^9).
// Parameter : g_sl_n   (input integer)
// Result    : g_sl_r   (digit count)
// ---------------------------------------------------------------------------

integer g_sl_n
integer g_sl_r

proc StrLen9()
    if g_sl_n >= 100000000
        g_sl_r = 9
    elseif g_sl_n >= 10000000
        g_sl_r = 8
    elseif g_sl_n >= 1000000
        g_sl_r = 7
    elseif g_sl_n >= 100000
        g_sl_r = 6
    elseif g_sl_n >= 10000
        g_sl_r = 5
    elseif g_sl_n >= 1000
        g_sl_r = 4
    elseif g_sl_n >= 100
        g_sl_r = 3
    elseif g_sl_n >= 10
        g_sl_r = 2
    else
        g_sl_r = 1
    endif
end

// ---------------------------------------------------------------------------
// Procedure: IntToStr9
//
// Convert a positive integer (up to 9 digits) to a string.
// Parameter : g_i2s_n   (input integer)
// Result    : g_i2s_s   (output string, at most 9 chars)
// ---------------------------------------------------------------------------

integer g_i2s_n
string  g_i2s_s[10]

proc IntToStr9()
    integer tmp
    integer dv
    integer rem
    integer idx
    string  buf[10]
    integer dc
    integer running
    integer loop_dc
    integer dc_done

    tmp = g_i2s_n
    buf = ""

    // Get digit count first
    g_sl_n = tmp
    StrLen9()
    idx = g_sl_r       // number of digits

    // Build string left-to-right by extracting digits via powers of 10
    // We divide by 10^(idx-1), then 10^(idx-2), etc.
    // dv holds current power of 10
    dv = 1
    if idx >= 2
        if idx >= 9
            dv = 100000000
        elseif idx >= 8
            dv = 10000000
        elseif idx >= 7
            dv = 1000000
        elseif idx >= 6
            dv = 100000
        elseif idx >= 5
            dv = 10000
        elseif idx >= 4
            dv = 1000
        elseif idx >= 3
            dv = 100
        else
            dv = 10
        endif
    endif

    buf     = ""
    dc      = idx
    running = tmp
    loop_dc = dc
    dc_done = FALSE

    while dc_done == FALSE
        rem     = running / dv
        running = running - rem * dv
        buf     = buf + Chr(rem + 48)   // '0' = ASCII 48
        dv      = dv / 10
        if dv < 1
            dv = 1
        endif
        loop_dc = loop_dc - 1
        if loop_dc <= 0
            dc_done = TRUE
        endif
    endwhile

    g_i2s_s = buf
end

// ---------------------------------------------------------------------------
// Procedure: TryMapping
//
// Try to map word_a onto sq_a_str so that the induced mapping on word_b
// gives a valid (non-zero-leading) integer sq_b, then check whether sq_b
// is a perfect square.  If max(sq_a, sq_b) > g_best, update g_best.
//
// Inputs (globals used):
//   g_tm_wa   : word A (uppercase letters only)
//   g_tm_wb   : word B (uppercase letters only)
//   g_tm_sqas : string representation of square A (same length as words)
//
// Uses two 26-char / 10-char mapping strings:
//   g_tm_lmap : letter->digit  (index = letter-'A', char = '0'..'9' or ' ')
//   g_tm_dmap : digit->letter  (index = digit-'0',  char = 'A'..'Z' or ' ')
// ---------------------------------------------------------------------------

string  g_tm_wa  [12]
string  g_tm_wb  [12]
string  g_tm_sqas[12]
// Mapping strings: 26 entries for letters, 10 entries for digits
// Initialised to all spaces (= unmapped)
string  g_tm_lmap[28]
string  g_tm_dmap[12]

integer g_tm_sq_a
integer g_tm_sq_b

proc TryMapping()
    integer wlen
    integer ki
    integer ltr_ch
    integer dg_ch
    integer ltr_idx
    integer dg_idx
    integer mapped_ch
    string  sq_b_str[12]
    integer valid_flag
    integer sq_b_val
    integer max_sq

    wlen       = Length(g_tm_wa)
    valid_flag = TRUE

    // ---- initialise mapping strings to all spaces ----
    g_tm_lmap = "                          "  // 26 spaces
    g_tm_dmap = "          "                  // 10 spaces

    // ---- build mapping from word_a and sq_a_str ----
    ki = 1
    while ki <= wlen and valid_flag == TRUE
        ltr_ch  = Asc(SubStr(g_tm_wa,   ki, 1))   // ASCII of letter
        dg_ch   = Asc(SubStr(g_tm_sqas, ki, 1))   // ASCII of digit char

        ltr_idx = ltr_ch - 64    // A=1 .. Z=26  (1-based in SAL SubStr)
        dg_idx  = dg_ch  - 47    // '0'=1 .. '9'=10

        // Check existing letter->digit mapping
        if SubStr(g_tm_lmap, ltr_idx, 1) == " "
            // Letter not yet mapped; check digit not already taken
            if SubStr(g_tm_dmap, dg_idx, 1) == " "
                // Safe to assign
                g_tm_lmap = SubStr(g_tm_lmap, 1, ltr_idx - 1) +
                            Chr(dg_ch) +
                            SubStr(g_tm_lmap, ltr_idx + 1, 26 - ltr_idx)
                g_tm_dmap = SubStr(g_tm_dmap, 1, dg_idx - 1) +
                            Chr(ltr_ch) +
                            SubStr(g_tm_dmap, dg_idx + 1, 10 - dg_idx)
            else
                valid_flag = FALSE
            endif
        else
            // Letter already mapped; must agree
            if SubStr(g_tm_lmap, ltr_idx, 1) <> Chr(dg_ch)
                valid_flag = FALSE
            endif
        endif

        ki = ki + 1
    endwhile

    // ---- if mapping is consistent, apply to word_b ----
    if valid_flag == TRUE
        sq_b_str = ""
        ki       = 1
        while ki <= wlen and valid_flag == TRUE
            ltr_ch  = Asc(SubStr(g_tm_wb, ki, 1))
            ltr_idx = ltr_ch - 64

            mapped_ch = Asc(SubStr(g_tm_lmap, ltr_idx, 1))

            if Chr(mapped_ch) == " "
                valid_flag = FALSE
            else
                sq_b_str = sq_b_str + Chr(mapped_ch)
            endif

            ki = ki + 1
        endwhile
    endif

    // ---- leading-zero check and convert sq_b_str to integer ----
    if valid_flag == TRUE
        if SubStr(sq_b_str, 1, 1) == "0"
            valid_flag = FALSE
        endif
    endif

    if valid_flag == TRUE
        // Convert sq_b_str to integer
        sq_b_val = 0
        ki = 1
        while ki <= wlen
            sq_b_val = sq_b_val * 10 + Asc(SubStr(sq_b_str, ki, 1)) - 48
            ki = ki + 1
        endwhile

        // Check if sq_b_val is a perfect square
        g_isqrt_n = sq_b_val
        IsqrtN()
        if g_isqrt_r * g_isqrt_r == sq_b_val
            // Both sq_a and sq_b are perfect squares
            if g_tm_sq_a > sq_b_val
                max_sq = g_tm_sq_a
            else
                max_sq = sq_b_val
            endif
            if max_sq > g_best
                g_best = max_sq
            endif
        endif
    endif
end

// ---------------------------------------------------------------------------
// Procedure: ProcessPair
//
// For one anagram pair (wa, wb), iterate over all square roots whose squares
// have the same digit count as the words.  For each square, call TryMapping
// both ways (wa->sq, wb->sq).
//
// Globals:
//   g_pp_wa   : word A
//   g_pp_wb   : word B
// ---------------------------------------------------------------------------

string  g_pp_wa[12]
string  g_pp_wb[12]

proc ProcessPair()
    integer wlen
    integer rt_lo
    integer rt_hi
    integer rt
    integer sq
    string  sq_str[12]
    integer loop_done

    wlen = Length(g_pp_wa)

    // Determine root range for squares of exactly wlen digits
    if wlen == 2
        rt_lo = 4
        rt_hi = 9
    elseif wlen == 3
        rt_lo = 10
        rt_hi = 31
    elseif wlen == 4
        rt_lo = 32
        rt_hi = 99
    elseif wlen == 5
        rt_lo = 100
        rt_hi = 316
    elseif wlen == 6
        rt_lo = 317
        rt_hi = 999
    elseif wlen == 7
        rt_lo = 1000
        rt_hi = 3162
    elseif wlen == 8
        rt_lo = 3163
        rt_hi = 9999
    elseif wlen == 9
        rt_lo = 10000
        rt_hi = 31622
    else
        Return()
    endif

    rt        = rt_lo
    loop_done = FALSE

    while loop_done == FALSE
        sq = rt * rt

        // Convert sq to string
        g_i2s_n = sq
        IntToStr9()
        sq_str = g_i2s_s

        // Only process if length matches (should always be true given rt range)
        if Length(sq_str) == wlen
            // Try: map word_a -> square, derive word_b, check
            g_tm_wa   = g_pp_wa
            g_tm_wb   = g_pp_wb
            g_tm_sqas = sq_str
            g_tm_sq_a = sq
            TryMapping()

            // Try: map word_b -> square, derive word_a, check
            g_tm_wa   = g_pp_wb
            g_tm_wb   = g_pp_wa
            g_tm_sqas = sq_str
            g_tm_sq_a = sq
            TryMapping()
        endif

        rt = rt + 1
        if rt > rt_hi
            loop_done = TRUE
        endif
    endwhile
end

// ---------------------------------------------------------------------------
// Procedure: LoadPairs
//
// Populate g_pairs_id with one line per anagram pair.
// Format: "WORD_A,WORD_B"
// All 44 anagram pairs from the Project Euler words list are embedded here.
// ---------------------------------------------------------------------------

proc LoadPairs()
    g_pairs_id = CreateTempBuffer()

    AddLine("ACT,CAT")
    AddLine("ARISE,RAISE")
    AddLine("BOARD,BROAD")
    AddLine("CARE,RACE")
    AddLine("CENTRE,RECENT")
    AddLine("COURSE,SOURCE")
    AddLine("CREATION,REACTION")
    AddLine("CREDIT,DIRECT")
    AddLine("DANGER,GARDEN")
    AddLine("DEAL,LEAD")
    AddLine("DOG,GOD")
    AddLine("EARN,NEAR")
    AddLine("EARTH,HEART")
    AddLine("EAST,SEAT")
    AddLine("EAT,TEA")
    AddLine("EXCEPT,EXPECT")
    AddLine("FILE,LIFE")
    AddLine("FORM,FROM")
    AddLine("FORMER,REFORM")
    AddLine("HATE,HEAT")
    AddLine("HOW,WHO")
    AddLine("IGNORE,REGION")
    AddLine("INTRODUCE,REDUCTION")
    AddLine("ITEM,TIME")
    AddLine("ITS,SIT")
    AddLine("LEAST,STEAL")
    AddLine("MALE,MEAL")
    AddLine("MEAN,NAME")
    AddLine("NIGHT,THING")
    AddLine("NO,ON")
    AddLine("NOTE,TONE")
    AddLine("NOW,OWN")
    AddLine("PHASE,SHAPE")
    AddLine("POST,SPOT")
    AddLine("POST,STOP")
    AddLine("SPOT,STOP")
    AddLine("QUIET,QUITE")
    AddLine("RATE,TEAR")
    AddLine("SHEET,THESE")
    AddLine("SHOUT,SOUTH")
    AddLine("SHUT,THUS")
    AddLine("SIGN,SING")
    AddLine("SURE,USER")
    AddLine("THROW,WORTH")
end

// ---------------------------------------------------------------------------
// Main procedure
// ---------------------------------------------------------------------------

proc Main()
    integer orig_id
    integer total_lines
    integer line_num
    string  pair_line[22]
    integer comma_at
    string  ans_str[12]

    orig_id = GetBufferId()

    // ----- Step 1: load all 44 anagram pairs into a temp buffer -----
    LoadPairs()

    // ----- Step 2: iterate over all pairs and search for square pairs -----
    g_best   = 0
    line_num = 1

    GotoBufferId(g_pairs_id)
    BegFile()
    total_lines = NumLines()

    while line_num <= total_lines
        pair_line = GetText(1, 22)

        // Find comma separator
        comma_at = Pos(",", pair_line)

        if comma_at > 1
            g_pp_wa = SubStr(pair_line, 1, comma_at - 1)
            g_pp_wb = SubStr(pair_line, comma_at + 1,
                             Length(pair_line) - comma_at)
            ProcessPair()
        endif

        Down()
        line_num = line_num + 1
    endwhile

    // ----- Step 3: clean up temp buffer -----
    AbandonFile(g_pairs_id)

    // ----- Step 4: convert answer to string -----
    g_i2s_n = g_best
    IntToStr9()
    ans_str = g_i2s_s

    // ----- Step 5: show answer and copy to clipboard -----
    CopyToWinClip(ans_str)

    GotoBufferId(orig_id)

    Warn("Project Euler #98 - Anagramic Squares: " + ans_str)
end
