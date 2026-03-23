// File: p177.s
// Purpose: Solve Project Euler problem 177
//          "Integer Angled Quadrilaterals"
//          How many non-similar convex quadrilaterals have all
//          eight corner angles (made by each diagonal with each
//          adjacent side) equal to integer numbers of degrees?
//
// Math:
//   Label the diagonals intersection angle phi = angle(APB).
//   The 8 corner angles are:
//     a=BAC, b=ABD, c=DBC, d=BCA, e=DCA, f=CDB, g=ADB, h=CAD
//   From the 4 triangles at P:
//     a+b=180-phi,  c+d=phi,  e+f=180-phi,  g+h=phi
//   Geometrically realisable iff the sine closure holds:
//     sin(a)sin(c)sin(e)sin(g) = sin(b)sin(d)sin(f)sin(h)
//   Equivalently: |logsin(a)+logsin(c)+logsin(e)+logsin(g)
//                  -logsin(b)-logsin(d)-logsin(f)-logsin(h)| < 1e-9
//   Non-similar: count only the lex-min of the 8 D4-symmetry
//   equivalents of tuple (a,h,b,c,d,e,f,g).
//
//   Loop: phi in [2,178]; amax=min((180-phi)//2,phi//2);
//         a in [1,amax]; c,g in [a,phi-a]; e in [a,180-phi-a]
//
//   Correct answer: 129325
//
// Strategy:
//   1. Erase old p177.py and p177result.txt if present
//   2. Build pure-Python solver line by line with AddLine()
//   3. Add Python indentation via GotoLine()+BegLine()+InsertText()
//   4. SaveAs p177.py, run via DOS(), read p177result.txt
//   5. Show result in Warn() box; copy bare answer to clipboard
//
// Python runtime: ~3-5 minutes
//
// <version>1.0.0.0.1</version>
// LLM: Claude Sonnet 4.6 (Anthropic)
//
// History:
//   1.0.0.0.1  2026-03-23  Initial version by Claude Sonnet 4.6 (Anthropic)
//              Pattern from eulerproject0154.s

