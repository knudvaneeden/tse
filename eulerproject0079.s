// euler079.s
// Version: 1.1
// Project Euler - Problem 79: Passcode Derivation
// https://projecteuler.net/problem=79
//
// The 50 keylog entries are hardcoded below.
// Algorithm: topological sort (Kahn's algorithm) on the 8 unique digits.
//
// TSE SAL constraints observed:
//   - No integer arrays  -> temp buffers (one integer per line)
//   - No reserved / built-in names as variable names
//   - All string lengths within 255 chars
//   - 32-bit integers only
//   - Warn() to show answer; CopyToWinClip() only the bare answer string
//   - Result NOT pasted into the .s program buffer
//
// Key TSE SAL buffer rules applied:
//   - CreateTempBuffer() creates a buffer with 1 blank line already present
//   - So the FIRST AddLine() goes to line 2; to have data on line 1 we must
//     overwrite line 1 first, then AddLine() for lines 2 onward
//   - KillLine() removes the line AND its newline, shrinking the buffer;
//     use DelToEol() instead to clear only the line content in place

// -----------------------------------------------------------------------
// Digit index mapping: 0->0, 1->1, 2->2, 3->3, 4->6, 5->7, 6->8, 7->9
// -----------------------------------------------------------------------

integer gbuf_indeg    // buffer id: in_degree[0..7]  (lines 1-8)
integer gbuf_succ     // buffer id: succ matrix 8x8  (lines 1-64)
integer gbuf_keylog   // buffer id: keylog entries   (lines 1-50)

// -----------------------------------------------------------------------
// Map ASCII digit character to internal index 0-7
// -----------------------------------------------------------------------
integer proc DigitToIdx(integer dchar)
    if dchar == Asc("0")  return(0)  endif
    if dchar == Asc("1")  return(1)  endif
    if dchar == Asc("2")  return(2)  endif
    if dchar == Asc("3")  return(3)  endif
    if dchar == Asc("6")  return(4)  endif
    if dchar == Asc("7")  return(5)  endif
    if dchar == Asc("8")  return(6)  endif
    if dchar == Asc("9")  return(7)  endif
    return(-1)
end

// -----------------------------------------------------------------------
// Map internal index 0-7 to ASCII digit character
// -----------------------------------------------------------------------
integer proc IdxToDigitChar(integer idx)
    string lut[10] = "01236789"
    return( Asc( lut[idx+1..idx+1] ) )
end

// -----------------------------------------------------------------------
// Write a value to a specific line in a buffer.
// Uses DelToEol() to clear content in place (does NOT shrink buffer).
// Caller must already be in the target buffer.
// -----------------------------------------------------------------------
proc WriteLineVal(integer line_nr, integer num)
    GotoLine(line_nr)
    BegLine()
    DelToEol()
    InsertText( Str(num), _INSERT_ )
end

// -----------------------------------------------------------------------
// Read integer from a specific line in a buffer.
// Caller must already be in the target buffer.
// -----------------------------------------------------------------------
integer proc ReadLineVal(integer line_nr)
    string txt[20]
    GotoLine(line_nr)
    txt = GetText(1, 20)
    return( Val(Trim(txt)) )
end

// -----------------------------------------------------------------------
// Get in_degree for index idx
// -----------------------------------------------------------------------
integer proc GetInDeg(integer idx)
    integer prev_id
    integer result_val
    prev_id    = GotoBufferId(gbuf_indeg)
    result_val = ReadLineVal(idx + 1)
    GotoBufferId(prev_id)
    return(result_val)
end

// -----------------------------------------------------------------------
// Set in_degree for index idx
// -----------------------------------------------------------------------
proc SetInDeg(integer idx, integer num)
    integer prev_id
    prev_id = GotoBufferId(gbuf_indeg)
    WriteLineVal(idx + 1, num)
    GotoBufferId(prev_id)
end

// -----------------------------------------------------------------------
// Get succ[row][col]
// -----------------------------------------------------------------------
integer proc GetSucc(integer row, integer col)
    integer prev_id
    integer result_val
    prev_id    = GotoBufferId(gbuf_succ)
    result_val = ReadLineVal(row * 8 + col + 1)
    GotoBufferId(prev_id)
    return(result_val)
end

// -----------------------------------------------------------------------
// Set succ[row][col]
// -----------------------------------------------------------------------
proc SetSucc(integer row, integer col, integer num)
    integer prev_id
    prev_id = GotoBufferId(gbuf_succ)
    WriteLineVal(row * 8 + col + 1, num)
    GotoBufferId(prev_id)
end

// -----------------------------------------------------------------------
// Get keylog entry at line line_nr (1-based)
// -----------------------------------------------------------------------
string proc GetKeylog(integer line_nr)
    integer prev_id
    string  txt[10]
    prev_id = GotoBufferId(gbuf_keylog)
    GotoLine(line_nr)
    txt = GetText(1, 10)
    GotoBufferId(prev_id)
    return( Trim(txt) )
end

// -----------------------------------------------------------------------
// Fill a buffer with n_lines lines each containing the value init_val.
// CreateTempBuffer() already has 1 blank line, so:
//   - Overwrite line 1 first
//   - Then AddLine() for lines 2..n_lines
// Caller must already be in the target buffer.
// -----------------------------------------------------------------------
proc FillBuffer(integer n_lines, integer init_val)
    integer k
    string  sv[20]
    sv = Str(init_val)
    // Overwrite the existing blank line 1
    GotoLine(1)
    BegLine()
    DelToEol()
    InsertText(sv, _INSERT_)
    // Add remaining lines
    k = 2
    while k <= n_lines
        AddLine(sv)
        k = k + 1
    endwhile
