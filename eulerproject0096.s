// euler096.s
// Version: 1.2
// Project Euler - Problem 96: Su Doku
// Solve all 50 Sudoku puzzles, sum the 3-digit numbers
// in the top-left corner of each solution grid.
//
// TSE SAL rules confirmed and applied:
//  1. No integer arrays:
//       9x9 grid stored in CreateTempBuffer() g_buf (81 lines, one digit per line)
//  2. No reserved/built-in names as variable names:
//       no val, pos, str, s, mark, Find, Insert, Delete, Length,
//       Copy, Line, Row, Col, Tab, Key, Word, etc. used as variables
//  3. All variable declarations immediately after the procedure header,
//     before any executable statements
//  4. 32-bit integers only (answer ~24702, well within 2,147,483,647)
//  5. No iterate/continue keywords: nested if/endif blocks skip iterations
//  6. break is the only loop exit keyword
//  7. Return() always with parentheses
//  8. Warn() box for final answer
//  9. CopyToWinClip() only the bare numeric answer string
// 10. No paste/insert of result into any editor buffer
// 11. String lengths <= 255 characters (all strings well under limit)
// 12. Version number included (see line 2)
// 13. No 'while 1' infinite loop construct used
// 14. Backtracking implemented as RECURSION (no iterative stack buffer needed)

// ---------------------------------------------------------------------------
// Globals
// ---------------------------------------------------------------------------
integer g_buf     // temp buffer holding the 81-cell grid (one digit per line)
integer g_solved  // set to 1 when a solution is found (stops recursion)

// ---------------------------------------------------------------------------
// SetCell(ci, dg)
//   ci : cell index 0..80  (row*9 + col)
//   dg : digit      0..9   (0 = empty)
// ---------------------------------------------------------------------------
proc SetCell(integer ci, integer dg)
    GotoBufferId(g_buf)
    GotoLine(ci + 1)
    BegLine()
    KillToEol()
    InsertText(Str(dg), _INSERT_)
end

// ---------------------------------------------------------------------------
// GetCell(ci) -> digit 0..9
// ---------------------------------------------------------------------------
integer proc GetCell(integer ci)
    integer dg
    GotoBufferId(g_buf)
    GotoLine(ci + 1)
    BegLine()
    dg = Val(GetText(1, 2))
    Return(dg)
end

// ---------------------------------------------------------------------------
// IsGroupUsed(startci, stepsize, cnt, dg) -> 1 if dg found in that group
// ---------------------------------------------------------------------------
integer proc IsGroupUsed(integer startci, integer stepsize, integer cnt, integer dg)
    integer kidx
    integer found
    found = 0
    kidx  = 0
    while kidx < cnt
        if found == 0
            if GetCell(startci + kidx * stepsize) == dg
                found = 1
            endif
        endif
        kidx = kidx + 1
    endwhile
    Return(found)
end

// ---------------------------------------------------------------------------
// IsRowUsed(rw, dg) -> 1 if dg in row rw (0-based)
// ---------------------------------------------------------------------------
integer proc IsRowUsed(integer rw, integer dg)
    Return(IsGroupUsed(rw * 9, 1, 9, dg))
end

// ---------------------------------------------------------------------------
// IsColUsed(cl, dg) -> 1 if dg in column cl (0-based)
// ---------------------------------------------------------------------------
integer proc IsColUsed(integer cl, integer dg)
    Return(IsGroupUsed(cl, 9, 9, dg))
end

// ---------------------------------------------------------------------------
// IsBoxUsed(rw, cl, dg) -> 1 if dg in 3x3 box containing (rw, cl)
//   Box top-left: br=(rw/3)*3, bc=(cl/3)*3
//   Three rows of 3 cells each are checked separately.
// ---------------------------------------------------------------------------
integer proc IsBoxUsed(integer rw, integer cl, integer dg)
    integer br
    integer bc
    integer bidx
    br   = (rw / 3) * 3
    bc   = (cl / 3) * 3
    bidx = br * 9 + bc
    if IsGroupUsed(bidx,      1, 3, dg)
        Return(1)
    endif
    if IsGroupUsed(bidx +  9, 1, 3, dg)
        Return(1)
    endif
    if IsGroupUsed(bidx + 18, 1, 3, dg)
        Return(1)
    endif
    Return(0)