Proc Main()
    Integer bufPy
    Integer bufResult
    String  answerStr[255] = ""
    String  pyExe[255]     = "g:\language\computer\python\python\python.exe"
    String  pyFile[255]    = "p177.py"
    String  resultFile[255]= "p177result.txt"
    String  pyCmd[255]     = ""
    String  i1[8]          = "    "
    String  i2[16]         = "        "
    String  i3[16]         = "            "
    String  i4[20]         = "                "
    String  i5[24]         = "                    "
    String  i6[28]         = "                        "

    // --- Erase old Python script file ---
    PushPosition()
    PushBlock()
    If EditFile(pyFile)
        AbandonFile()
    EndIf
    EraseDiskFile(pyFile)
    PopPosition()
    PopBlock()

    // --- Erase old result file ---
    PushPosition()
    PushBlock()
    If EditFile(resultFile)
        AbandonFile()
    EndIf
    EraseDiskFile(resultFile)
    PopPosition()
    PopBlock()

    // -------------------------------------------------------
    // Build the Python script line by line.
    // Line numbers noted in comments; GotoLine() uses them
    // in the indentation block below.
    // No leading spaces in AddLine() -- added by InsertText().
    // -------------------------------------------------------
    bufPy = CreateTempBuffer()
    GotoBufferId(bufPy)
    BegFile()

    AddLine("import math")                                            // line 1
    AddLine("import sys")                                             // line 2
    AddLine("")                                                       // line 3
    AddLine("def is_canonical(a, h, b, c, d, e, f, g):")             // line 4
    AddLine("t0 = (a, h, b, c, d, e, f, g)")                         // line 5   -> i1
    AddLine("for t in [")                                             // line 6   -> i1
    AddLine("(c, b, d, e, f, g, h, a),")                             // line 7   -> i2
    AddLine("(e, d, f, g, h, a, b, c),")                             // line 8   -> i2
    AddLine("(g, f, h, a, b, c, d, e),")                             // line 9   -> i2
    AddLine("(h, a, g, f, e, d, c, b),")                             // line 10  -> i2
    AddLine("(f, g, e, d, c, b, a, h),")                             // line 11  -> i2
    AddLine("(d, e, c, b, a, h, g, f),")                             // line 12  -> i2
    AddLine("(b, c, a, h, g, f, e, d)")                              // line 13  -> i2
    AddLine("]:")                                                     // line 14  -> i1
    AddLine("if t < t0:")                                             // line 15  -> i2
    AddLine("return False")                                           // line 16  -> i3
    AddLine("return True")                                            // line 17  -> i1
    AddLine("")                                                       // line 18
    AddLine("ls = [math.log(math.sin(math.radians(i))) for i in range(1, 180)]") // line 19
    AddLine("TOL = 1e-9")                                             // line 20
    AddLine("count = 0")                                              // line 21
    AddLine("for phi in range(2, 179):")                              // line 22
    AddLine("amax = min((180 - phi) // 2, phi // 2)")                // line 23  -> i1
    AddLine("for a in range(1, amax + 1):")                          // line 24  -> i1
    AddLine("b = 180 - phi - a")                                     // line 25  -> i2
    AddLine("va = ls[a-1]")                                          // line 26  -> i2
    AddLine("vb = ls[b-1]")                                          // line 27  -> i2
    AddLine("for c in range(a, phi - a + 1):")                       // line 28  -> i2
    AddLine("d = phi - c")                                           // line 29  -> i3
    AddLine("vc = ls[c-1]")                                          // line 30  -> i3
    AddLine("vd = ls[d-1]")                                          // line 31  -> i3
    AddLine("for e in range(a, b + 1):")                             // line 32  -> i3
    AddLine("f = 180 - phi - e")                                     // line 33  -> i4
    AddLine("ve = ls[e-1]")                                          // line 34  -> i4
    AddLine("vf = ls[f-1]")                                          // line 35  -> i4
    AddLine("part = va + vc + ve - vb - vd - vf")                   // line 36  -> i4
    AddLine("for g in range(a, phi - a + 1):")                       // line 37  -> i4
    AddLine("hh = phi - g")                                          // line 38  -> i5
    AddLine("diff = abs(part + ls[g-1] - ls[hh-1])")                // line 39  -> i5
    AddLine("if diff >= TOL:")                                       // line 40  -> i5
    AddLine("continue")                                              // line 41  -> i6
    AddLine("if is_canonical(a, hh, b, c, d, e, f, g):")            // line 42  -> i5
    AddLine("count += 1")                                            // line 43  -> i6
    AddLine("open('p177result.txt','w').write(str(count))")          // line 44

    // -------------------------------------------------------
    // Insert Python indentation.
    // -------------------------------------------------------
    GotoBufferId(bufPy)

    GotoLine( 5)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine( 6)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine( 7)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine( 8)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine( 9)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(10)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(11)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(12)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(13)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(14)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(15)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(16)  BegLine()  InsertText(i3, _INSERT_)
    GotoLine(17)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(23)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(24)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(25)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(26)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(27)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(28)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(29)  BegLine()  InsertText(i3, _INSERT_)
    GotoLine(30)  BegLine()  InsertText(i3, _INSERT_)
    GotoLine(31)  BegLine()  InsertText(i3, _INSERT_)
    GotoLine(32)  BegLine()  InsertText(i3, _INSERT_)
    GotoLine(33)  BegLine()  InsertText(i4, _INSERT_)
    GotoLine(34)  BegLine()  InsertText(i4, _INSERT_)
    GotoLine(35)  BegLine()  InsertText(i4, _INSERT_)
    GotoLine(36)  BegLine()  InsertText(i4, _INSERT_)
    GotoLine(37)  BegLine()  InsertText(i4, _INSERT_)
    GotoLine(38)  BegLine()  InsertText(i5, _INSERT_)
    GotoLine(39)  BegLine()  InsertText(i5, _INSERT_)
    GotoLine(40)  BegLine()  InsertText(i5, _INSERT_)
    GotoLine(41)  BegLine()  InsertText(i6, _INSERT_)
    GotoLine(42)  BegLine()  InsertText(i5, _INSERT_)
    GotoLine(43)  BegLine()  InsertText(i6, _INSERT_)

    // --- Save Python script to disk ---
    SaveAs(pyFile, _OVERWRITE_)
    AbandonFile(bufPy)

    // --- Run Python (blocks until done; ~3-5 minutes) ---
    pyCmd = pyExe + " " + pyFile
    DOS(pyCmd, _DONT_PROMPT_)

    // --- Read result from file written by Python ---
    bufResult = CreateTempBuffer()
    InsertFile(resultFile)
    BegFile()
    answerStr = GetText(1, CurrLineLen())
    AbandonFile(bufResult)

    // --- Show answer in Warn box (take screenshot here) ---
    CopyToWinClip(answerStr)

    Warn("Project Euler 177 - Integer Angled Quadrilaterals" + Chr(13) +
         "Answer: ", answerStr)

    // --- Copy only the bare number to clipboard ---
    CopyToWinClip(answerStr)

    Return()
End
