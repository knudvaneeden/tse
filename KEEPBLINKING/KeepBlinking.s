/*
  Macro         KeepBlinking
  Author        Carlo.Hogeveen@xs4all.nl
  Compatibility TSE Pro v4.0 upwards
  Version       v1.0 - 14 Jun 2019

  If you do not type for some seconds, then the cursor stops blinking.

  This happened since switching to some past version of Windows.
  This behaviour is also observable in NotePad, Wordpad, (after more blinks)
  Word, and UltraEdit (v20, not up-to-date). Some other editors dot not have
  this problem.

  This macro is a work-around to keep the cursor blinking in TSE too.

  Thanks to Stein Oiestad who came up with its solution!
  Any errors in its implementation are mine.


  INSTALLATION

  Copy this source file to TSE's "mac" folder.
  Compile the file as a TSE macro, for instance by opening it in TSE and
  invoking the menu Macro -> Compile.
  Lastly add the macro's name KeepBlinking in the menu Macro -> AutoLoad List,
  and restart TSE.


  HISTORY
  v1.0 - 14 Jun 2019
    Initial release.

*/

integer c = 0

proc idle()
  if c > 18
    if Query(Cursor)
      Set(Cursor, OFF)
      Set(Cursor, ON)
    endif
    c = 0
  else
    c = c + 1
  endif
end idle

proc WhenLoaded()
  Hook(_IDLE_, idle)
end WhenLoaded

