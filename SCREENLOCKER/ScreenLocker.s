/*
  Macro           ScreenLocker
  Author          Carlo.Hogeveen@xs4all.nl
  Version         v1.0.1   -   27 May 2020
  Compatibility   GUI versions of TSE Pro v4.2 upwards

  This tool intends to lock access to Windows until a password is re-entered.

  It has a screensaver!

  DISCLAIMER
  It has been tested for a short time on Windows 10 Pro, and not publicly yet.
  It is not unlikely to have flaws. Use at your own risk!

  CHALLENGE
  Please let me know if you find a way to access Windows without invoking the
  screenlocker's burglary reaction.
  Mention the Windows version if it is not Windows 10: I have this vague memory
  of many years ago breaking the method that ScreenLocker is now using.
  The assumption is a Windows computer on which autorun has been disabled
  for CDs and USB-devices.

  INSTALLATION
  Copy this file to TSE's "mac" folder and compile it there, for instance by
  opening the file there in TSE, and applying the Macro -> Compile menu.

  Execute the tool in any of these ways:
    By entering its name in TSE's Macro -> Execute menu.
    By adding it to TSE's Potpourri menu and starting it from there.
    From the command line, for example with: g32 -eScreenLocker
    By assigning a key to ExecMacro('ScreenLocker') in your .ui file.

  USAGE
  At any time if you do nothing the screensaver starts.
  On startup the screenlocker asks for a new password every time.
  A password can consist of any TSE keys except F10, Backspace and Enter.
  F10 lets you configure the reaction to a "burglary attempt".
  Configurable reactions are a warning, a Windows screenlock, or an immediate
  forced Windows shutdown.
  The default reaction is a warning without consequenses, so not a real lock.
  An attempt to leave the screen and more than 10 password attempts invoke the
  configured burglary reaction.

  CAVEAT
  If Windows itself locks its screen after a non-usage time-out, then that also
  invokes the screenlocker's configured burglary reaction.

  HISTORY
  v1.0    - 13 Jan 2020
    Initial version to test the concept.
  v1.0.1  - 27 May 2020
    No new features: This is just a technical update to make it compatible
    with TSE Pro v4.41.38 upwards by using v4.41.38's new built-in Random()
    function instead of the programmed one.

*/



// Compatability check

#ifdef WIN32
#else
   16-bit versions of TSE are not supported. You need at least TSE 4.2.
#endif

#ifdef EDITOR_VERSION
#else
   Editor Version is older than TSE 3.0. You need at least TSE 4.2.
#endif

#if EDITOR_VERSION < 4200h
   Editor Version is older than TSE 4.2. You need at least TSE 4.2.
#endif

// End of compatability check.



// Global constants
#define SCREENSAVER_DELAY 90    // In theory in 18ths of a second.
#define LOCK_ATTR         10    // 10 = Color(bright green ON black)



// Global variables
integer burglary_reaction               = 0
integer screensaver_remaining_delay     = SCREENSAVER_DELAY
string  input_password   [MAXSTRINGLEN] = ''
string  macro_name       [MAXSTRINGLEN] = ''
string  msg              [MAXSTRINGLEN] = ''
integer number_of_burglary_reactions    = 0
string  old_window_title [MAXSTRINGLEN] = ''
integer org_id                          = 0
string  password         [MAXSTRINGLEN] = ''
integer screen_is_locked                = FALSE
integer seed                            = 0
integer tmp_id                          = 0
integer unlocked_CursorAttr             = 0
integer unlocked_TextAttr               = 0
integer unlock_tries_left               = 10

proc to_beep_or_not_to_beep()
  if Query(Beep)
    Sound(1500,  500)
    Sound( 500, 1500)
  endif
end to_beep_or_not_to_beep

#if EDITOR_VERSION <= 4400h
  integer proc random()
    integer lo, Hi, test
    Hi = seed  /  127773
    lo = seed mod 127773
    test = 16807 * lo - (2147483647 mod 16807) * Hi
    if test > 0
      seed = test
    else
      seed = test + 2147483647
    endif
    return(seed)
  end random
#endif