end

// ---------------------------------------------------------------------------
// IsSafe(ci, dg) -> 1 if dg can legally be placed at cell ci
// ---------------------------------------------------------------------------
integer proc IsSafe(integer ci, integer dg)
    integer rw
    integer cl
    rw = ci / 9
    cl = ci mod 9
    if IsRowUsed(rw, dg)
        Return(0)
    endif
    if IsColUsed(cl, dg)
        Return(0)
    endif
    if IsBoxUsed(rw, cl, dg)
        Return(0)
    endif
    Return(1)
end

// ---------------------------------------------------------------------------
// SolveFrom(ci)
//   Recursive backtracking starting from cell index ci.
//   Sets g_solved = 1 when the puzzle is fully solved.
//   Stops early if g_solved is already 1 (solution found deeper in recursion).
// ---------------------------------------------------------------------------
proc SolveFrom(integer ci)
    integer nci
    integer dg
    // Skip forward to next empty cell
    nci = ci
    while nci < 81
        if g_solved == 0
            if GetCell(nci) == 0
                break
            endif
            nci = nci + 1
        else
            nci = 81  // already solved, exit scan
        endif
    endwhile

    if g_solved == 0
        if nci >= 81
            // No empty cell found -> puzzle complete
            g_solved = 1
        else
            // Try digits 1..9 at cell nci
            dg = 1
            while dg <= 9
                if g_solved == 0
                    if IsSafe(nci, dg)
                        SetCell(nci, dg)
                        SolveFrom(nci + 1)
                        if g_solved == 0
                            // Backtrack: remove the digit we just placed
                            SetCell(nci, 0)
                        endif
                    endif
                    dg = dg + 1
                else
                    dg = 10  // solution found, exit digit loop
                endif
            endwhile
        endif
    endif
end

// ---------------------------------------------------------------------------
// LoadPuzzle(pstr)
//   pstr: 81-char string of digits (0 = empty).
//   EmptyBuffer() leaves one blank line; overwrite it with cell 0,
//   then append lines for cells 1..80.
// ---------------------------------------------------------------------------
proc LoadPuzzle(string pstr)
    integer cidx
    GotoBufferId(g_buf)
    EmptyBuffer()
    BegFile()
    BegLine()
    KillToEol()
    InsertText(SubStr(pstr, 1, 1), _INSERT_)
    cidx = 1
    while cidx < 81
        EndFile()
        AddLine(SubStr(pstr, cidx + 1, 1))
        cidx = cidx + 1
    endwhile
end

// ---------------------------------------------------------------------------
// GetTopLeft() -> 3-digit integer from cells 0, 1, 2
// ---------------------------------------------------------------------------
integer proc GetTopLeft()
    integer tl
    tl = GetCell(0) * 100 + GetCell(1) * 10 + GetCell(2)
    Return(tl)
end

