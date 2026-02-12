/*
  Macro             Status
  Author            Carlo.Hogeveen@xs4all.nl
  Compatibility     Windows TSE PRo 4.0 upwards
                    Linux TSE Beta v4.41.35 upwards
  Version           1.2.1   17 Sep 2022


  === INFORMATION FOR END USERS ===

  PURPOSE

    This macro helps some specific other macros to show additional statuses
    on the right hand side of the screen, and to handle actions upon them.

    So you the user do not use this macro directly, other than to install
    and optionally configure it.


  INSTALLATION

    Put this file (the one you are now reading) in TSE's "mac" folder,
    and compile it as a macro, for instance by opening this file in TSE
    and using the Macro Compile menu.


  CONFIGURATION

    Configuration is optional: The defaults should usually work well.

    Just execute this macro to access its main configuration menu.
    For example go to the TSE menu "Macro -> Execute", and enter "Status".

    Or you can execute 'Status ConfigureStatusColor' to directly access its
    colour configuration menu.

    Macro configuration options:

      Status text colour
        The status text colour must be different from all other text colours,
        and its foreground and background colours may not be the same.
        Default the status text colour is set to the menu text colour, which
        usually meets this requirement.
        Do not worry though: Even without explicit configuration, when the
        status text colour is not or no longer different from all other text
        colours, then you are automatically presented with the status text
        colour-picking screen, in which invalid colours are already blacked out.

      Response time
        Status updates only occur in the editors idle time, so that the editor
        will remain responsive.
        That said, in theory all that idle time could be filled up with
        excessive CPU usage for too frequent status updates. Hence this
        configuration option to decrease the macro's response time in
        order to slow CPU usage down.
        However, in tests with my own macros using the fastest setting, I only
        saw a negligible increase in CPU usage.
        Therefore the default response time is  set to 1 (18ths of a second),
        which is the fastest possible response time setting.

      Reposition time
        For a better user experience, there is a built-in preference to display
        a status update at the status' previous display position to avoid the
        screen flickering too much with madly switched around statuses.
        However, in theory, a screen can be so full of text, that it can become
        impossible to place statuses if some old status positions hold up a
        repositioning of all statuses.
        So once every "reposition time" old status positions are "forgotten",
        so that all statuses can be optimally repositioned from scratch.
        The default reposition time is 1080 (18ths of a second), which is
        once every minute.

  TSE window size configuration:
    This macro works best when there is sufficient empty space on the right
    hand side of the text editing window.

    Usually there is, but if you habitually use a small TSE window, then for
    this macro to work well you should consider enlarging TSE's window for a
    better user experience.

    Note that if you do enlarge (not maximize) TSE's window, then after that
    you need to use TSE's menu "Option -> Full Configuration -> Save Current
    Settings" to make it permanent.
    This assumes that in TSE's menu "Full Configuration -> Display/Color
    options -> Startup Options" the "Startup Window Size" is still configured
    to its default value "Last Saved Settings".


  HISTORY
    1.0.0   22 Jan 2018
      Initial release.
    1.0.1    9 Feb 2018
      Bug fixed:
        After "reposition time" (default a minute) an infrequently updated
        status would start flickering.
        E.g. this happened with the yet to be released new version of the
        EolType macro.
    1.1      9 Mar 2018
      Now sets a version number that other macros can check.
    1.1.1   15 Apr 2018
      Tiny bug fix:
        Even when the calling macro did not supply the callback parameter,
        it was always called back when the user clicked or typed a callback
        key on the status.
    1.2     30 Apr 2020
      Added Linux TSE v4.41.35 upwards compatibility.
      Added parameter to allow other macros direct access to the colour
      configuration menu.
      Bug fix: Pressing <Escape> in the colour menu now allows you to leave it
      if the old colour was a valid one.
      Various tiny tweaks and improvements to the code and documentation.
    1.2.1   17 Sep 2022
      Fixed incompatibility with TSE's '-i' command line option
      and the TSELOADDIR environment variable.



  === INFORMATION FOR MACRO WRITERS   -   HOW TO CALL THIS MACRO ===

  Claimer:
    I wrestled extremely long and hard with what this macro must, should,
    could, and would (not) do. After following several roads to complexity
    madness, I settled on some hard choices, keeping it simple, and handling
    only a limited area of concern. Therefore its limits on functionality and
    feature set are very deliberate.

  General info:
    Call this macro from your macro to temporarily show a status on the right
    hand side of the text area, and optionally implement what happens when your
    macro is called back by a user key or mouse action on the displayed status.

    Document and/or check in your macro that this macro needs to be installed.
    Otherwise your macro will give the Warning: "File not found: Status.mac".

    Because multiple calling macros can each display multiple statuses, each
    status must be identified by a unique status id, which must consist of the
    calling macro's name and a status name, separated by a colon.
    This status id is not part of the displayed status text.

    Depending on its version TSE's macro command line is limited to 127 or 255
    characters starting at the first non-space character of the first parameter.
    This implies a limit on the combined length of your macro name, the status
    name, the status text and other macro parameter syntax.
    That said, to keep statuses in the text area workable, they should be a lot
    shorter anyway, i.e. as short as possible while still well understandable.

    Each call to this macro results in at most one display of the provided
    status text.

    This macro does NOT preserve or redisplay a once displayed status, nor will
    it implicitly clear a status, though it will clear the remainder of a
    partially overwritten status.

    The lifetime of a once displayed status is completely up to what the
    editor, macros and the user do. For instance, it is complete OK for the
    user to type over a displayed status, or to clear the status by scrolling.

    You, the calling macro writer, can call this macro to explicitly clear
    your displayed status.

    The premise is, that statuses, that continuously need to be redisplayed,
    are redisplayed so by hooked events in your calling macro.


  Calling details:
    In short, this macro should be executed with parameters that have the
    following format:
      <calling macro's name>:<status name>[,c[allback]] [status text]

    In detail, your macro should call this macro with a line consisting of
    directives and optionally the status text that the user will see.
    Note that any whitespace and control characters you supply anywhere
    will be converted to spaces.
    Directives are case-insensitive, may not contain spaces, and multiple
    directives must be separated by a comma without any spaces.
    Status text to be displayed must be preceded by and may contain spaces.
    Directives:
    - The status-id is mandatory and must be the first directive.
      It must consist of these two names separated by a colon:
      - The name of your macro: this avoids conflicts with other macros
        that use this macro to display statuses.
      - A name for the status, which must be unique within the scope of the
        your macro.
    - The literal "callback" (shortened: "c") directive is optional.
      If you supply it, then your macro is called back when the user clicks or
      types on the displayed status.
    Text:
      The rest of the macro command line makes up the status text shown to the
      user. Note that leading spaces are trimmed off of the status text.
      If there is no tekst after the directives, then the corresponding
      status is explicitly cleared from the screen.


  Call examples:
    For example, assuming a macro with name "Lengths" that shows both the
    wordlength and the stringlength:
      ExecMacro("Status Lengths:WrdLen Wrd 9")   // Shows "Wrd 9".
      ExecMacro("Status Lengths:StrLen Str 45")  // Shows "Str 45".
    For example, assuming a macro "Lengths" that shows either the wordlength or
    the stringlength, but never both at the same time:
      ExecMacro("Status Lengths:Len Wrd 9")      // Internally the same status,
      ExecMacro("Status Lengths:Len Str 45")     // externally still different.
    For example, assuming a macro "Lengths", that currently wants to show the
    length of a word, and that wants to be called back when the user clicks on
    the status' text "Wrd 12":
      ExecMacro("Status Lengths:WrdLen,callback Wrd 12")


  Callback details:
    When this macro calls a macro back, because a status text was typed or
    clicked upon, then it does so with a macro commandline string that has the
    following format:
      callback <this macro's name> <status name> <key name>
    where <status name> is the status name of the status id of the actioned
    upon status, and where <key name> is the name of the TSE key or mouse
    button used on the status.

  Callback example:
    For example, when the "Lengths:WrdLen" status was displayed with the
    "callback" directive, and the status text was right-clicked, then the
    "Lengths" macro will be called back by this macro ("Status") with:
      ExecMacro("Lengths callback Status WrdLen <RightBtn>")


  Details for implementing callbacks:
    My general advice is to create a consistent user experience by implementing
    keys the same way the context does:
      <F1>                              Display Help.
      <RightBtn>, <F10>, <Shift F10>    Show a menu.
    Note that you might want to leave the <LeftBtn> alone, because the editor
    needs it to reposition the cursor.

    My specific advice is to look at my Lengths macro as an example.

  Caveat: Use this macro for statuses, not messages:
    I contemplated and dismissed making the Status macro useable for displaying
    messages. That turned out to be one of the roads to complexity madness.
    So the Status macro is not written to facilitate displaying a message.
    So, if you try to display a message as a "status text" anyway, be forewarned
    that some of the typical requirements for displaying a message are not met:
    - A status is displayed at most once and has no garanteed lifetime.
    - The longer a status text, the likelier it might not fit and be lost.
    - For a message it would make sense to find a solution for showing a longer
      text, but a status text must be short, so long text is not facilitated.
    - A currently undisplayable status is not queued for later display,
      because by then it would be outdated anyway, so it is discarded.
    - For a message it would make sense to log it, so it can later be consulted
      at the user's convenience; for a status that would be overkill.





  INFORMATION FOR MACRO WRITERS   -   THE DESIGN OF THIS MACRO

  Premise
    While editing I want several additional statuses, that each may consist of
    a very short text, and an occasional and exceptional one which may consist
    of up to fifty characters.
    TSE's standard status line is already pretty full.
    The right hand side of the text area is usually pretty empty.


  Target
    This macro needs to be able to be called by other macros to show additional
    statuses in optimal locations on the screen, and should optionally do a
    callback to the originating macro when its status is clicked or typed upon.

    Roughly it handles only two concerns: Where and when these additional
    statuses are optimally shown on the screen, and to pass back any actions
    upon them.


  Design
    Roughly this macro goes through these subtasks:
    - When called by another macro, add the status (display request) to an
      input queue.
      Exception to the queue: If a new status is passed while an old version of
      the same status (with the same status-id) is already in the input queue,
      then delete the older status and add the new one.
    - When called by the _idle_ hook:
      - After RESPONSE_TIME:
        ( thereby allowing other _idle_ hooks to generate statuses first
          and/or first do their own screen modifications):
        - Update statuses from the input queue to the statuses buffer.
        - Display updated statuses. Do it in their remembered locations in the
          text-area, otherwise find optimal locations. Read on for the used
          rules for "optimal location".
        After REPOSITION_TIME:
        - Reset all status positions.
    - When a user editing action is initiated:
      - If there was typed or clicked upon a displayed status for which a
        callback is defined, then execute the callback.



  Status displaying - The basics
  - The goal of handling an as small as possible area of concern to reduce
    complexity led to the following design decisions:
    - Status updates are displayed at most once at "display moments", which
      occur each time the editor has been idle for RESPONSE_TIME 1/18ths
      of a second.
    - If a status is updated multiple times between display moments,
      then only the last update is displayed; the rest is discarded.
    - A status update, that at the display moment doesn't fit on the screen
      according to this macro's display rules, is also discarded.
    - A displayed status has no borders between it and editing text.
      ( Text area real estate is assumed to be scarce and expensive. )
    - Everybody and everything is allowed to clear or overwrite a displayed
      status. It will not be implicitly redisplayed.
    - An displayed status remains displayed indefinitly until anybody or
      anything (partially) overwrites or clears it.
    - The remainder of a partially overwritten status will be cleared.
    - Just changing the cursor position does NOT remove a displayed status.
      The downside might be a temporarily wrong status, but this simplifies
      the design hugely, and as long as it's done consistently users will
      naturally adapt to this behaviour.
    - To be able to recognize an on-screen status text part, the status text
      colour must differ from all other editing text colours, like normal
      text, cursor line text, blocked text, and (syntax) hilited text.



  Criteria for which statuses should be placed where in descending priority:
  - Which
    - Previously displayed statuses.
    - Longer before shorter statuses.
  - Where
    - Not between editing text.
    - At a textless part of sufficient size in the text area.
    - Not concatenated to another status on the same line.
    - At its previous location, possibly extending it to the left. (1)
    - As much to the right hand side of the text area as possible. (2)
    - As much to the top of the text area as possible.

  (1) Priority exception: Placing a recurring status at its previous location
      trumps the longer before shorter status rule. Here a more restful user
      experience was chosen over an optimal use of free text area.
  (2) Partially implemented: For now only completely to the right hand side.
      It is documented this way because there already is some code for the
      full implementation.



  Internal data-structures:
    In general
      The input queue and display memory are both implemented as a TSE buffer,
      in which entries are implemented as lines.

    Input queue
      A buffer of lines, sorted downward from old to new, each line containing
      the unprocessed parameters of a call to this macro, with the optimization
      that for a new line with an already occurring status id
      (<macro name>:<status name>) the old line is deleted.
      Line format:
        <macro name>:<status name>[,c|callback] <status text>

    Statuses
      An buffer of lines, one line per status, sometimes sorted on the status'
      displayed text length from long to short, each line representing how the
      status was or is to be displayed in the text window.
      The buffer retains status data temporarily and at most as long
      as REPOSITION_TIME for these express purposes:
      - To be able to completely clear an already partially overwritten status.
      - To be able to reposition a status at its previous location.
      Line format:
        Consecutive fields contain information about the status,
        each field having fixed length MAXSTRINGLEN.
      Fields:
        1   Status id   <their macro name>:<status name>
        2   Callback    cy|cn     Can status be called back or not.
        3   State       --        Not displayed, no pending action.
                        -u        Not displayed, to be updated.
                        d-        Being displayed, no pending action.
                        du        Being displayed, to be updated.
        4   X position  <integer> Horizonal position in the window.
        5   Y position  <integer> Vertical position in the window.
        6   Length      <integer> Length of the displayed status text.
        7   Text        <string>  The displayed status text.
        8   New text    <string>  A text update for this status.
*/