proc matrix_screensaver()
  string  a  [MAXSTRINGLEN] = ''
  string  s  [MAXSTRINGLEN] = ''
  integer p                 = 0
  integer x                 = 0
  integer y                 = 0
  for y = Query(ScreenRows) downto 2
    GetStrAttrXY(1, y - 1, s,  a, MAXSTRINGLEN)
    PutStrAttrXY(1, y    , s, '', LOCK_ATTR)
  endfor
  for x = 1 to Query(ScreenCols)
    p = random() mod 100
    if p >= 95
      if s[x] == ' '
        s[x] = Chr(random() mod 94 + 33)
      else
        s[x] = ' '
      endif
    else
      if s[x] <> ' '
        if p >= 15
          s[x] = Chr(random() mod 94 + 33)
        else
          s[x] = ' '
        endif
      endif
    endif
  endfor
  PutStrAttrXY(1, 1, s, '', LOCK_ATTR)
end matrix_screensaver

proc display_helpline()
  PutStrAttrXY(1, Query(ScreenRows),
               'F10 menu   Backspace, Enter   Any other TSE key can be in the password.',
               '', LOCK_ATTR)
end display_helpline

proc display_password()
  PutStrAttrXY(10, 10, Format('':Length(input_password)/2:'*'), '', LOCK_ATTR)
end display_password

proc display_message()
  SetWindowTitle(msg)
  PutStrAttrXY(1, 1, Format(msg : Query(ScreenCols) * -1), '', LOCK_ATTR)
end display_message

proc idle()
  if screensaver_remaining_delay
    if screensaver_remaining_delay mod 18 == 0
      Set(Cursor    , OFF)
      Set(TextAttr  , LOCK_ATTR)
      Set(CursorAttr, LOCK_ATTR)
      Set(Attr      , LOCK_ATTR)
      ClrScr()
      display_message()
      display_password()
      if not screen_is_locked
        display_helpline()
      endif
    endif
    screensaver_remaining_delay = screensaver_remaining_delay - 1
  else
    matrix_screensaver()
  endif
end idle

proc react_to_burglary_attempt()
  number_of_burglary_reactions = number_of_burglary_reactions + 1
  if number_of_burglary_reactions == 1 // Once is enough.
    case burglary_reaction
      when 2
        Dos('%WINDIR%\System32\rundll32.exe user32.dll,LockWorkStation',
            _DONT_PROMPT_|_DONT_CLEAR_|_RUN_DETACHED_|_START_HIDDEN_)
      when 3
        // Immediately lock the screen first, because the quickest way to shut
        // down forcibly requires at least a 1 second delay.
        Dos('%WINDIR%\System32\rundll32.exe user32.dll,LockWorkStation',
            _DONT_PROMPT_|_DONT_CLEAR_|_RUN_DETACHED_|_START_HIDDEN_)
        Dos('shutdown /s /t 1')
    endcase
    Sound(1000, 250)
    Sound(1200, 250)
    Sound(1000, 250)
    Sound( 800, 250)
    Warn   ('There was a burglary attempt!')
    Message('There was a burglary attempt!') // Overwrites any obsolete message.
    PurgeMacro(macro_name)
  endif
end react_to_burglary_attempt

proc set_configured_burglary_reaction(integer p_burglary_reaction)
  burglary_reaction = p_burglary_reaction
  if not WriteProfileInt(macro_name + ':Configuration',
                         'BurglaryReaction',
                         burglary_reaction)
    Warn('Failed to save configuration setting.')
  endif
end set_configured_burglary_reaction

integer proc get_configured_burglary_reaction()
  burglary_reaction = GetProfileInt(macro_name + ':Configuration',
                                    'BurglaryReaction',
                                    1)
  return(burglary_reaction)
end get_configured_burglary_reaction

menu configuration_menu()
  title   = 'Burglary reaction'
  history = get_configured_burglary_reaction()
  '&Warning message and sound',
    set_configured_burglary_reaction(1),,
    'Make a sound and show a warning message.'
  '&Lock Windows',
    set_configured_burglary_reaction(2),,
    'Lock Windows.'
  '&Shutdown Windows',
    set_configured_burglary_reaction(3),,
    'Shut Windows down.'
end configuration_menu

