// euler102.s
// Version: 1.0
// Project Euler - Problem 102: Triangle Containment
//
// Three distinct points are plotted at random on a Cartesian plane,
// for which -1000 <= x, y <= 1000, such that a triangle is formed.
// Using triangles.txt, a 27K text file containing the co-ordinates of
// one thousand "random" triangles, find the number of triangles for
// which the interior contains the origin.
//
// Algorithm: cross-product sign test.
// For triangle A(ax,ay), B(bx,by), C(cx,cy) and origin O(0,0):
//   z1 = ax*by - ay*bx
//   z2 = bx*cy - by*cx
//   z3 = cx*ay - cy*ax
// Origin is inside iff all three z values have the same sign
// (all positive or all negative).
//
// All intermediate values: max |ax*by| = 1000*1000 = 1,000,000
// Well within 32-bit signed integer range (~2,147,483,647). Safe.
//
// TSE SAL rules applied:
//   [1] No integer arrays  -- only scalar INTEGER variables used
//   [2] No reserved/built-in names as variable names
//       (no val, pos, str, s, mark, old, len, etc.)
//   [3] String lengths declared <=255 chars; no silent truncation
//   [4] 32-bit integers only -- verified above (max 1,000,000)
//   [5] Return() always with parentheses
//   [6] Warn() box to display the final answer
//   [7] CopyToWinClip() copies ONLY the bare numeric answer
//   [8] No AddLine/InsertText/Paste of the result into any buffer
//   [9] Version number present at top of file
//  [10] val and pos NOT used as variable names

// ---------------------------------------------------------------------------
// Helper: parse a signed integer from string sln starting at index sidx.
// Advances sidx past the parsed token (stops at comma or end of string).
// Result is returned via the global gnum.
// ---------------------------------------------------------------------------
INTEGER gnum        // parsed number result (global to avoid extra params)
INTEGER gsign       // sign accumulator for ParseInt

PROC ParseInt(STRING sln, INTEGER sidx)
    INTEGER slen
    INTEGER ch
    INTEGER digit

    gsign = 1
    gnum  = 0
    slen  = Length(sln)

    // skip leading whitespace
    WHILE sidx <= slen
        ch = Asc(sln[sidx])
        IF ch == 32
            sidx = sidx + 1
        ELSE
            BREAK
        ENDIF
    ENDWHILE

    // optional minus sign
    IF sidx <= slen
        ch = Asc(sln[sidx])
        IF ch == 45      // ASCII '-'
            gsign = -1
            sidx  = sidx + 1
        ELSEIF ch == 43  // ASCII '+'
            sidx  = sidx + 1
        ENDIF
    ENDIF

    // digits
    WHILE sidx <= slen
        ch = Asc(sln[sidx])
        IF ch >= 48 AND ch <= 57   // '0'..'9'
            digit = ch - 48
            gnum  = gnum * 10 + digit
            sidx  = sidx + 1
        ELSE
            BREAK
        ENDIF
    ENDWHILE

    gnum = gnum * gsign
END

// ---------------------------------------------------------------------------
// Helper: find the position of the next comma in sln starting at sidx.
// Returns the position, or Length(sln)+1 if none found.
// ---------------------------------------------------------------------------
INTEGER gcommapos   // result position of next comma

PROC FindComma(STRING sln, INTEGER sidx)
    INTEGER slen
    INTEGER ch

    slen = Length(sln)
    gcommapos = slen + 1
    WHILE sidx <= slen
        ch = Asc(sln[sidx])
        IF ch == 44    // ASCII ','
            gcommapos = sidx
            RETURN()
        ENDIF
        sidx = sidx + 1
    ENDWHILE
END