// Compatibility restrictions and mitigations

#ifdef LINUX
  #define WIN32 FALSE
#endif

#ifdef WIN32
#else
   16-bit versions of TSE are not supported. You need at least TSE 4.0.
#endif

#ifdef EDITOR_VERSION
#else
   Editor Version is older than TSE 3.0. You need at least TSE 4.0.
#endif

#if EDITOR_VERSION < 4000h
   Editor Version is older than TSE 4.0. You need at least TSE 4.0.
#endif

#if EDITOR_VERSION < 4400h
  /*
    StrReplace() 1.0

    If you have TSE Pro 4.0 or 4.2, then this proc almost completely implements
    the built-in StrReplace() function of TSE Pro 4.4.
    The StrReplace() function replaces a string (pattern) inside a string.
    It works for strings like the Replace() function does for files, so read
    the Help for the Replace() function for the usage of the options, but apply
    these differences while reading:
    - Where Replace() refers to "file" and "line", StrReplace() refers to
      "string".
    - The options "g" ("global", meaning "from the start of the string")
      and "n" ("no questions", meaning "do not ask for confirmation on
      replacements") are implicitly always active, and can therefore be omitted.
    Notable differences between the procedure below with TSE 4.4's built-in
    function are, that here the fourth parameter "options" is mandatory
    and that the fifth parameter "start position" does not exist.
  */
  integer strreplace_id = 0
  string proc StrReplace(string needle, string haystack, string replacer, string options)
    integer i                      = 0
    integer org_id                 = GetBufferId()
    string  result  [MAXSTRINGLEN] = haystack
    string  validated_options [20] = 'gn'
    for i = 1 to Length(options)
      if (Lower(SubStr(options, i, 1)) in '0'..'9', 'b', 'i','w', 'x', '^', '$')
        validated_options = validated_options + SubStr(options, i, 1)
      endif
    endfor
    if strreplace_id == 0
      strreplace_id = CreateTempBuffer()
    else
      GotoBufferId(strreplace_id)
      EmptyBuffer()
    endif
    InsertText(haystack, _INSERT_)
    lReplace(needle, replacer, validated_options)
    result = GetText(1, CurrLineLen())
    GotoBufferId(org_id)
    return(result)
  end StrReplace
