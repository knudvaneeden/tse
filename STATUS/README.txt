===

1. -To install

     1. -Take the file status_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstallstatus.bat

     4. -That will create a new file status_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          status.mac

2. -The .ini file is the local file 'status.ini'
    (thus not using tse.ini)

===

/*
  Macro             Status
  Author            Carlo.Hogeveen@xs4all.nl
  Compatibility     Windows TSE PRo 4.0 upwards
                    Linux TSE Beta v4.41.35 upwards
  Version           1.2 - 30 Apr 2020


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