proc configure()
  UnHook(idle)
  // Set(TextAttr, unlocked_attr)
  configuration_menu()
  // Set(TextAttr, LOCK_ATTR)
  Hook(_IDLE_        , idle)
  Hook(_NONEDIT_IDLE_, idle)
end configure

proc losing_focus()
  Message('Attempt to leave the screen locker detected!')
  react_to_burglary_attempt()
end losing_focus

proc after_getkey()
  integer key_code = Query(Key)
  screensaver_remaining_delay = SCREENSAVER_DELAY
  if screen_is_locked
    msg = 'The screen is locked: Enter password plus <Enter> to unlock.'
    if (key_code in <Enter>, <GreyEnter>)
      if input_password == password
        msg = 'The screen is unlocked.'
        PurgeMacro(macro_name)
      else
        unlock_tries_left = unlock_tries_left - 1
        if unlock_tries_left == 0
          msg = 'Too many password attempts!'
          Message(msg)
          react_to_burglary_attempt()
        else
          msg = Format('Wrong password: You have ', unlock_tries_left,
                       ' attempts left.')
          input_password = ''
        endif
      endif
    elseif key_code == <BackSpace>
      if Length(input_password)
        input_password = input_password[1 : Length(input_password) - 2]
      else
        to_beep_or_not_to_beep()
      endif
    else
      if Length(input_password) == 254
        to_beep_or_not_to_beep()
      else
        input_password = input_password        +
                         Chr(HiByte(key_code)) +
                         Chr(LoByte(key_code))
        display_password()
      endif
    endif
  else
    msg = 'Type a new password plus <Enter> to lock the screen.'
    if (key_code in <Enter>, <GreyEnter>)
      msg = 'The screen is locked: Enter password plus <Enter> to unlock.'
      password         = input_password
      input_password   = ''
      screen_is_locked = TRUE
    elseif key_code == <BackSpace>
      if Length(input_password)
        input_password = input_password[1 : Length(input_password) - 2]
      else
        to_beep_or_not_to_beep()
      endif
    elseif key_code == <F10>
      configure()
      msg = 'End of configuration. Type a new password plus <Enter> to lock the screen.'
      input_password = ''
    else
      if Length(input_password) == 254
        to_beep_or_not_to_beep()
      else
        input_password = input_password        +
                         Chr(HiByte(key_code)) +
                         Chr(LoByte(key_code))
      endif
      display_password()
    endif
  endif
  BreakHookChain() // Stop CUAMark and friends nicely from processing keys this way.
end after_getkey

Keydef no_keys
end no_keys

proc WhenLoaded()
  macro_name          = SplitPath(CurrMacroFilename(), _NAME_)
  org_id              = GetBufferId()
  old_window_title    = GetWindowTitle()
  seed                = GetClockTicks() mod 1000000000 - seed
  unlocked_CursorAttr = Query(CursorAttr)
  unlocked_TextAttr   = Query(TextAttr  )
  burglary_reaction   = get_configured_burglary_reaction()
  if isGUI()
    Enable(no_keys, _EXCLUSIVE_)
    tmp_id = CreateTempBuffer() // This file catches any key leaks.
    msg = 'Type a password plus <Enter> to lock the screen.'
    Hook(_AFTER_GETKEY_         , after_getkey )
    Hook(_IDLE_                 , idle         )
    Hook(_LOSING_FOCUS_         , losing_focus )
    Hook(_NONEDIT_IDLE_         , idle         )
    Hook(_NONEDIT_LOSING_FOCUS_ , losing_focus )
  else
    to_beep_or_not_to_beep()
    Warn(macro_name, ' only works in a GUI Version of TSE.')
    PurgeMacro(macro_name)
  endif
end WhenLoaded

proc WhenPurged()
  Disable(no_keys)
  // Do a hard ignore to avoid leaking the last key, usually <Enter>.
  Set(Key, -1)
  Set(Cursor, ON)
  Set(TextAttr  , unlocked_TextAttr  )
  Set(CursorAttr, unlocked_CursorAttr)
  if tmp_id
    GotoBufferId(org_id)
    AbandonFile (tmp_id)
  endif
  SetWindowTitle(old_window_title)
  UpdateDisplay(_ALL_WINDOWS_REFRESH_)
end WhenPurged

