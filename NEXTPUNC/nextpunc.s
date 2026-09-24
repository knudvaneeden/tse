/* NEXTPUNC 1.0.0.0.0 - GPT-6 - 2026-09-24 23:38 UTC
   Based on the supplied mNextPunc macro (2009-04-27).
*/

proc mNextPunc()                       // <Alt GreyCursorRight>
  START:
    Right()                            // begin at character to right
    case CurrChar()
      when 0x2e, 0x2c, 0x21, 0x3a, 0x3b, 0x3f // . , ! : ; ?
        goto DONE
      when _AT_EOL_, _BEYOND_EOL_
        Alarm()
        goto QUIT
      otherwise
        goto START
    endcase
  DONE:
    Right()
    case CurrChar()
      when 0x9, 0x20, 0x00            // tab, space, NUL
        goto DONE
      otherwise
        goto QUIT
    endcase
  QUIT:
end

proc Main()
  string silentS[16] = ""

  silentS = GetProfileStr("nextpunc", "silent", "false",
                          ExpandPath("nextpunc.ini"))
  if not EquiStr(silentS, "true")
    Warn("NEXTPUNC 1.0.0.0.0 (GPT-6): Move after the next . , ! : ; or ? " +
         "on this line. Use Alt+GreyCursorRight for subsequent jumps.")
  endif
  mNextPunc()
end

<Alt GreyCursorRight> mNextPunc()