// ---------------------------------------------------------------------------
// Main macro
// ---------------------------------------------------------------------------
PROC Main()
    // Buffer handles
    INTEGER data_buf        // buffer holding triangles.txt
    INTEGER orig_buf        // original buffer to return to

    // Per-line parsing
    STRING  cur_line[128]   // one CSV line from the file
    INTEGER cur_idx         // current parse index within cur_line
    INTEGER total_lines     // number of lines in the file

    // Parsed triangle coordinates (six integers per triangle)
    INTEGER tax             // vertex A x-coordinate
    INTEGER tay             // vertex A y-coordinate
    INTEGER tbx             // vertex B x-coordinate
    INTEGER tby             // vertex B y-coordinate
    INTEGER tcx             // vertex C x-coordinate
    INTEGER tcy             // vertex C y-coordinate

    // Cross-product values (sign test)
    INTEGER zz1             // ax*by - ay*bx
    INTEGER zz2             // bx*cy - by*cx
    INTEGER zz3             // cx*ay - cy*ax

    // Counters
    INTEGER tri_count       // number of triangles containing the origin
    INTEGER line_num        // current line number being processed

    // Answer string
    STRING  ans_str[32]     // Str() of tri_count

    // -------------------------------------------------------------------
    // Remember the current buffer so we can return to it
    // -------------------------------------------------------------------
    orig_buf = GetBufferId()

    // -------------------------------------------------------------------
    // Load triangles.txt into a TSE buffer
    // -------------------------------------------------------------------
    data_buf = EditFile("p102_triangles.txt")
    IF data_buf == 0
        Warn("euler102: Could not open p102_triangles.txt")
        RETURN()
    ENDIF
    GotoBufferId(data_buf)

    total_lines = NumLines()
    tri_count   = 0
    line_num    = 1

    // -------------------------------------------------------------------
    // Process each line
    // -------------------------------------------------------------------
    BegFile()
    WHILE line_num <= total_lines
        cur_line = GetText(1, 127)

        // Parse 6 comma-separated integers: ax,ay,bx,by,cx,cy
        cur_idx = 1

        // --- ax ---
        FindComma(cur_line, cur_idx)
        ParseInt(cur_line, cur_idx)
        tax     = gnum
        cur_idx = gcommapos + 1

        // --- ay ---
        FindComma(cur_line, cur_idx)
        ParseInt(cur_line, cur_idx)
        tay     = gnum
        cur_idx = gcommapos + 1

        // --- bx ---
        FindComma(cur_line, cur_idx)
        ParseInt(cur_line, cur_idx)
        tbx     = gnum
        cur_idx = gcommapos + 1

        // --- by ---
        FindComma(cur_line, cur_idx)
        ParseInt(cur_line, cur_idx)
        tby     = gnum
        cur_idx = gcommapos + 1

        // --- cx ---
        FindComma(cur_line, cur_idx)
        ParseInt(cur_line, cur_idx)
        tcx     = gnum
        cur_idx = gcommapos + 1

        // --- cy  (no trailing comma, parse to end of string) ---
        ParseInt(cur_line, cur_idx)
        tcy = gnum

        // -----------------------------------------------------------
        // Cross-product sign test
        //   zz1 = ax*by - ay*bx
        //   zz2 = bx*cy - by*cx
        //   zz3 = cx*ay - cy*ax
        // Origin is inside iff all three have the same sign.
        // -----------------------------------------------------------
        zz1 = tax * tby - tay * tbx
        zz2 = tbx * tcy - tby * tcx
        zz3 = tcx * tay - tcy * tax

        IF  (zz1 > 0 AND zz2 > 0 AND zz3 > 0)
        OR  (zz1 < 0 AND zz2 < 0 AND zz3 < 0)
            tri_count = tri_count + 1
        ENDIF

        // advance to next line
        IF line_num < total_lines
            Down()
        ENDIF
        line_num = line_num + 1
    ENDWHILE

    // -------------------------------------------------------------------
    // Close the data buffer and restore original buffer
    // -------------------------------------------------------------------
    AbandonFile(data_buf)
    GotoBufferId(orig_buf)

    // -------------------------------------------------------------------
    // Report result
    // [6]  Warn() box shows the final answer
    // [7]  CopyToWinClip() copies ONLY the bare integer (ans_str)
    // [8]  No AddLine / InsertText of result into any buffer
    // -------------------------------------------------------------------
    ans_str = Str(tri_count)
    CopyToWinClip(ans_str)
    Warn("Project Euler #102 answer: " + ans_str)
END