#endif



// Here in the Status macro compare_versions() is only used for Linux TSE.

#ifdef LINUX

  /*
    compare_versions()  v2.0

    This proc compares two version strings version1 and version2, and returns
    -1, 0 or 1 if version1 is smaller, equal, or greater than/to version2.

    For the comparison a version string is split into parts:
    - Explicitly by separating parts by a period.
    - Implicitly:
      - Any uninterrupted sequence of digits is a "number part".
      - Any uninterrupted sequence of other characters is a "string part".

    Spaces are mostly ignored. They are only significant:
    - Between two digits they signify that the digits belong to different parts.
    - Between two "other characters" they belong to the same string part.

    If the first version part is a single "v" or "V" then it is ignored.

    Two version strings are compared by comparing their respective version parts
    from left to right.

    Two number parts are compared numerically, e.g: "1" < "2" < "11" < "012".

    Any other combination of version parts is case-insensitively compared as
    strings, e.g: "12" < "one" < "three" < "two", or "a" < "B" < "c" < "d".

    Examples: See the included unit tests further on.

    v2.0
      Out in the wild there is an unversioned version of compare_versions(),
      that is more restricted in what version formats it can recognize,
      therefore here versioning of compare_versions() starts at v2.0.
  */

  // compare_versions_standardize() is a helper proc for compare_versions().

  string proc compare_versions_standardize(string p_version)
    integer char_nr                  = 0
    string  n_version [MAXSTRINGLEN] = Trim(p_version)

    // Replace any spaces between digits by one period. Needs two StrReplace()s.
    n_version = StrReplace('{[0-9]} #{[0-9]}', n_version, '\1.\2', 'x')
    n_version = StrReplace('{[0-9]} #{[0-9]}', n_version, '\1.\2', 'x')

    // Remove any spaces before and after digits.
    n_version = StrReplace(' #{[0-9]}', n_version, '\1', 'x')
    n_version = StrReplace('{[0-9]} #', n_version, '\1', 'x')

    // Remove any spaces before and after periods.
    n_version = StrReplace(' #{\.}', n_version, '\1', 'x')
    n_version = StrReplace('{\.} #', n_version, '\1', 'x')

    // Separate version parts by periods if they aren't yet.
    char_nr = 1
    while char_nr < Length(n_version)
      case n_version[char_nr:1]
        when '.'
          NoOp()
        when '0' .. '9'
          if not (n_version[char_nr+1:1] in '0' .. '9', '.')
            n_version = n_version[1:char_nr] + '.' + n_version[char_nr+1:MAXSTRINGLEN]
          endif
        otherwise
          if (n_version[char_nr+1:1] in '0' .. '9')
            n_version = n_version[1:char_nr] + '.' + n_version[char_nr+1:MAXSTRINGLEN]
          endif
      endcase
      char_nr = char_nr + 1
    endwhile
    // Remove a leading 'v' if it is by itself, i.e not part of a non-numeric string.
    if  (n_version[1:2] in 'v.', 'V.')
      n_version = n_version[3:MAXSTRINGLEN]
    endif
    return(n_version)
  end compare_versions_standardize

  integer proc compare_versions(string version1, string version2)
    integer result                 = 0
    string  v1_part [MAXSTRINGLEN] = ''
    string  v1_str  [MAXSTRINGLEN] = ''
    string  v2_part [MAXSTRINGLEN] = ''
    string  v2_str  [MAXSTRINGLEN] = ''
    integer v_num_parts            = 0
    integer v_part_nr              = 0
    v1_str      = compare_versions_standardize(version1)
    v2_str      = compare_versions_standardize(version2)
    v_num_parts = Max(NumTokens(v1_str, '.'), NumTokens(v2_str, '.'))
    repeat
      v_part_nr = v_part_nr + 1
      v1_part   = Trim(GetToken(v1_str, '.', v_part_nr))
      v2_part   = Trim(GetToken(v2_str, '.', v_part_nr))
      if  v1_part == ''
      and isDigit(v2_part)
        v1_part = '0'
      endif
      if v2_part == ''
      and isDigit(v1_part)
        v2_part = '0'
      endif
      if  isDigit(v1_part)
      and isDigit(v2_part)
        if     Val(v1_part) < Val(v2_part)
          result = -1
        elseif Val(v1_part) > Val(v2_part)
          result =  1
        endif
      else
        result = CmpiStr(v1_part, v2_part)
      endif
    until result    <> 0
       or v_part_nr >= v_num_parts
    return(result)
  end compare_versions

#endif

// End of compatibility restrictions and mitigations.





/*
  Internal configuration constants:
    ERRORS_IGNORED_DURATION
      After an error is reported other errors will be ignored
      for ERRORS_IGNORED_DURATION 1/18ths of a second.
      This macro needs to able to report errors, but because of its nature an
      error probably would recur so frequently as to block you from doing
      anything other than acknowledging error messages.
    MAX_STATUSES
      This is a safeguard value.
      Typically there will be less than say 10 statuses to handle.
      Enter an evil or playful macro programmer (one of whom might be me)
      who starts to generate status ids: Then two problems might arise when
      too many statuses are created.
      1 This macro will stop working correctly if there are more than 65536
        statuses to handle (because that is the maximum number of lines TSE's
        internal Sort can handle).
      2 Probably long before that it will make the whole editor will slow down
        or even freeze.
      To avoid these two problems all statuses will be cleared when more
      than MAX_STATUSES have accumulated.
      Never ever set MAX_STATUSES to a value larger than 65535.
    RESPONSE_TIME_DEFAULT
      In theory a fast response time could consume too much CPU time.
      In practice my own tests (with my own calling macros) do not show that, so
      if not set by the user, then the default is set to 1 (18ths of a second)
      for the fastest response time.
    REPOSITION_TIME_DEFAULT
      In theory favouring remembered status positions could prevent finding
      optimal new status positions, so once in a while (read: reposition_time)
      all previous status positions are forgotten, and new status positions are
      determined from scratch. If not set by the user, then the default
      reposition_time is set to 1080 (18ths of a second), which is one minute.
*/
#define ERRORS_IGNORED_DURATION 18 * 60
#define MAX_STATUSES            256
#define REPOSITION_TIME_DEFAULT 18 * 60
#define RESPONSE_TIME_DEFAULT   18 / 18



/*
  Internal configuration variables:
    REPOSITION_TIME
      Normally, when possible, updates of statuses are positioned at their
      previous location, thus avoiding continously searching for madly jumping
      statuses.
      Short-term that is a big improvement, however long-term an unluckily
      positioned status should not remain there forever.
      The reposition time determines after how many 1/18ths of a second of
      non-consecutive idle time all status updates should be positioned from
      scratch.
      Aside: Note again, that already displayed statuses are themselves never
      repositioned: Only updates of statuses can lead to new positions.
    RESPONSE_TIME
      Defines after how many 1/18ths of a second of consecutive idle time,
      in which there were no file changes, status updates should be displayed.
      Do NOT set a too small/fast response time: Not doing so gives other
      macros a chance to create and update statuses and/or do their own screen
      updates first, and it keeps the editor responsive.
*/
integer reposition_time = REPOSITION_TIME_DEFAULT
integer response_time   = RESPONSE_TIME_DEFAULT