// ---------------------------------------------------------------------------
// Main()
// ---------------------------------------------------------------------------
proc Main()
    integer total_sum
    integer grid_num
    integer tl_num
    string  answer_str[12]

    // All 50 puzzles embedded (81 chars each, 0=empty)
    // Source: 0096_sudoku.txt from Project Euler problem 96
    string p01[81]
    string p02[81]
    string p03[81]
    string p04[81]
    string p05[81]
    string p06[81]
    string p07[81]
    string p08[81]
    string p09[81]
    string p10[81]
    string p11[81]
    string p12[81]
    string p13[81]
    string p14[81]
    string p15[81]
    string p16[81]
    string p17[81]
    string p18[81]
    string p19[81]
    string p20[81]
    string p21[81]
    string p22[81]
    string p23[81]
    string p24[81]
    string p25[81]
    string p26[81]
    string p27[81]
    string p28[81]
    string p29[81]
    string p30[81]
    string p31[81]
    string p32[81]
    string p33[81]
    string p34[81]
    string p35[81]
    string p36[81]
    string p37[81]
    string p38[81]
    string p39[81]
    string p40[81]
    string p41[81]
    string p42[81]
    string p43[81]
    string p44[81]
    string p45[81]
    string p46[81]
    string p47[81]
    string p48[81]
    string p49[81]
    string p50[81]

    p01 = "003020600900305001001806400008102900700000008006708200002609500800203009005010300"
    p02 = "200080300060070084030500209000105408000000000402706000301007040720040060004010003"
    p03 = "000000907000420180000705026100904000050000040000507009920108000034059000507000000"
    p04 = "030050040008010500460000012070502080000603000040109030250000098001020600080060020"
    p05 = "020810740700003100090002805009040087400208003160030200302700060005600008076051090"
    p06 = "100920000524010000000000070050008102000000000402700090060000000000030945000071006"
    p07 = "043080250600000000000001094900004070000608000010200003820500000000000005034090710"
    p08 = "480006902002008001900370060840010200003704100001060049020085007700900600609200018"
    p09 = "000900002050123400030000160908000000070000090000000205091000050007439020400007000"
    p10 = "001900003900700160030005007050000009004302600200000070600100030042007006500006800"
    p11 = "000125400008400000420800000030000095060902010510000060000003049000007200001298000"
    p12 = "062340750100005600570000040000094800400000006005830000030000091006400007059083260"
    p13 = "300000000005009000200504000020000700160000058704310600000890100000067080000005437"
    p14 = "630000000000500008005674000000020000003401020000000345000007004080300902947100080"
    p15 = "000020040008035000000070602031046970200000000000501203049000730000000010800004000"
    p16 = "361025900080960010400000057008000471000603000259000800740000005020018060005470329"
    p17 = "050807020600010090702540006070020301504000908103080070900076205060090003080103040"
    p18 = "080005000000003457000070809060400903007010500408007020901020000842300000000100080"
    p19 = "003502900000040000106000305900251008070408030800763001308000104000020000005104800"
    p20 = "000000000009805100051907420290401065000000000140508093026709580005103600000000000"
    p21 = "020030090000907000900208005004806500607000208003102900800605007000309000030020050"
    p22 = "005000006070009020000500107804150000000803000000092805907006000030400010200000600"
    p23 = "040000050001943600009000300600050002103000506800020007005000200002436700030000040"
    p24 = "004000000000030002390700080400009001209801307600200008010008053900040000000000800"
    p25 = "360020089000361000000000000803000602400603007607000108000000000000418000970030014"
    p26 = "500400060009000800640020000000001008208000501700500000000090084003000600060003002"
    p27 = "007256400400000005010030060000508000008060200000107000030070090200000004006312700"
    p28 = "000000000079050180800000007007306800450708096003502700700000005016030420000000000"
    p29 = "030000080009000500007509200700105008020090030900402001004207100002000800070000090"
    p30 = "200170603050000100000006079000040700000801000009050000310400000005000060906037002"
    p31 = "000000080800701040040020030374000900000030000005000321010060050050802006080000000"
    p32 = "000000085000210009960080100500800016000000000890006007009070052300054000480000000"
    p33 = "608070502050608070002000300500090006040302050800050003005000200010704090409060701"
    p34 = "050010040107000602000905000208030501040070020901080406000401000304000709020060010"
    p35 = "053000790009753400100000002090080010000907000080030070500000003007641200061000940"
    p36 = "006080300049070250000405000600317004007000800100826009000702000075040190003090600"
    p37 = "005080700700204005320000084060105040008000500070803010450000091600508007003010600"
    p38 = "000900800128006400070800060800430007500000009600079008090004010003600284001007000"
    p39 = "000080000270000054095000810009806400020403060006905100017000620460000038000090000"
    p40 = "000602000400050001085010620038206710000000000019407350026040530900020007000809000"
    p41 = "000900002050123400030000160908000000070000090000000205091000050007439020400007000"
    p42 = "380000000000400785009020300060090000800302009000040070001070500495006000000000092"
    p43 = "000158000002060800030000040027030510000000000046080790050000080004070100000325000"
    p44 = "010500200900001000002008030500030007008000500600080004040100700000700006003004050"
    p45 = "080000040000469000400000007005904600070608030008502100900000005000781000060000010"
    p46 = "904200007010000000000706500000800090020904060040002000001607000000000030300005702"
    p47 = "000700800006000031040002000024070000010030080000060290000800070860000500002006000"
    p48 = "001007090590080001030000080000005800050060020004100000080000030100020079020700400"
    p49 = "000003017015009008060000000100007000009000200000500004000000020500600340340200000"
    p50 = "300200000000107000706030500070009080900020004010800050009040301000702000000008006"

    g_buf     = CreateTempBuffer()
    total_sum = 0
    grid_num  = 1

    while grid_num <= 50
        if grid_num == 1
            LoadPuzzle(p01)
        elseif grid_num == 2
            LoadPuzzle(p02)
        elseif grid_num == 3
            LoadPuzzle(p03)
        elseif grid_num == 4
            LoadPuzzle(p04)
        elseif grid_num == 5
            LoadPuzzle(p05)
        elseif grid_num == 6
            LoadPuzzle(p06)
        elseif grid_num == 7
            LoadPuzzle(p07)
        elseif grid_num == 8
            LoadPuzzle(p08)
        elseif grid_num == 9
            LoadPuzzle(p09)
        elseif grid_num == 10
            LoadPuzzle(p10)
        elseif grid_num == 11
            LoadPuzzle(p11)
        elseif grid_num == 12
            LoadPuzzle(p12)
        elseif grid_num == 13
            LoadPuzzle(p13)
        elseif grid_num == 14
            LoadPuzzle(p14)
        elseif grid_num == 15
            LoadPuzzle(p15)
        elseif grid_num == 16
            LoadPuzzle(p16)
        elseif grid_num == 17
            LoadPuzzle(p17)
        elseif grid_num == 18
            LoadPuzzle(p18)
        elseif grid_num == 19
            LoadPuzzle(p19)
        elseif grid_num == 20
            LoadPuzzle(p20)
        elseif grid_num == 21
            LoadPuzzle(p21)
        elseif grid_num == 22
            LoadPuzzle(p22)
        elseif grid_num == 23
            LoadPuzzle(p23)
        elseif grid_num == 24
            LoadPuzzle(p24)
        elseif grid_num == 25
            LoadPuzzle(p25)
        elseif grid_num == 26
            LoadPuzzle(p26)
        elseif grid_num == 27
            LoadPuzzle(p27)
        elseif grid_num == 28
            LoadPuzzle(p28)
        elseif grid_num == 29
            LoadPuzzle(p29)
        elseif grid_num == 30
            LoadPuzzle(p30)
        elseif grid_num == 31
            LoadPuzzle(p31)
        elseif grid_num == 32
            LoadPuzzle(p32)
        elseif grid_num == 33
            LoadPuzzle(p33)
        elseif grid_num == 34
            LoadPuzzle(p34)
        elseif grid_num == 35
            LoadPuzzle(p35)
        elseif grid_num == 36
            LoadPuzzle(p36)
        elseif grid_num == 37
            LoadPuzzle(p37)
        elseif grid_num == 38
            LoadPuzzle(p38)
        elseif grid_num == 39
            LoadPuzzle(p39)
        elseif grid_num == 40
            LoadPuzzle(p40)
        elseif grid_num == 41
            LoadPuzzle(p41)
        elseif grid_num == 42
            LoadPuzzle(p42)
        elseif grid_num == 43
            LoadPuzzle(p43)
        elseif grid_num == 44
            LoadPuzzle(p44)
        elseif grid_num == 45
            LoadPuzzle(p45)
        elseif grid_num == 46
            LoadPuzzle(p46)
        elseif grid_num == 47
            LoadPuzzle(p47)
        elseif grid_num == 48
            LoadPuzzle(p48)
        elseif grid_num == 49
            LoadPuzzle(p49)
        elseif grid_num == 50
            LoadPuzzle(p50)
        endif

        // Reset solved flag and run recursive solver from cell 0
        g_solved = 0
        SolveFrom(0)

        tl_num    = GetTopLeft()
        total_sum = total_sum + tl_num

        grid_num = grid_num + 1
    endwhile

    AbandonFile(g_buf)

    answer_str = Str(total_sum)

    // Show in Warn() box
    Warn("Project Euler #96 answer: " + answer_str)

    // Clipboard: ONLY the bare number, nothing else
    CopyToWinClip(answer_str)
end
