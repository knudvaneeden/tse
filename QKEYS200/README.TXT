
                                QKEYS.S v2.00
                                 ÄÄÄÄÄÄÄÄÄÄÄ
  Description
  ÄÄÄÄÄÄÄÄÄÄÄ
  This macro accelerates the rate of cursor movement and hence scroll speed.
  Essentially, the macro detects when the Cursor navigation keys are being
  pressed and repeats the commands associated with them eg. Up(),Down() etc

  The original version attempted to smooth the scrolling and provide support
  for Ian Campbell's Syntax Hilite macro (colors.s). This is not required for
  TSE 2.6/TSE 2.8. Also, the original changed the BIOS settings for KeyRepeat
  and KeyDelay. I suggest simply setting these in Windows Control Panel to
  their fastest rates.

  Installing
  ÄÄÄÄÄÄÄÄÄÄÄ
  Simply copy QKEYS.MAC and QKEYS.S to your \TSE\MAC directory. Add 'qkeys'
  (without the quotes) to your AutoLoad list in TSE's Macro menu. Quit and
  Restart TSE.

  Press <CtrlShift CursorUp> to invoke the configuration menu.

  A user-configuration menu has been added to allow experimentation with the
  horizontal/vertical repeat rates and the repeat delay.

  Once you're happy with your configuration use the Save Settings option to
  make your settings permanent.

  Any feedback/bug reports will be gladly received. Enjoy!

  Caveats
  ÄÄÄÄÄÄÄÄÄÄÄ
  The key acceleration settings are a bit crude. In fact the slowest
  acceleration is _very_ fast. Sorry about that. In a future version I will
  try to incorporate some high resolution timers to smooth/slowdown the
  acceleration a little. If anyone knows how to access millisecond timers,
  please let me know.

  Disclaimer
  ÄÄÄÄÄÄÄÄÄÄÄ
  USE THIS MACRO AT YOUR OWN RISK. THE AUTHOR TAKES NO LIABILITY FOR DAMAGES
  INCURRED RESULTING FROM ITS USE.