// Global integer constants

/*
  Notes:
  - MAXSTRINGLEN is more than double the string lengths that can be passed to
    the MacroCmdLine, but chosen just in case Semware ever increases the latter.
  - Assigning the same maximum string length to all status buffer fields costs
    extra memory, but gives faster access and simpler, better maintainable code.
  - The status buffer will remain small, so the extra memory cost is acceptable.
*/
#define STATUS_BUFFER_MAX_FIELD_LENGTH MAXSTRINGLEN

#define STATUS_BUFFER_FIELD_1     1
#define STATUS_BUFFER_FIELD_2     STATUS_BUFFER_FIELD_1 + STATUS_BUFFER_MAX_FIELD_LENGTH
#define STATUS_BUFFER_FIELD_3     STATUS_BUFFER_FIELD_2 + STATUS_BUFFER_MAX_FIELD_LENGTH
#define STATUS_BUFFER_FIELD_4     STATUS_BUFFER_FIELD_3 + STATUS_BUFFER_MAX_FIELD_LENGTH
#define STATUS_BUFFER_FIELD_5     STATUS_BUFFER_FIELD_4 + STATUS_BUFFER_MAX_FIELD_LENGTH
#define STATUS_BUFFER_FIELD_6     STATUS_BUFFER_FIELD_5 + STATUS_BUFFER_MAX_FIELD_LENGTH
#define STATUS_BUFFER_FIELD_7     STATUS_BUFFER_FIELD_6 + STATUS_BUFFER_MAX_FIELD_LENGTH
#define STATUS_BUFFER_FIELD_8     STATUS_BUFFER_FIELD_7 + STATUS_BUFFER_MAX_FIELD_LENGTH



// Global string constants

string MY_MACRO_VERSION [5] = '1.2.1'
string COLORS          [46] = 'Black Blue Green Cyan Red Magenta Yellow White'



// Global variables

integer abort                          = FALSE
integer input_queue_id                 = 0
integer last_error_clockticks          = 0
integer last_filechanged               = 0
string  my_macro_name   [MAXSTRINGLEN] = ''
integer reposition_timer               = REPOSITION_TIME_DEFAULT
integer reset_statuses                 = FALSE
integer response_timer                 = RESPONSE_TIME_DEFAULT
integer restart_the_menu               = FALSE
integer statuses_id                    = 0
integer status_attr                    = 0
string  status_attr_chr            [1] = '' // Redundant for performance.



// Procedures

integer proc is_valid_status_color(integer status_attr)
  integer result = TRUE
  integer background_color = status_attr  /  16
  integer foreground_color = status_attr mod 16
  if foreground_color == background_color
    result = FALSE
  elseif status_attr in Query(TextAttr),
                        Query(HiliteAttr),
                        Query(BlockAttr),
                        Query(CursorAttr),
                        Query(CursorInBlockAttr),
                        Query(Directive1Attr),
                        Query(Directive2Attr),
                        Query(Directive3Attr),
                        Query(MultiLnDlmt1Attr),
                        Query(MultiLnDlmt2Attr),
                        Query(MultiLnDlmt3Attr),
                        Query(SingleLnDlmt1Attr),
                        Query(SingleLnDlmt2Attr),
                        Query(SingleLnDlmt3Attr),
                        Query(ToEol1Attr),
                        Query(ToEol2Attr),
                        Query(ToEol3Attr),
                        Query(Quote1Attr),
                        Query(Quote2Attr),
                        Query(Quote3Attr),
                        Query(NumberAttr),
                        Query(IncompleteQuoteAttr),
                        Query(Keywords1Attr),
                        Query(Keywords2Attr),
                        Query(Keywords3Attr),
                        Query(Keywords4Attr),
                        Query(Keywords5Attr),
                        Query(Keywords6Attr),
                        Query(Keywords7Attr),
                        Query(Keywords8Attr),
                        Query(Keywords9Attr)
    result = FALSE
  endif
  return(result)
end is_valid_status_color

string proc get_color_name(integer color_attr)
  integer color_background = color_attr  /  16
  integer color_foreground = color_attr mod 16
  string  color_name  [33] = 'Intense Bright Magenta on Magenta'
  color_name = iif(color_background > 7, 'Intense ', '')
             + iif(color_foreground > 7, 'Bright ' , '')
             + GetToken(COLORS, ' ', (color_foreground mod 8) + 1)
             + ' on '
             + GetToken(COLORS, ' ', (color_background mod 8) + 1)
  return(color_name)
end get_color_name

integer proc select_color(integer param_color, string param_prompt)
  integer background                  = 0
  string  color_name             [33] = 'Intense Bright Magenta on Magenta'
  integer cols_per_color              = (Query(ScreenCols) - 2) / 16
  integer foreground                  = 0
  integer grid_color                  = 0
  integer left_margin                 = 0
  integer mouse_background            = 0
  integer mouse_foreground            = 0
  integer old_attr                    = Set(Attr, Color(bright white ON black))
  integer old_cursor                  = Set(Cursor, OFF)
  integer old_SpecialEffects          = 0
  integer prev_clockticks             = 0
  integer rows_per_color              = (Query(ScreenRows) - 3) / 16
  integer selected_color              = param_color
  integer selected_background         = 0
  integer selected_foreground         = 0
  integer sub_row                     = 0
  integer top_margin                  = (Query(ScreenRows) - 3 - rows_per_color * 16) / 2 + 1
  string  window_title [MAXSTRINGLEN] = ''
          left_margin                 = (Query(ScreenCols) - 2 - cols_per_color * 16) / 2 + 1
  BufferVideo()
  ClrScr()
  if param_color <> 0
     selected_foreground = param_color mod 16
     selected_background = param_color  /  16
  endif
  repeat
    color_name = get_color_name(selected_background * 16 + selected_foreground)
    if param_prompt == ''
      window_title = color_name
    else
      window_title = Format(param_prompt, color_name:36)
    endif
    PutStrAttrXY(1, 1, window_title, '', Color(bright white ON black))
    ClrEol()
    PopWinOpen(left_margin,
               top_margin,
               left_margin + (cols_per_color * 16) + 1,
               top_margin  + (rows_per_color * 16) + 1,
               1,
               '',
               Color(bright white ON black))
    for foreground = 0 to 15 // Rows.
      for background = 0 to 15 // Columns.
        for sub_row = 1 to rows_per_color
          if foreground <> 0 // Skip a bug in the PutStrAttrXY command
          or background <> 0 // up to and including TSE 4.2.
            grid_color = background * 16 + foreground
            if is_valid_status_color(grid_color)
              PutStrAttrXY(background * cols_per_color + 1,
                           foreground * rows_per_color + sub_row,
                           Format((grid_color)
                                  :cols_per_color:'0':16),
                           '',
                           grid_color)
            endif
          endif
        endfor
      endfor
    endfor
    old_SpecialEffects = Set(SpecialEffects,
                         Query(SpecialEffects) & ~ _DRAW_SHADOWS_)
    PopWinOpen(left_margin + selected_background * cols_per_color,
               top_margin  + selected_foreground * rows_per_color,
               left_margin + selected_background * cols_per_color + cols_per_color + 1,
               top_margin  + selected_foreground * rows_per_color + rows_per_color + 1,
               1,
               '',
               Color(bright white ON black))
    Set(SpecialEffects, old_SpecialEffects)
    UnBufferVideo()
    case GetKey()
      when <Home>, <GreyHome>
        selected_foreground = 0
        selected_background = 0
      when <end>, <GreyEnd>
        selected_foreground = 15
        selected_background = 15
      when <CursorDown>, <GreyCursorDown>
        if selected_foreground == 15
          selected_foreground = 0
        else
          selected_foreground = selected_foreground + 1
        endif
      when <CursorUp>, <GreyCursorUp>
        if selected_foreground == 0
          selected_foreground = 15
        else
          selected_foreground = selected_foreground - 1
        endif
      when <CursorRight>, <GreyCursorRight>
        if selected_background == 15
          selected_background = 0
        else
          selected_background = selected_background + 1
        endif
      when <CursorLeft>, <GreyCursorLeft>
        if selected_background == 0
          selected_background = 15
        else
          selected_background = selected_background - 1
        endif
      when <LeftBtn>
        /*
          The Delay(1) turned out to be necessary to give the system
          time to update the mouse status. An extra call to MouseStatus
          was useless, as could be expected, because TSE should already
          do that internally after a mousekey.
        */
        Delay(1)
        mouse_background = (Query(MouseX) - left_margin - 1) / cols_per_color
        mouse_foreground = (Query(MouseY) -  top_margin - 1) / rows_per_color
        if  (mouse_background in 0 .. 15)
        and (mouse_foreground in 0 .. 15)
          if  mouse_background == selected_background
          and mouse_foreground == selected_foreground
            if GetClockTicks() - prev_clockticks < 18
              PushKey(<Enter>)
            endif
          else
            selected_background = mouse_background
            selected_foreground = mouse_foreground
          endif
          prev_clockticks = GetClockTicks()
        endif
    endcase
    BufferVideo()
    PopWinClose()
    PopWinClose()
  until Query(Key) in <Enter>, <GreyEnter>, <Escape>
  UpdateDisplay(_ALL_WINDOWS_REFRESH_)
  UnBufferVideo()
  Set(Attr  , old_attr  )
  Set(Cursor, old_cursor)
  if Query(Key) <> <Escape>
    selected_color = selected_background * 16 + selected_foreground
  endif
  return(selected_color)
