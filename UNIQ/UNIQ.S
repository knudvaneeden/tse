/*************************************
A macro that removes duplicate lines.
Sort first for a complete clean-up.
June 6, 1996, Sjoerd W. Rienstra
in cooperation with Chris Antos.
**************************************/

proc main()
 integer  L0, L1
 string s0[255]

 PushPosition()
 Begfile()
 L1 = CurrLineLen()
 while Down()
  L0 = L1                          // remember previous line length.
  L1 = CurrLineLen()
  if L1 == L0                      // if line lengths are the same.
    if L1                          // if line is non-empty.
      L0 = L0 - ((L0-1) mod 255)   // work backwards, since lines are sorted.
      while L0 > 0
        Up()
        s0 = GetText(L0, 255)
        Down()
        if s0 <> GetText(L0, 255)  // stop comparing if different
          break
        endif
        L0 = L0 - 255              // largest possible step is 255
      endwhile
    endif
    if not L1 or L0 < 0            // L0 = -254, 1, 256, 511, ...
//    if L0 < 0                    // if blank lines must not be removed
      KillLine()
      Up()
    endif
  endif
 endwhile
 PopPosition()
end
