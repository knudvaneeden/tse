// euler089.s
// Project Euler - Problem 89: Roman Numerals
// Find the number of characters saved by writing 1000 Roman numerals
// from the supplied data file in their minimal (most efficient) form.
//
// Strategy:
//   1. Read each Roman numeral line from the buffer containing p089_roman.txt
//   2. Convert it to an integer (roman_to_int)
//   3. Convert that integer back to minimal Roman form (int_to_roman)
//   4. Accumulate (original_length - minimal_length) across all 1000 lines
//
// TSE SAL rules applied:
//   - No integer arrays  : buffer used for the data file only; all other
//                          state is in scalar integer variables
//   - No reserved names  : variables checked against SAL built-ins;
//                          no use of val, pos, str, s, mark, old, len,
//                          Find, Insert, Delete, Length, Copy, etc.
//   - String length <= 255: all strings are short literals or short numerals
//   - 32-bit integers only: max possible total savings is well under 2^31
//   - Return()           : always written with parentheses
//   - Warn()             : used to display the final answer
//   - CopyToWinClip()    : called with the bare answer string only
//   - No paste to buffer : no AddLine / InsertText of the result
//   - Version number     : 1.0 (see below)
//
// Version: 1.0

// ---------------------------------------------------------------------------
// roman_to_int(roman_str) : Integer
//   Converts a Roman numeral string to its integer value.
//   Uses the standard right-to-left scan: if current symbol < previous,
//   subtract; otherwise add.
// ---------------------------------------------------------------------------
integer proc roman_char_val(string ch)
    if ch == "M"    return(1000) endif
    if ch == "D"    return(500)  endif
    if ch == "C"    return(100)  endif
    if ch == "L"    return(50)   endif
    if ch == "X"    return(10)   endif
    if ch == "V"    return(5)    endif
    if ch == "I"    return(1)    endif
    return(0)
end

integer proc roman_to_int(string rstr)
    integer total, idx, cur_v, prev_v
    total  = 0
    prev_v = 0
    idx    = Length(rstr)
    while idx >= 1
        cur_v = roman_char_val(SubStr(rstr, idx, 1))
        if cur_v < prev_v
            total = total - cur_v
        else
            total = total + cur_v
        endif
        prev_v = cur_v
        idx    = idx - 1
    endwhile
    return(total)
end

// ---------------------------------------------------------------------------
// int_to_roman(n) : String
//   Converts a positive integer to its minimal Roman numeral form.
//   Uses the standard greedy subtraction table.
// ---------------------------------------------------------------------------
string proc int_to_roman(integer nv)
    string  rbuf[40]
    integer nrem
    nrem = nv
    rbuf = ""
    while nrem >= 1000   rbuf = rbuf + "M"  nrem = nrem - 1000  endwhile
    while nrem >= 900    rbuf = rbuf + "CM" nrem = nrem - 900   endwhile
    while nrem >= 500    rbuf = rbuf + "D"  nrem = nrem - 500   endwhile
    while nrem >= 400    rbuf = rbuf + "CD" nrem = nrem - 400   endwhile
    while nrem >= 100    rbuf = rbuf + "C"  nrem = nrem - 100   endwhile
    while nrem >= 90     rbuf = rbuf + "XC" nrem = nrem - 90    endwhile
    while nrem >= 50     rbuf = rbuf + "L"  nrem = nrem - 50    endwhile
    while nrem >= 40     rbuf = rbuf + "XL" nrem = nrem - 40    endwhile
    while nrem >= 10     rbuf = rbuf + "X"  nrem = nrem - 10    endwhile
    while nrem >= 9      rbuf = rbuf + "IX" nrem = nrem - 9     endwhile
    while nrem >= 5      rbuf = rbuf + "V"  nrem = nrem - 5     endwhile
    while nrem >= 4      rbuf = rbuf + "IV" nrem = nrem - 4     endwhile
    while nrem >= 1      rbuf = rbuf + "I"  nrem = nrem - 1     endwhile
    return(rbuf)
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer data_bid        // buffer id for roman.txt data file
    integer saved_total     // accumulated character savings
    integer orig_ln         // length of original line
    integer min_ln          // length of minimised line
    integer num_v           // integer value of current Roman numeral
    string  cur_line[40]    // current Roman numeral string from file
    string  min_form[40]    // minimal Roman form of current line
    string  ans_str[20]     // final answer as string

    // Open the data file.  The file must be accessible to TSE; adjust the
    // path below if needed (or open it manually and replace "data_bid = 0"
    // with the appropriate EditFile() call).
    data_bid = EditFile("p089_roman.txt")
    if data_bid == 0
        Warn("euler089: Cannot open p089_roman.txt - please open it first.")
        return()
    endif

    GotoBufferId(data_bid)
    BegFile()

    saved_total = 0

    repeat
        cur_line = Trim(GetText(1, 40))
        if Length(cur_line) > 0
            orig_ln  = Length(cur_line)
            num_v    = roman_to_int(cur_line)
            min_form = int_to_roman(num_v)
            min_ln   = Length(min_form)
            saved_total = saved_total + (orig_ln - min_ln)
        endif
    until not Down()

    ans_str = Str(saved_total)

    // Show answer in a Warn() dialog
    Warn("Project Euler #89 answer: " + ans_str)

    // Copy ONLY the bare numeric answer to the clipboard
    CopyToWinClip(ans_str)
end