end select_color

proc macro_cmd_line_2_input_queue()
  integer org_id                       = GetBufferId()
  string macro_cmd_line [MAXSTRINGLEN] = Trim(Query(MacroCmdLine))
  string status_id      [MAXSTRINGLEN] = GetToken(macro_cmd_line, ' ', 1)
  GotoBufferId(input_queue_id)
  if lFind(status_id + ' ', '^gi')
  or lFind(status_id      , '^gi$')
    KillToEol()
    InsertText(macro_cmd_line, _INSERT_)
  else
    EndFile()
    AddLine(macro_cmd_line)
  endif
  GotoBufferId(org_id)
end macro_cmd_line_2_input_queue

proc show_error(string name, string text)
  /*
  PushPosition()
  EndFile()
  AddLine(Format(my_macro_name, ':Error ', '"', name, '" ', StrReplace('#m', text, my_macro_name, '')))
  PopPosition()
  */
  if GetClockTicks() - last_error_clockticks > ERRORS_IGNORED_DURATION
    Warn(my_macro_name; 'error:'; '"', name, '"'; StrReplace('#m', text, my_macro_name, ''))
    last_error_clockticks = GetClockTicks()
  endif
end show_error

proc get_status_properties(var string  status_id,
                           var string  callback,
                           var integer being_displayed,
                           var integer to_be_updated,
                           var integer x_pos,
                           var integer y_pos,
                           var integer len,
                           var string  text,
                           var string  new_text)
  string state [3] = ''

  status_id =     Trim(GetText(STATUS_BUFFER_FIELD_1, STATUS_BUFFER_MAX_FIELD_LENGTH))
  callback  =     Trim(GetText(STATUS_BUFFER_FIELD_2, STATUS_BUFFER_MAX_FIELD_LENGTH))
  state     =     Trim(GetText(STATUS_BUFFER_FIELD_3, STATUS_BUFFER_MAX_FIELD_LENGTH))
  x_pos     = Val(Trim(GetText(STATUS_BUFFER_FIELD_4, STATUS_BUFFER_MAX_FIELD_LENGTH)))
  y_pos     = Val(Trim(GetText(STATUS_BUFFER_FIELD_5, STATUS_BUFFER_MAX_FIELD_LENGTH)))
  len       = Val(Trim(GetText(STATUS_BUFFER_FIELD_6, STATUS_BUFFER_MAX_FIELD_LENGTH)))
  text      =     Trim(GetText(STATUS_BUFFER_FIELD_7, STATUS_BUFFER_MAX_FIELD_LENGTH))
  new_text  =     Trim(GetText(STATUS_BUFFER_FIELD_8, STATUS_BUFFER_MAX_FIELD_LENGTH))

  being_displayed  = (SubStr(state, 1, 1) == 'd')
  to_be_updated    = (SubStr(state, 2, 1) == 'u')
end get_status_properties

proc set_status_properties(var string  status_id,
                           var string  callback,
                           var integer being_displayed,
                           var integer to_be_updated,
                           var integer x_pos,
                           var integer y_pos,
                           var integer len,
                           var string  text,
                           var string  new_text)
  BegLine()
  KillToEol()
  GotoColumn(STATUS_BUFFER_FIELD_1)
  InsertText(status_id , _INSERT_)
  GotoColumn(STATUS_BUFFER_FIELD_2)
  InsertText(callback  , _INSERT_)
  GotoColumn(STATUS_BUFFER_FIELD_3)
  InsertText(iif(being_displayed, 'd', '-') + iif(to_be_updated, 'u', '-'), _INSERT_)
  GotoColumn(STATUS_BUFFER_FIELD_4)
  InsertText(Str(x_pos), _INSERT_)
  GotoColumn(STATUS_BUFFER_FIELD_5)
  InsertText(Str(y_pos), _INSERT_)
  GotoColumn(STATUS_BUFFER_FIELD_6)
  InsertText(Str(len)  , _INSERT_)
  GotoColumn(STATUS_BUFFER_FIELD_7)
  InsertText(text      , _INSERT_)
  GotoColumn(STATUS_BUFFER_FIELD_8)
  InsertText(new_text  , _INSERT_)
end set_status_properties

