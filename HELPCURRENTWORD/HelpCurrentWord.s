/*
  Macro         HelpCurrentWord
  Author        Carlo.Hogeveen@xs4all.nl
  Compatibility TSE 4.0 upwards
  Date          29 jun 2017
  Version       1.0.1
  Version date  2 jul 2017

  Purpose
    When you double tap the F1 key when editing a TSE program,
    then TSE's Help is called for the word at the cursor,
    otherwise the F1 key works as usual.

  Installation
    Copy this file to TSE's "mac" folder, open it in TSE,
    and compile it with the Macro menu.
    Then add the macro to the Macro AutoLoad List (menu),
    preferrably at the bottom to avoid clashing with
    other macros that implement the F1 key.
    Restart TSE.

  History
    1.0     29 jun 2017
      Initial release.
    1.0.1   2 jul 2017
      Bug solved: it did't work for .ui files.

*/

integer current_word_help_enabled = TRUE

proc Main()
 integer next_key = 0
 if current_word_help_enabled
  if (CurrExt() in '.inc', '.s', '.si', '.ui')
   Delay(9)
   if KeyPressed()
    next_key = GetKey()
    if KeyName(next_key) == 'F1'
      Help(GetWord(TRUE))
    else
     current_word_help_enabled = FALSE
     PushKey(next_key)
     PushKey(<F1>)
    endif
   else
    ChainCmd()
   endif
  else
   ChainCmd()
  endif
 else
  current_word_help_enabled = TRUE
  ChainCmd()
 endif
end Main

<F1> Main()

