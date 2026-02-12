/*
  Macro           Close_button_fix
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows TSE Pro GUI v4.2 upwards
  Version         v1   13 Dec 2021


  This TSE extension demonstrates a fix for the _ON_ABANDON_EDITOR_ hook not
  being called when the GUI version of TSE is closed with the "X" close button
  in its upper right corner if the TSE option "Empty Command-Line Action"
  has one of these values:
    Menu   (default)
    Restore State
    Also Restore State

  Based on this demo macro you still need to recode your own macros.

  The fix only works for TSE Pro GUI v4.2 upwards, because in that version
  the needed _LOSING_FOCUS_ hook was introduced.
  The fix does nothing when applied to lower TSE versions.

  The fix is based on the fact, that when the close button is used to close the
  editor, the _ON_EXIT_CALLED_ hook is still called, the _ON_ABANDON_EDITOR_
  hook is not called, and the _LOSING_FOCUS_ hook is still called.
  By letting on_exit_called() set a flag that on_abandon_editor needs to be
  called, and by letting on_abandon_editor() reset the flag when it is being
  called, losing_focus() can use the flag to call abandon_editor() when
  abandon_editor() has not been called yet. The _IDLE_ hook resets the flag to
  handle the case where closing the editor has been interrupted by the user and
  _LOSING_FOCUS_ is still called when the user (after an idle moment) switches
  to another application. I have not been able to skip the idle moment, so this
  solution seems solid.

  Each time the _on_abandon_editor_() procedure is called a tune is played,
  i.e. a series of 5 notes, each lower than the one before.

  The fix works best by autoloading this macro.

  We can then test all the different ways to close the editor and to interrupt
  closing the editor. Only when we actually close the editor should the tune
  play, and only once.
*/

#if EDITOR_VERSION >= 4200h
  integer on_abandon_editor_expected = FALSE
#endif

proc on_abandon_editor()
  #if EDITOR_VERSION >= 4200h
    on_abandon_editor_expected = FALSE
  #endif
  Sound(2000, 100)
  Sound(1600, 100)
  Sound(1200, 100)
  Sound( 800, 100)
  Sound( 400, 100)
end on_abandon_editor

#if EDITOR_VERSION >= 4200h
  proc idle()
    on_abandon_editor_expected = FALSE
  end idle

  proc losing_focus()
    if on_abandon_editor_expected
      on_abandon_editor()
    endif
  end losing_focus

  proc on_exit_called()
    on_abandon_editor_expected = TRUE
  end on_exit_called
#endif

proc WhenLoaded()
  Hook(_ON_ABANDON_EDITOR_, on_abandon_editor)
  #if EDITOR_VERSION >= 4200h
    Hook(_IDLE_           , idle             )
    Hook(_ON_EXIT_CALLED_ , on_exit_called   )
    Hook(_LOSING_FOCUS_   , losing_focus     )
  #endif
end WhenLoaded