proc add_input_queue_to_statuses()
  string  input_callback    [MAXSTRINGLEN] = ''
  string  input_directives  [MAXSTRINGLEN] = ''
  string  input_line        [MAXSTRINGLEN] = ''
  string  input_macro_name  [MAXSTRINGLEN] = ''
  string  input_id          [MAXSTRINGLEN] = ''
  string  input_name        [MAXSTRINGLEN] = ''
  string  input_text        [MAXSTRINGLEN] = ''
  integer org_id                           = GetBufferId()
  string  status_callback   [MAXSTRINGLEN] = ''
  string  status_id         [MAXSTRINGLEN] = ''
  string  status_new_text   [MAXSTRINGLEN] = ''
  integer status_being_displayed           = FALSE
  integer status_to_be_updated             = FALSE
  string  status_old_text   [MAXSTRINGLEN] = ''
  integer status_x_pos                     = 0
  integer status_y_pos                     = 0
  integer status_len                       = 0
  GotoBufferId(input_queue_id)
  BegFile()
  if NumLines() > 0
    repeat
      if CurrLineLen() > 0
        input_line       = Trim(StrReplace('[\d000-\d031]', GetText(1, MAXSTRINGLEN), ' ', 'x'))
        input_directives = GetToken(input_line      , ' ', 1)
        input_id         = GetToken(input_directives, ',', 1)
        input_macro_name = GetToken(input_id        , ':', 1)
        input_name       = GetToken(input_id        , ':', 2)
        input_callback   = GetToken(input_directives, ',', 2)
        input_text       = Trim(SubStr(input_line, Length(input_directives) + 2, MAXSTRINGLEN))
        if Length(input_macro_name) == 0
        or (    Lower(input_macro_name) == Lower(my_macro_name)
            and Lower(input_id)         <> (Lower(my_macro_name) + ':error'))
          show_error(input_macro_name, 'not allowed to call "#m"')
        elseif not isMacroLoaded(input_macro_name)
          show_error(input_macro_name, 'not loaded, so it cannot call "#m"')
        elseif Length(input_name) == 0
          show_error(input_macro_name, 'provided no "#m" name')
        elseif not (input_callback in 'callback', 'c', '')
          show_error(input_macro_name, 'sent illegal directive "' + input_callback + '" to "#m"')
        else
          input_callback = iif(input_callback == '', 'cn', 'cy')
          GotoBufferId(statuses_id)
          if lFind(input_id + ' ', 'gi^')
            get_status_properties(status_id, status_callback,
                                  status_being_displayed, status_to_be_updated,
                                  status_x_pos, status_y_pos, status_len,
                                  status_old_text, status_new_text)
            status_id            = input_id
            status_callback      = input_callback
            status_to_be_updated = TRUE
            status_new_text      = input_text
            set_status_properties(status_id, status_callback,
                                  status_being_displayed, status_to_be_updated,
                                  status_x_pos, status_y_pos, status_len,
                                  status_old_text, status_new_text)
          else
            EndFile()
            AddLine()
            status_being_displayed = FALSE
            status_to_be_updated   = TRUE
            status_x_pos           = 0
            status_y_pos           = 0
            status_len             = 0
            status_old_text        = ''
            set_status_properties(input_id, input_callback,
                                  status_being_displayed, status_to_be_updated,
                                  status_x_pos, status_y_pos, status_len,
                                  status_old_text, input_text)
          endif
        endif
      endif
      GotoBufferId(input_queue_id)
    until not Down()
  endif
  EmptyBuffer()
  GotoBufferId(org_id)
end add_input_queue_to_statuses

proc display_statuses()
  integer org_id                      = GetBufferId()

  // Status fields
  string  status_id    [MAXSTRINGLEN] = ''
  string  callback     [MAXSTRINGLEN] = ''
  integer being_displayed             = FALSE
  integer to_be_updated               = FALSE
  integer x_pos                       = 0
  integer y_pos                       = 0
  integer len                         = 0
  string  text         [MAXSTRINGLEN] = ''
  string  new_text     [MAXSTRINGLEN] = ''

  integer old_MsgLevel                = 0

  string  screen_chars [MAXSTRINGLEN] = ''
  string  screen_attrs [MAXSTRINGLEN] = ''
  string  blank_chars  [MAXSTRINGLEN] = ''

  integer attr_matches                = 0

  integer i                           = 0
  integer max_i                       = 0
  integer max_i_y                     = 0
  integer y                           = 0
  integer new_len                     = 0
  integer extra_separator_len         = 0
  integer expansion                   = 0
  integer reduction                   = 0
  integer place_found                 = FALSE

  integer border_left_x               = Query(WindowX1)
  integer border_right_x              = border_left_x + Query(WindowCols) - 1
  integer border_top_y                = Query(WindowY1)
  integer border_bottom_y             = border_top_y  + Query(WindowRows) - 1
  integer border_width                = Min(border_right_x - border_left_x + 1, 256)

  BufferVideo()

  GotoBufferId(statuses_id)

  if NumLines() > MAX_STATUSES
    reset_statuses = TRUE
  endif

  /*
    Step 1

    For all statuses that have state "being displayed":
    - If not displayed on the screen any more,
      then set its state to "not displayed".
    - If partially overwritten on the screen
      then clear the remainder on the screen,
      and set its state to "not displayed".
  */
  BegFile()
  repeat
    get_status_properties(status_id, callback, being_displayed, to_be_updated,
                          x_pos, y_pos, len, text, new_text)
    if being_displayed
      GetStrAttrXY(x_pos, y_pos, screen_chars, screen_attrs, len)
      attr_matches = 0
      for i = 1 to len
        if SubStr(screen_attrs, i, 1) == status_attr_chr
          attr_matches = attr_matches + 1
        endif
      endfor
      if attr_matches > 0
        if attr_matches < len
        or reset_statuses
          for i = 1 to len
            if SubStr(screen_attrs, i, 1) == status_attr_chr
              screen_chars[i:1] = ' '
              screen_attrs[i:1] = Chr(Query(TextAttr))
            endif
          endfor
          PutStrAttrXY(x_pos, y_pos, screen_chars, screen_attrs)
          being_displayed = FALSE
        endif
      else
        being_displayed = FALSE
      endif
      if not being_displayed
        set_status_properties(status_id, callback, being_displayed, to_be_updated,
                              x_pos, y_pos, len, text, new_text)
      endif
    endif
  until not Down()

  /*
    Step 2

    When there are too many statuses or when the reposition_timer went off,
    then still displayed statuses have just been cleared from the editing
    window, and now the status buffer has to be reset as follows:
    - Initialize the position, length and text of to be updated statuses.
    - Delete all not to be updated statuses.
  */
  if reset_statuses
    BegFile()
    repeat
      get_status_properties(status_id, callback, being_displayed, to_be_updated,
                            x_pos, y_pos, len, text, new_text)
      if to_be_updated
        text      = ''
        x_pos     = 0
        y_pos     = 0
        len       = 0
        set_status_properties(status_id, callback, being_displayed, to_be_updated,
                              x_pos, y_pos, len, text, new_text)
      else
        KillLine()
        Up()
      endif
    until not Down()
    if  CurrLine()                              <= 1
    and Length(Trim(GetText(1, CurrLineLen()))) == 0
      EmptyBuffer()   // Ensure next AddLine() creates line 1.
    endif
    reset_statuses = FALSE
  endif

  /*
    Step 3

    Sort statuses descending on the new text size.
  */
  if NumLines() > 1
    PushBlock()
    MarkColumn(1, STATUS_BUFFER_FIELD_6, NumLines(), STATUS_BUFFER_FIELD_7 - 1)
    old_MsgLevel = Set(MsgLevel, _WARNINGS_ONLY_)
    Sort(_DESCENDING_)
    Set(MsgLevel, old_MsgLevel)
    PopBlock()
  endif

  /*
    Step 4

    Summary: Try placing new text at the status' previous display location.

    For all statuses that are "to be updated"
    and have a previous display position
    and are "being displayed":
      If the new text fits the remembered length,
      then
        overwrite the displayed text right-aligned,
      else
        if the new text will fit by expanding it to the left,
        then
          do so overwriting the displayed text,
        otherwise
          clear the old text from the screen,
          forget the previous position,
          and remain "to be updated".
  */
  BegFile()
  repeat
    get_status_properties(status_id, callback, being_displayed, to_be_updated,
                          x_pos, y_pos, len, text, new_text)
    if  to_be_updated
    and being_displayed
    and len > 0
      if Length(new_text) == len
        screen_chars = Format(new_text:len)
        screen_attrs = Format('':len:status_attr_chr)
        PutStrAttrXY(x_pos, y_pos, screen_chars, screen_attrs)
        to_be_updated = FALSE
        text          = new_text
        new_text      = ''
        set_status_properties(status_id, callback, being_displayed, to_be_updated,
                              x_pos, y_pos, len, text, new_text)
      elseif Length(new_text) < len
        reduction     = len - Length(new_text)
        screen_chars  = Format('':reduction)
        screen_attrs  = Format('':reduction:Chr(Query(TextAttr)))
        PutStrAttrXY(x_pos, y_pos, screen_chars, screen_attrs)
        len           = Length(new_text)
        x_pos = x_pos + reduction
        screen_chars  = Format(new_text:len)
        screen_attrs  = Format('':len:status_attr_chr)
        PutStrAttrXY(x_pos, y_pos, screen_chars, screen_attrs)
        to_be_updated = FALSE
        text          = new_text
        new_text      = ''
        set_status_properties(status_id, callback, being_displayed, to_be_updated,
                              x_pos, y_pos, len, text, new_text)
      else
        expansion = Length(new_text) - len
        GetStrAttrXY(x_pos - expansion, y_pos, screen_chars, screen_attrs, expansion)
        if screen_chars == Format('':expansion)
          x_pos         = x_pos - expansion
          len           = Length(new_text)
          screen_chars  = Format(new_text:len)
          screen_attrs  = Format('':len:status_attr_chr)
          PutStrAttrXY(x_pos, y_pos, screen_chars, screen_attrs)
          to_be_updated = FALSE
          text          = new_text
          new_text      = ''
          set_status_properties(status_id, callback, being_displayed, to_be_updated,
                                x_pos, y_pos, len, text, new_text)
        else
          screen_chars = Format('':len)
          screen_attrs = Format('':len:Chr(Query(TextAttr)))
          PutStrAttrXY(x_pos, y_pos, screen_chars, screen_attrs)
          being_displayed = FALSE
          x_pos            = 0
          y_pos            = 0
          len              = 0
          set_status_properties(status_id, callback, being_displayed, to_be_updated,
                                x_pos, y_pos, len, text, new_text)
        endif
      endif
    endif
  until not Down()

  /*
    Step 5

    Summary: Place remaining new text at a new location.

    For each status that is "to be updated":
      For each line of the current editing window:
        Determine the right-most position in which the new status text fits,
        and remember it and the line if it is more to the right
        than the previous remembered line and position.
      If no such position is found anywhere
      then skip the new status
      otherwise place the new status text at the found location.
      In both cases set the status to not to be updated.
  */
  BegFile()
  repeat
    get_status_properties(status_id, callback, being_displayed, to_be_updated,
                          x_pos, y_pos, len, text, new_text)
    if to_be_updated
      new_len     = Length(new_text)
      blank_chars = Format('':new_len)
      max_i       = 0
      max_i_y     = 0
      for y = border_top_y to border_bottom_y
        // Examine at most the rightmost 256 chars of the editing window.
        GetStrAttrXY(border_right_x - border_width + 1, y,
                     screen_chars, screen_attrs, border_width)
        place_found         = FALSE
        extra_separator_len = 0
        for i = border_width - new_len + 1 downto 1
          if  SubStr(screen_chars, i - extra_separator_len,
                     new_len + 2 * extra_separator_len) == blank_chars
            place_found = TRUE
            break
          endif
          extra_separator_len = 1
        endfor
        if place_found
          if i > max_i
            max_i   = i
            max_i_y = y
          endif
        endif
      endfor
      if max_i > 0
        x_pos = border_right_x - border_width + max_i
        y_pos = max_i_y
        len   = new_len
        PutStrAttrXY(x_pos, y_pos, new_text, Format('':new_len:status_attr_chr))
        being_displayed = TRUE
        to_be_updated   = FALSE
        text            = new_text
        new_text        = ''
        set_status_properties(status_id, callback, being_displayed, to_be_updated,
                              x_pos, y_pos, len, text, new_text)
      endif
    endif
  until not Down()
  GotoBufferId(org_id)
  UnBufferVideo()