end

// -----------------------------------------------------------------------
// Load all 50 keylog entries into gbuf_keylog
// -----------------------------------------------------------------------
proc LoadKeylog()
    integer prev_id
    prev_id = GotoBufferId(gbuf_keylog)
    // Overwrite existing blank line 1 with first entry
    GotoLine(1)
    BegLine()
    DelToEol()
    InsertText("319", _INSERT_)
    // Lines 2-50
    AddLine("680")
    AddLine("180")
    AddLine("690")
    AddLine("129")
    AddLine("620")
    AddLine("762")
    AddLine("689")
    AddLine("762")
    AddLine("318")
    AddLine("368")
    AddLine("710")
    AddLine("720")
    AddLine("710")
    AddLine("629")
    AddLine("168")
    AddLine("160")
    AddLine("689")
    AddLine("716")
    AddLine("731")
    AddLine("736")
    AddLine("729")
    AddLine("316")
    AddLine("729")
    AddLine("729")
    AddLine("710")
    AddLine("769")
    AddLine("290")
    AddLine("719")
    AddLine("680")
    AddLine("318")
    AddLine("389")
    AddLine("162")
    AddLine("289")
    AddLine("162")
    AddLine("718")
    AddLine("729")
    AddLine("319")
    AddLine("790")
    AddLine("680")
    AddLine("890")
    AddLine("362")
    AddLine("319")
    AddLine("760")
    AddLine("316")
    AddLine("729")
    AddLine("380")
    AddLine("319")
    AddLine("728")
    AddLine("716")
    GotoBufferId(prev_id)
end

// -----------------------------------------------------------------------
// Build precedence graph from 50 keylog entries.
// For each triplet ABC add edges: A->B, B->C, A->C
// (each edge recorded only once; in_degree incremented per new edge)
// -----------------------------------------------------------------------
proc BuildGraph()
    integer entry_nr
    string  entry[10]
    integer ia, ib, ic
    entry_nr = 1
    while entry_nr <= 50
        entry = GetKeylog(entry_nr)
        ia = DigitToIdx( Asc( entry[1..1] ) )
        ib = DigitToIdx( Asc( entry[2..2] ) )
        ic = DigitToIdx( Asc( entry[3..3] ) )
        if GetSucc(ia, ib) == 0
            SetSucc(ia, ib, 1)
            SetInDeg(ib, GetInDeg(ib) + 1)
        endif
        if GetSucc(ib, ic) == 0
            SetSucc(ib, ic, 1)
            SetInDeg(ic, GetInDeg(ic) + 1)
        endif
        if GetSucc(ia, ic) == 0
            SetSucc(ia, ic, 1)
            SetInDeg(ic, GetInDeg(ic) + 1)
        endif
        entry_nr = entry_nr + 1
    endwhile
end

// -----------------------------------------------------------------------
// Kahn topological sort over 8 nodes.
// Picks smallest-index node with in_degree == 0 each round.
// Returns the passcode digit string, or "ERROR" on failure.
// -----------------------------------------------------------------------
string proc TopoSort()
    string  result[20]
    integer round_nr
    integer cidx
    integer sidx
    integer found_node
    integer dchar
    result     = ""
    round_nr   = 1
    while round_nr <= 8
        found_node = -1
        cidx = 0
        while cidx <= 7
            if GetInDeg(cidx) == 0
                found_node = cidx
                cidx = 8
            endif
            cidx = cidx + 1
        endwhile
        if found_node < 0
            return("ERROR")
        endif
        dchar  = IdxToDigitChar(found_node)
        result = result + Chr(dchar)
        // Mark node as done: in_degree = -1
        SetInDeg(found_node, -1)
        // Decrement in_degree of successors
        sidx = 0
        while sidx <= 7
            if GetSucc(found_node, sidx) == 1
                SetInDeg(sidx, GetInDeg(sidx) - 1)
            endif
            sidx = sidx + 1
        endwhile
        round_nr = round_nr + 1
    endwhile
    return(result)
end

// -----------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------
proc Main()
    string passcode[20]

    // Create fresh temp buffers (each starts with 1 blank line)
    gbuf_indeg  = CreateTempBuffer()
    gbuf_succ   = CreateTempBuffer()
    gbuf_keylog = CreateTempBuffer()

    // Initialise in_degree buffer: 8 lines of "0"
    GotoBufferId(gbuf_indeg)
    FillBuffer(8, 0)

    // Initialise succ matrix buffer: 64 lines of "0"
    GotoBufferId(gbuf_succ)
    FillBuffer(64, 0)

    // Load keylog entries
    LoadKeylog()

    // Build the precedence graph
    BuildGraph()

    // Topological sort -> passcode
    passcode = TopoSort()

    // Copy ONLY the answer to clipboard
    CopyToWinClip(passcode)

    // Show result
    Warn("Project Euler #79 answer: " + passcode)

    // Release temp buffers
    AbandonFile(gbuf_indeg)
    AbandonFile(gbuf_succ)
    AbandonFile(gbuf_keylog)
end
