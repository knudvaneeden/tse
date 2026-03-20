// File: pe136_euler_singleton_difference.s
// Purpose: Solve Project Euler problem 136 (Singleton differences)
// Version: 3.2
// History:
//   1.0 - Created 2026-03-20 by Perplexity, powered by GPT-5.1
//   1.1 - String declaration fixed (answerStr[255] = "")
//   1.2 - Replaced integer arrays with buffer-based implementation
//   1.3 - Replaced MakeBuff() with CreateTempBuffer() + line-based storage
//   1.4 - EndProc replaced with End
//   1.5 - Added Main() proc to call PE136_SingletonDifference()
//   1.6 - Replaced hanging buffer pre-fill with direct math shortcut
//   1.7 - Replaced Int(Sqrt()) with direct Integer assignment of Sqrt()
//   1.8 - Replaced Sqrt() with integer-only isqrt via Newton loop
//   1.9 - Reverted to correct a(4b-a) enumeration; lazy buffer fill
//   2.0 - Chunked band approach (still too slow)
//   2.1 - Use DOS shell + Python one-liner to compute; read result file
//   2.2 - Fixed Python path; fixed double quote concatenation using '"'
//   2.3 - Write Python script to .py file via AddLine() to avoid 255-char limit
//   2.4 - Fixed missing Python indentation in AddLine() calls
//   2.5 - Rewrote Python script using inline indentation in string literals
//   2.6 - Delete result file before DOS() call; poll until it exists
//   2.7 - Use EditFile()+AbandonFile()+EraseDiskFile() to delete result file
//   2.8 - Erase both files before run; add Delay() after DOS()
//   2.9 - Use absolute path for result file in Python open() call
//   3.0 - Revert to simple relative resultFile everywhere; fix erase
//   3.1 - Fix Python indentation using GotoLine()+BegLine()+InsertText()
//   3.2 - Added GotoBufferId(bufPy) before indentation block to ensure
//         InsertText() operates inside correct buffer

Proc PE136_SingletonDifference()
  Integer bufPy
  Integer bufResult
  String  answerStr[255]  = ""
  String  pyExe[255]      = "g:\language\computer\python\python\python.exe"
  String  pyFile[255]     = "pe136.py"
  String  resultFile[255] = "pe136result.txt"
  String  pyCmd[255]      = ""
  String  i2[4]           = "  "
  String  i4[8]           = "    "

  // Erase old Python script file
  PushPosition()
  PushBlock()
  If EditFile(pyFile)
    AbandonFile()
  EndIf
  EraseDiskFile(pyFile)
  PopPosition()
  PopBlock()

  // Erase old result file
  PushPosition()
  PushBlock()
  If EditFile(resultFile)
    AbandonFile()
  EndIf
  EraseDiskFile(resultFile)
  PopPosition()
  PopBlock()

  // Write Python script line by line; no leading spaces yet
  bufPy = CreateTempBuffer()
  GotoBufferId(bufPy)
  BegFile()
  AddLine("import sys")                                                    // line 1
  AddLine("L = 50000000")                                                  // line 2
  AddLine("a1 = bytearray(L)")                                             // line 3
  AddLine("a2 = bytearray(L)")                                             // line 4
  AddLine("a = 1")                                                         // line 5
  AddLine("while a < L:")                                                  // line 6
  AddLine("lb = (a + 3) // 4")                                             // line 7  -> i2
  AddLine("b = lb")                                                        // line 8  -> i2
  AddLine("while b < a:")                                                  // line 9  -> i2
  AddLine("c = a * (4 * b - a)")                                           // line 10 -> i4
  AddLine("if c >= L: break")                                              // line 11 -> i4
  AddLine("if a1[c]: a2[c] = 1")                                           // line 12 -> i4
  AddLine("else: a1[c] = 1")                                               // line 13 -> i4
  AddLine("b += 1")                                                        // line 14 -> i4
  AddLine("a += 1")                                                        // line 15 -> i2
  AddLine("answer = sum(1 for i in range(1, L) if a1[i] and not a2[i])")  // line 16
  AddLine("open('pe136result.txt', 'w').write(str(answer))")               // line 17

  // Insert indentation - stay inside bufPy for all GotoLine() calls
  GotoBufferId(bufPy)
  GotoLine(7)
  BegLine()
  InsertText(i2, _INSERT_)
  GotoLine(8)
  BegLine()
  InsertText(i2, _INSERT_)
  GotoLine(9)
  BegLine()
  InsertText(i2, _INSERT_)
  GotoLine(10)
  BegLine()
  InsertText(i4, _INSERT_)
  GotoLine(11)
  BegLine()
  InsertText(i4, _INSERT_)
  GotoLine(12)
  BegLine()
  InsertText(i4, _INSERT_)
  GotoLine(13)
  BegLine()
  InsertText(i4, _INSERT_)
  GotoLine(14)
  BegLine()
  InsertText(i4, _INSERT_)
  GotoLine(15)
  BegLine()
  InsertText(i2, _INSERT_)

  // Save the buffer as the Python script file
  SaveAs(pyFile, _OVERWRITE_)
  AbandonFile(bufPy)

  // Run the Python script via DOS shell (blocks until Python finishes)
  pyCmd = pyExe + " " + pyFile
  DOS(pyCmd, _DONT_PROMPT_)

  // Read the result file into a temp buffer
  bufResult = CreateTempBuffer()
  InsertFile(resultFile)
  BegFile()
  answerStr = GetText(1, CurrLineLen())
  AbandonFile(bufResult)

  // Show answer and copy only the bare number to clipboard
  Warn("Project Euler 136 answer: ", answerStr)
  CopyToWinClip(answerStr)

  Return()
End

Proc Main()
  PE136_SingletonDifference()
  Return()
End