end display_statuses

proc idle()
  // Time when all statuses are repositioned from scratch.
  if reposition_timer == 0
    reposition_timer = REPOSITION_TIME
    reset_statuses   = TRUE
  else
    reposition_timer = reposition_timer - 1
  endif

  // While anything changes the current file
  if FileChanged() <> last_filechanged
    // Temporarily suspend status reporting
    last_filechanged = FileChanged()
    response_timer   = RESPONSE_TIME
  else
    // Otherwise time when status updates are displayed.
    if response_timer == 0
      response_timer = RESPONSE_TIME
      add_input_queue_to_statuses()
      display_statuses()
    else
      response_timer = response_timer - 1
    endif
  endif
end idle

proc after_command()
  // While anything happens on the keyboard
  // temporarily suspend status reporting
  response_timer = RESPONSE_TIME
end after_command

proc after_getkey()
  // This proc manages possible callbacks.

  string  cursor_attr                  [1] = ''
  string  cursor_char                  [1] = ''
  integer key_in_screen_x                  = 0
  integer key_in_screen_y                  = 0
  integer key_in_window_x                  = 0
  integer key_in_window_y                  = 0
  integer org_id                           = 0
  integer status_being_displayed           = 0
  string  status_callback   [MAXSTRINGLEN] = ''
  string  status_id         [MAXSTRINGLEN] = ''
  integer status_len                       = 0
  string  status_new_text   [MAXSTRINGLEN] = ''
  string  status_text       [MAXSTRINGLEN] = ''
  integer status_to_be_updated             = 0
  integer status_x_pos                     = 0
  integer status_y_pos                     = 0
  string  their_macro_name  [MAXSTRINGLEN] = ''
  string  their_status_name [MAXSTRINGLEN] = ''
  integer window_in_screen_x1              = 0
  integer window_in_screen_y1              = 0

  if QueryEditState() == 0
    // First determine the key's screen position.
    // Note that that differs for keyboard and mouse keys!
    // If the key is a mouse key ...
    if Query(Key) == Query(MouseKey)
      // For a mouse key the screen position is determined by the mouse pointer.
      key_in_screen_x     = Query(MouseX)
      key_in_screen_y     = Query(MouseY)
    else
      // For a keyboard key the screen position is determined by the cursor.
      window_in_screen_x1 = Query(WindowX1)
      window_in_screen_y1 = Query(WindowY1)
      key_in_window_x     = CurrCol() - CurrXoffset()
      key_in_window_y     = CurrRow()
      key_in_screen_x     = window_in_screen_x1 + key_in_window_x - 1
      key_in_screen_y     = window_in_screen_y1 + key_in_window_y - 1
    endif
    // We want the colour attribute of the character at the cursor.
    GetStrAttrXY(key_in_screen_x, key_in_screen_y, cursor_char, cursor_attr, 1)
    // If that is our status colour
    if cursor_attr == status_attr_chr
      // For the displayed status at the cursor find the corresponding status
      // in the status buffer.
      org_id = GetBufferId()
      GotoBufferId(statuses_id)
      BegFile()
      repeat
        get_status_properties(status_id, status_callback,
                              status_being_displayed, status_to_be_updated,
                              status_x_pos, status_y_pos, status_len,
                              status_text, status_new_text)
        if   status_callback == 'cy'
        and  key_in_screen_y == status_y_pos
        and (key_in_screen_x in status_x_pos .. (status_x_pos + status_len - 1))
          their_macro_name  = GetToken(status_id, ':', 1)
          their_status_name = GetToken(status_id, ':', 2)
        endif
      until their_macro_name <> ''
         or not Down()
      GotoBufferId(org_id)
      if their_macro_name <> ''
        ExecMacro(their_macro_name + ' callback ' + my_macro_name + ' ' +
                  their_status_name + ' ' +
                  StrReplace(' ', KeyName(Query(Key)), '_', ''))
      endif
    endif
  endif
end after_getkey

proc WhenLoaded()
  integer org_id = GetBufferId()

  my_macro_name = SplitPath(CurrMacroFilename(), _NAME_)

  #ifdef LINUX
    // Because Status incessantly gets called by other macro's, an abort
    // of Status would appear to make it stuck in a loop of abort messages.
    // Status therefore needs this extra check against that.
    abort = GetGlobalInt(my_macro_name + ':Abort')

    if  not abort
    and compare_versions(VersionStr(), '4.41.35') == -1
      Warn('ERROR: In Linux the Status extension needs at least TSE v4.41.35.')
      PurgeMacro(my_macro_name)
      abort = TRUE
      SetGlobalInt(my_macro_name + ':Abort', TRUE)
    endif
  #endif

  if not abort
    SetGlobalStr(my_macro_name + ':Version', MY_MACRO_VERSION)
    input_queue_id   = CreateTempBuffer()
    ChangeCurrFilename(my_macro_name + ':input_queue',
                       _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
    statuses_id    = CreateTempBuffer()
    ChangeCurrFilename(my_macro_name + ':statuses',
                       _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
    GotoBufferId(org_id)
    response_time = Val(GetProfileStr(my_macro_name + ':config', 'response_time', Str(RESPONSE_TIME_DEFAULT ), ".\unicode.ini" ) )
    response_time = iif(response_time > 0,
                        response_time,
                        RESPONSE_TIME_DEFAULT)
    reposition_time = Val(GetProfileStr(my_macro_name + ':config', 'reposition_time', Str(REPOSITION_TIME_DEFAULT), ".\unicode.ini" ))
    reposition_time = iif(reposition_time > 0,
                          reposition_time,
                          REPOSITION_TIME_DEFAULT)
    status_attr = Val(GetProfileStr(my_macro_name + ':config', 'status_color', '00', ".\unicode.ini" ), 16)
    if not is_valid_status_color(status_attr)
      status_attr = Query(MenuTextAttr)
      while not is_valid_status_color(status_attr)
        Warn('"', get_color_name(status_attr),
             '" is not a valid status text colour.',
             Chr(13),
             Chr(13),
             'The status text colour must differ from all other text colours,',
             Chr(13),
             'and its foreground and background colours must differ.',
             Chr(13),
             Chr(13),
             'Pick a valid status text colour ...')
        status_attr = select_color(status_attr,
                                   'Pick a valid status text colour')
      endwhile
      WriteProfileStr(my_macro_name + ':config', 'status_color', Str(status_attr, 16 ), ".\unicode.ini" )
    endif
    status_attr_chr = Chr(status_attr)
    Hook(_IDLE_          , idle         )
    Hook(_AFTER_COMMAND_ , after_command)
    Hook(_AFTER_GETKEY_  , after_getkey)
  endif
end WhenLoaded

proc WhenPurged()
  AbandonFile(input_queue_id)
  AbandonFile(statuses_id)
end WhenPurged

proc show_help()
  string  full_macro_source_name [MAXSTRINGLEN] = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_|_NAME_) + '.s'
  string  help_file_name         [MAXSTRINGLEN] = '*** ' + my_macro_name + ' Help ***'
  integer hlp_id                                = GetBufferId(help_file_name)
  integer org_id                                = GetBufferId()
  integer tmp_id                                = 0
  if hlp_id
    GotoBufferId(hlp_id)
  else
    tmp_id = CreateTempBuffer()
    if LoadBuffer(full_macro_source_name)
      // Separate characters, otherwise my SynCase macro gets confused.
      if lFind('/' + '*', 'g')
        PushBlock()
        UnMarkBlock()
        Right(2)
        MarkChar()
        if not lFind('*' + '/', '')
          EndFile()
        endif
        MarkChar()
        Copy()
        CreateTempBuffer()
        Paste()
        UnMarkBlock()
        PopBlock()
        BegFile()
        ChangeCurrFilename(help_file_name,
                           _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
        BufferType(_NORMAL_)
        FileChanged(FALSE)
        BrowseMode(TRUE)
      else
        GotoBufferId(org_id)
        Warn('File "', full_macro_source_name, '" has no multi-line comment block.')
      endif
    else
      GotoBufferId(org_id)
      Warn('File "', full_macro_source_name, '" not found.')
    endif
    AbandonFile(tmp_id)
  endif
end show_help

string proc config_get(string item_name)
  string item_value[MAXSTRINGLEN] = ''
  case item_name
    when 'response'
      item_value = Format(response_time:10)
    when 'reposition'
      item_value = Format(reposition_time:10)
    when 'color'
      item_value = Format(get_color_name(status_attr):33)
  endcase
  return(item_value)
end config_get

proc config_set(string item_name)
  integer first_try              = TRUE
  string  item_string_value [10] = ''
  integer item_integer_value     = 0
  case item_name
    when 'response'
      item_string_value = Str(response_time)
      if Ask('Enter a new response time (1/18ths of a second):',
             item_string_value)
        item_integer_value = Val(item_string_value)
        if (item_integer_value in 1 .. MAXINT)
          response_time = item_integer_value
          WriteProfileStr(my_macro_name + ':config', 'response_time', Str(response_time), ".\unicode.ini" )
        else
          Warn('"', item_string_value, '" is an illegal response time.')
        endif
      endif
    when 'reposition'
      item_string_value = Str(reposition_time)
      if Ask('Enter a new reposition time (1/18ths of a second):',
             item_string_value)
        item_integer_value = Val(item_string_value)
        if (item_integer_value in 1 .. MAXINT)
          reposition_time = item_integer_value
          WriteProfileStr(my_macro_name + ':config', 'reposition_time', Str(reposition_time), ".\unicode.ini" )
        else
          Warn('"', item_string_value, '" is an illegal reposition time.')
        endif
      endif
    when 'color'
      repeat
        if first_try
          first_try = FALSE
        else
          Warn('"', get_color_name(status_attr),
               '" is not a valid status text colour.',
               Chr(13),
               Chr(13),
               'The status text colour must differ from all other text colours,',
               Chr(13),
               'and its foreground and background colours must differ.',
               Chr(13),
               Chr(13),
               'Pick a valid status text colour ...')
        endif
        status_attr = select_color(status_attr,
                                   'Pick a valid status text colour')
      until is_valid_status_color(status_attr)
      WriteProfileStr(my_macro_name + ':config', 'status_color', Format(status_attr:2:'0':16), ".\unicode.ini" )
      status_attr_chr  = Chr(status_attr)
      restart_the_menu = TRUE
  endcase
end config_set

menu config_menu()
  title       = 'Status Configuration'
  x           = 5
  y           = 5
  history

  '&Escape', NoOp(), _MF_CLOSE_ALL_BEFORE_, 'Exit this menu'
  '&Help', show_help(), _MF_CLOSE_ALL_BEFORE_,
    'Show all comments from the macro source, including technical notes.'
  '',, _MF_DIVIDE_
  '&Response   time  (1/18ths of a second)' [config_get('response'):10],
    config_set('response'), _MF_DONT_CLOSE_,
    'Low/high for fast/slow status updates costing more/less CPU time.'
  'Re&position time  (1/18ths of a second)' [config_get('reposition'):10],
    config_set('reposition'), _MF_DONT_CLOSE_,
    'Lower/higher displays statuses a shorter/longer time at the same position.'
  '',, _MF_DIVIDE_
  '&Status text colour' [config_get('color'):33], config_set('color'),
    _MF_CLOSE_ALL_BEFORE_,
    'Status text colour must be readable and differ from all other text colours.'
end config_menu

proc Main()
  if not abort
    case Query(MacroCmdLine)
      when ''
        repeat
          restart_the_menu = FALSE
          config_menu()
        until not restart_the_menu
      when 'ConfigureStatusColor'
        config_set('color')
      otherwise
        macro_cmd_line_2_input_queue()
    endcase
  endif
end Main

