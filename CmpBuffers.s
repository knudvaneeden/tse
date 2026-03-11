/*
  Tool            CmpBuffers
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   TSE v4.50rc15 upwards, all variants
  Version         v1.2.2   11 Mar 2026


  This tool lets you select and compare two buffers.

  It works by first determining consecutive lines that match, and by then
  marking and hiliting each intervening block of lines as a related difference.

  Its browser shows the buffers side by side and has keys to navigate the
  text and the differences.

  "Unmodified" keys navigate text simulteneously in both buffers, while with
  the <Ctrl> modifier the same keys only navigate text in the current buffer.


  CmpBuffer's main advantages over CmpFiles:
  - It lets you configure its browser keys.
  - It never aborts on a "resync" error.
  - It has more ways to select the two buffers,
    including one that lets you instantly compare a buffer to its disk file.
  - It lets you save its configuration settings,
    of which it has many more than CmpFiles.
  - It not just marks the currently selected difference,
    but also hilites other differences that happen to be on the screen.
  - You can navigate differences in both directions.
  - Navigating differences also goes to the beginning and end of their blocks.
  - It can also treat empty lines as ignorable whitespace.
  - It compares the whole buffers instead of just chunks of it,
    resulting in more consistently recognized differences.
  - It lets the user decide when to stop a too long running comparison.
    In practice those are rare.
  - When stopped prematurely, it stops gracefully: Compared lines are shown
    correctly and not yet compared lines are shown as one big difference.

  CmpBuffer's main disadvantages over CmpFiles:
  - It does not let you replace a difference in one buffer by its counterpart
    from the other buffer.
  - It does not let you zoom text.
  - It compares more slowly.


  INSTALLATION

    Copy this file to TSE's "mac" directory and compile it there,
    for example by opening it there in TSE and applying the Macro Compile menu.

    CmpBuffers can then be started as a macro,
    for example by entering "CmpBuffers" in the Macro Execute menu.

    You can add CmpBuffers to TSE's Potpourri menu.

    You can create a key in your .ui file to start CmpBuffers' menu,
    for example:
      <Ctrl 7>  ExecMacro("CmpBuffers")

    You can create a key in your .ui file to bypass the menu
    and to immediately compare the current buffer to its disk file
    with the case-insensitive parameter "CompareToDiskFile".
    For example:
      <Ctrl 9>  ExecMacro("CmpBuffers CompareToDiskFile")

    You can create a key in your .ui file to bypass the menu
    and to immediately compare the only two open buffers
    with the case-insensitive parameter "CompareTheOnly2buffers".
    If not exactly two buffers are open, then you will get warning instead.
    For example:
      <Ctrl 5>  ExecMacro("CmpBuffers CompareTheOnly2buffers")

    You can compare two disk files directly by passing both fully-qualified
    file paths separated by a space.  Both files must exist on disk.
    The split between the two paths is found by scanning from the right for
    the last space after which the remainder is an existing file.
    This means paths with spaces are supported as long as the second path
    contains at least one space-free prefix that identifies it uniquely.
    Paths without spaces always work unambiguously.
    For example, called from a macro:
      ExecMacro('CmpBuffers c:\temp\ddd1.txt c:\temp\ddd2.txt')
    Or bound to a key in your .ui file:
      <Ctrl 8>  ExecMacro('CmpBuffers c:\temp\old.txt c:\temp\new.txt')


  BROWSER CONFIGURATION

    You can configure CmpBuffer's browser with its configuration menu,
    which can be selected from the start-up menu and from the browser itself.

    The configuration menu's documentation can be accessed in two ways:
    - Further down in this document in its third TSE multi-line comment.
      Browse down or search for "ConfigurationMenu".
    - From the configuration menu.


  BROWSER
    The tool works by letting the user select two buffers.
    Between these buffers it first determines consecutive lines that match,
    and then marks or hilites each block of intervening lines as a difference.

    The browser shows the buffers side by side and has keys to navigate to the
    differences.

    The browser looks just like TSE with the screen split in two windows.
    In fact, you may sometimes wonder whether you are using CmpBuffer's browser
    or TSE's edit window.
    The solution: Look at the help line!

    The browser uses keys that are assigned to named actions.

    Documentation for key usage and named actions can be accessed in two ways:
    - Further down in this document in its second TSE multi-line comment.
      Browse down or search for "ActionList" or "KeyList".
    - By pressing the <F1> key while in the key definition screen.


  TODO
    MUST
    SHOULD
    COULD
    - Replace a difference in one buffer with its counterpart from the other.
    - Windows GUI only: "Zoom out" in the browser using the font size.
      Make it configurable as a default at the browser's start-up.
    WONT
    - Add an option to show not just the current difference at the same height,
      but all differences that happen to be on the screen.
      A user expressed they find the latter to be clearer, but I find that the
      insertion of empty lines to achieve this would take away context/content
      from the current difference.
    - Whitespace-insensitivity currently applies to one or more whitespaces.
      This could be extended to zero or more whitespaces between two non-words
      and between a word and a non-word.
      It would be a great feature to have, but I do not need it enough to bug
      Semware for it or to write my own slow version of CompareLines().
    - Whitespace-insensitivity currently applies the same everywhere.
      It would be a great feature if it could optionally not apply inside
      strings, but again, I do not need it enough to bug Semware for it or to
      write my own slow version of CompareLines().
    - Make the comparison faster.
      CmpBuffers runs a comparison of both whole buffers before starting the
      browser and then browses the found list of differences.
      Almost always CmpBuffers' comparison is fast enough for the compared
      files, and often so fast that it is not noticeable it actually uses a
      slow algorithm.
      I like the slow algorithm's advantage that it works more consistently,
      so I will not replace it.
      A a real-life example of a slow comparison was comparing version 15.1
      and 16 of Unicode's NamesList.txt file, which took 5 minutes!
        https://www.unicode.org/Public/15.1.0/ucd/NamesList.txt
        https://www.unicode.org/Public/16.0.0/ucd/NamesList.txt
    - An Export/ViewFinds function that lists the differences.
      It would have to be directional: A list of what line-wise deletions and
      additions to a source buffer would result in the target buffer.
      I doubt the usefulness of listing differences without their context,
      but a user mentioned it, noting the problematic output format too.
      It would be easy to implement something, but the goal is too vague.
      An agreed-upon export format might help.
      I lean towards not doing this one.


  HISTORY

  v0.0.0.1   DEVELOPMENT   11 Aug 2024
    Initial release.
    Produces an output buffer containing line number references.

  v0.0.0.2   DEVELOPMENT   20 Aug 2024
    Now uses a browser to compare differences.
    Documented a long and incomplete list of bugs and missing functionalities.

  v0.0.0.3   DEVELOPMENT   21 Aug 2024
    Fixed: "Go to previous difference" now works.

  v0.0.0.4   DEVELOPMENT   21 Aug 2024 (2)
    Fixed: "Go to next/previous difference" needed to be pressed twice when
    both compared blocks had at most 1 line and there therefore was no
    difference between the beginning and end of blocks to go to.

  v0.0.0.5   DEVELOPMENT   23 Aug 2024
    Undocumented a compare bug that was not reproduceable.
    Added a lot of basic navigation keys.
    Navigation revealed an occasionally occurring coloring bug.
    Added a pretty exit pop-up.

  v0.0.0.6   DEVELOPMENT   24 Aug 2024
    Replaced the sequence of start-up questions with one start-up menu.
    Replaced persistent warnings with temporary pop-ups.

  v0.0.0.7   DEVELOPMENT   4 Sep 2024
    Fixed: Sometimes one window was not immediately recolored.
    Changed the default number of consecutive lines that need to match
    from 1 to 2 in order to get better matches and differences.

  v0.0.0.8   DEVELOPMENT   5 Sep 2024
  (*) When keys are mentioned, the same applies to their alternative keys.
  - Added keys (*):
      <PgUp/Dn>             goes page up/down for both buffers.
      <Ctrl PgUp/Dn>        goes page up/down for the current buffer.
  - Added a double function to these existing keys (*):
      <Home/End>      once  goes to begin/end of both lines.
      <Ctrl Home/End> once  goes to begin/end of the current line.
      <Home/End>      twice goes to begin/end of both buffers.
      <Ctrl Home/end> twice goes to begin/end of the current buffer.
  - When CmpBuffers is started, it no longer goes to the top of files.
    This means finding differences starts from the current line in the current
    window.
  - Improved finding the next/previous difference if the current line in the
    current window is not at the beginning or end of a block of differences.

  v0.0.0.9   DEVELOPMENT   6 Sep 2024
  - Added <Alt CursorUp/Down> to go to the first/last difference.
  - Added a help line.
  - Added a help screen.

  v0.0.0.10   DEVELOPMENT   7 Sep 2024
  - Extended the help line with new browser keys, that when used will tell you
    they are not implemented yet:
      K         Key list
      I         Toggle IgnoreCase
      F or W    Toggle FilterWhitespace
      1-9       Blocks of consecutive matching lines must have at least N lines.
      F10 or M  Menu

  v0.0.0.11   DEVELOPMENT   7 Sep 2024 (2)
  - At start-up show the number of differences found.

  v0.0.0.12   DEVELOPMENT   8 Sep 2024
  - Implemented the Key List, both from the start-up menu and the browser.

  v0.0.0.13   DEVELOPMENT   9 Sep 2024
  - In the browser you can now toggle Ignore Case and Filter Whitespace ON/OFF.

  v0.0.0.14   DEVELOPMENT   9 Sep 2024 (2)
  - Added browser keys <1> - <9> to change the minimum number of lines required
    to find a block of consecutive matching lines.

  v0.0.0.15   DEVELOPMENT   10 Sep 2024
  - Updated the key list. Mainly its documentation.
  - Planned the design of the configuration menu.

  v0.0.0.16   DEVELOPMENT   11 Sep 2024
  - Changed the browser key for the configuration menu from <M> to <C>.
  - Added the first configuration menu options:
    - Filter whitespace.
    - Ignore case.

  v0.0.0.17   DEVELOPMENT   11 Sep 2024 (2)
  - Added more configuration menu options:
    - Minimum matching lines.
    - Split window vertically or horizontally.
    - Show a message for           ... seconds.
    - Start showing progress after ... seconds.
    - Stop  compare after          ... seconds.
  - Restart the compare and/or the browser if the configuration menu changed a
    relevant setting.

  v0.0.0.18   DEVELOPMENT   12 Sep 2024
  - Divided the start-up      menu into meaningful sections.
  - Divided the configuration menu into meaningful sections.
  - Added four color configuration options.

  v0.0.0.19   DEVELOPMENT   13 Sep 2024
  - Added a help screen in and about the configuration menu.

  v0.0.0.20   DEVELOPMENT   13 Sep 2024 (2)
  - Improved the documentation, especially the INSTALLATION section.
  - Added the option to bypass the menu and immediately start comparing the
    current buffer to its disk file.

  v0.0.0.21   DEVELOPMENT   13 Sep 2024 (3)
  - When there are 3 or more buffers, then it is now possible to select one of
    them to compare to the current buffer.

  v0.1        BETA          15 Sep 2024
  - Finding the first or last difference AGAIN now gives a message.
    It used to do nothing, which was correct but confusing.
  - There is now a pop-up message "Comparing ..." during a comparison.
    A comparison is often so fast that the message is not visible, but for a
    bit longer comparisons it helps avoid confusion about the browser's state.
  - Because it is less needed because of the previous point, the default
    for "Start progress after" has been lengthened to 5 seconds. It was 2.
  - In the start-up menu the order of options was slightly changed: The two
    disk-options are placed together and the two buffer-options are too.
  - Improved the documentation.

  v0.2        BETA          22 Sep 2024
  - Improved the documentation a bit more.
  - Fixed coloring differences in the wrong window after toggling the window
    split type.

  v1   22 Sep 2024
  - All know errors are fixed.
  - Did not get new comments from users.
  - Did a thorough test of found differences for a difficult file.

  v1.0.0.1   DEVELOPMENT   30 Sep 2024
  - Made most keys configurable by introducing actions to assign them to.
    Some browser keys are immutable, either because they are in the immutable
    helpline or because they are vital to keep the browser working.
  - Fixed the settings menu closing too early after using "Configuration
    Help" when the settings menu was opened from the start-up menu.

  v1.0.0.2   DEVELOPMENT   1 Oct 2024
  - Fixed a problem by making the single-letter keys case-insensitive.

  v1.0.0.3   DEVELOPMENT   2 Oct 2024
  - Fixed that the deletion of keys was not saved permanently.
  - Fixed that non-default keys were deleted when settings were saved.
  - Cannot reproduce a problem with the sizing of pop-up messages.

  v1.0.0.4   DEVELOPMENT   7 Oct 2024
  - Added a (too?) minimal help screen to the "Actions with their keys" screen.
  - Updated the documentation to reflect that keys are now assigned to named
    actions.
  - Fixed: Resetting all keys did not delete any extra keys that the user had
    configured and did not save the newly reset keys.

  v1.0.0.5   BETA   8 Oct 2024
  - Fixed inconvenient cursor positioning when vertical scrolling at the start
    or end of buffers.

  v1.1   10 Oct 2024
  - Summary: It allows you to configure your own browser keys.
  - Publicly announced this release after many development versions and a beta.
  - Contains last minute improvements to the documentation for keys.

  v1.1.1   14 Oct 2024   (not released)
  - Documented 3 WONT points in the TODO list.

  v1.2     14 Apr 2025
  - Moved the menu option "Compare the only 2 buffers" to the top.
  - Macro executing "CmpBuffers CompareTheOnly2buffers" will bypass the menu.

  v1.2.1   15 Apr 2025
  - Added a macro start-up check for unknown parameters.

  v1.2.2   11 Mar 2026
  - Added two-filename command-line support: passing two space-separated disk
    file paths directly (e.g. ExecMacro('CmpBuffers file1.txt file2.txt'))
    loads and compares both files without them needing to be open in TSE.
    The split point is found by scanning from the right for the last space
    after which the remainder is an existing file.
    Both temporary buffers are cleaned up on exit.
  - Added intra-line word/character diff highlighting: when two diff blocks
    have an equal number of changed lines, individual character positions that
    differ between the paired lines are highlighted in a distinct color
    (default: Bright Yellow on Red), similar to Beyond Compare's word diff.
    Configurable via the Configure menu as "Intra-line changed words".
    Set to color 0 to disable.

*/





/*                                              (Keywords: ActionList, KeyList)
  Keys are assigned to named actions.

  First the key properties are described, and further down the named actions.

  Most keys are configurable, meaning you can assign them to actions and delete
  them from actions.

  Configured keys are effective immediately, and saved when the tool is exited.
  There is no need or way to save changed key assignments explicitly.

  A few keys are immutable.

  Immutable Keys
    <Escape> is an immutable key: A user cannot delete or reassign it,
    and then accidentilly no longer be able to exit the browser.

    Keys with a name containing "," or ";" are immutable,
    because the tool internally uses "," and ";" to separate key names.

    The browser's helpline keys are immutable.
    If they were changeable, then the sum of the lengths of the keynames could
    exceed the length of the helpline. That is hereby avoided.

    Note that an action having an immutable key does not block you from also
    assigning it a configurable key.

  Configurable keys
    Selecting a named action shows a list of its assigned keys.

    With the <Ins> and <Del> keys you can add and remove configurable keys
    to and from the action's key list.

    Adding a key with <Ins> prompts you to press the new key.

    Adding a key to one action that is already assigned to another action
    will show an extra confirmation prompt, showing which action the key will
    be removed from and which action the key will be assigned to.

  Default keys
    The actions' default keys were primarily chosen for their ability to
    provide a consistent look and feel within CmpBuffers itself.

    One of those consistencies is, that default keys without the <Ctrl>
    modifier will act on both windows, while keys with the <Ctrl> modifier
    will only act on the current window.

    Key-compatibility of CmpBuffers with CmpFiles was only a secondary
    consideration, and has only been added were it did not conflict with the
    primary goal.

  Keys are case-insensitive.
    For example, you cannot assign the keys <a> and <A> to different actions.
    In the browser they are the same key.

  Default all keys are "Grey"-insensitive.
    For example, default <GreyCursorRight> and <CursorRight> are assigned to
    the same action.
    If the operation system and the TSE setting "Equate Enhanced Keyboard"
    support it, then you can configure them to be assigned to different
    actions.
    To research "Grey" for your specific context use the ShowKey tool
    in TSE's Potpourri menu.

  Linux key deficiencies and alternatives:
    In general Linux distributions might not support all key combinations that
    are available in Windows, and can even interpret Windows keys as
    different Linux keys.

    This especially affects Linux server distributions!

    As a specific example, not all Linux distributions support key-modifiers
    (Ctrl, Alt, Shift) for all navigation keys (up, down, left, right, home,
    end, pgup, pgdown, ...).

    Therefore default the first letters of navigation key names (u, d, l, r,
    h, e) can be used as alternatives, optionally with their modifiers.



  ---------- ACTIONS WITH IMMUTABLE KEYS -------------
  ACTION NAME               ACTION DESCRIPTION
  Escape                    Exit anything.
  Show main help screen     Shows general help about this tool.
  Show keys help screen     Shows this list of actions with their keys.
  Toggle ignore case        Are upper- and lower-case letters a difference?
  Toggle filter whitespace  Are any >= 2 whitespace characters a difference?
  Set minimum match lines   At least N matching lines are needed for a match.
  Configure settings        Configure non-key settings.

  ---------- ACTIONS WITH CONFIGURABLE KEYS ----------
  ACTION NAME               ACTION DESCRIPTION
  Toggle selected window    Make the other window the current one.
  Toggle window split type  Vertically or horizontally split windows?
  Find first difference     The tool first finds matches,
  Find last difference      and administrates and shows
  Find next difference      everything in between the matches
  Find previous difference  as a difference.
  Move cursors to begin     Both windows: Go to beginning of line or buffer.
  Move cursors to end       Both windows: Go to end of line or buffer.
  Move cursors page up      Both windows: Move a page up.
  Move cursors page down    Both windows: Move a page down.
  Move cursors up           Both windows: Move the cursor one line up.
  Move cursors down         Both windows: Move the cursor one line down.
  Move cursors left         Both windows: Move the cursor left one character.
  Move cursors right        Both windows: Move the cursor right one character.
  Move cursor to begin      Current window: Go to beginning of line or buffer.
  Move cursor to end        Current window: Go to end of line or buffer.
  Move cursor page up       Current window: Move a page up.
  Move cursor page down     Current window: Move a page down.
  Move cursor up            Current window: Move the cursor one line up.
  Move cursor down          Current window: Move the cursor one line down.
  Move cursor left          Current window: Move the cursor left one character.
  Move cursor right         Current window: Move the cursor right one character.
*/





/*                                                 (Keyword: ConfigurationMenu)
  Configuration Help
    You are reading it.

  Message Duration (seconds)
    Where relevant the tool pops up a message that disappears after a few
    seconds.
    Here you can configure how many seconds.
    The default is 2 seconds.

  Split Window
    The differences between two buffers are shown in two windows (one for each
    buffer) by splitting the main TSE screen vertically or horizontally.
    Here you can configure that split type.
    The default is "Vertically".

  Color for Selected Difference
    If you select a difference by using a navigation key that finds one,
    then the found difference is shown in this color.
    Its default color is that of TSE's "Text - Blocked" configuration option.

  with syntax hiliting
    If "Yes", the use the background color of the above TSE color,
    and use the foreground/letter color of TSE's syntax hiliting.
    Its default value is that of TSE's "Syntax Hilite inside Blocks"
    configuration option.

    Beware that setting this option to "Yes" will look bad if your syntax
    hiliting's foreground/letter colors do not contrast well with the previous
    option's background color.
    A solution that lets you use syntax hiliting is to change the previous
    option's background color.

  Other (Color for NOT-Selected Differences)
    If a not-selected difference happens to occur in the browser screen,
    then the difference is shown in this color.
    Its default color is that of TSE's "Text - Highlighted" configuration
    option.

  with syntax hiliting
    If "Yes", the use the background color of the above TSE color,
    and use the foreground/letter color of TSE's syntax hiliting.
    Its default value is "No", because TSE does not have a comparable option.

    Beware that setting this option to "Yes" will look bad if your syntax
    hiliting's foreground/letter colors do not contrast well with the previous
    option's background color.
    A solution that lets you use syntax hiliting is to change the previous
    option's background color.

  Intra-line changed words
    When two diff blocks have an equal number of changed lines, the lines are
    paired 1:1 and individual character positions that differ between the pair
    are highlighted in this color.
    This gives a Beyond-Compare-style intra-line word/character highlight.
    Its default color is Bright Yellow on Red.
    Set it to color 0 (Black on Black) to disable intra-line highlighting.

  Filter Whitespace
    When this option is On and a comparison is run, any positive number of
    consecutive whitespace characters will match any other positive number of
    consecutive whitespace characters.
    Whitespace characters are space, tab, and newline.
    For example, when On, " " and "  " are not found as a difference,
    and neither are empty lines.

  Ignore Case
    When this option is On and a comparison is run, upper case letters are
    considered equal to their lower case counterparts.
    For example, when On, "max" and "Max" are not found as a difference.

  Minimum Matching Lines
    The tool works, by first determining all matches that the two buffers have
    in common, and from that determining their differences.
    A "match" is a consecutive block of at least "Minimum Matching Lines".
    If "Minimum Matching Lines" is 1, then a comparison will usually find a lot
    of irrelevant matches.
    Therefore the default is 2.

  Start &progress after (seconds)
    For a longer running comparison this option determines after how many
    seconds the comparison should start showing its progress.
    The default is 2 seconds.

    Note: In practice longer running comparisons are rare.

  Stop compare after (seconds)
    For a longer running comparison this option determines after how many
    seconds the comparison should stop.
    The default is 86400 seconds, which is 1 day.

    Alternatively a user can stop a running comparison by pressing <Escape>.

    In both cases the tool will present the not-yet-compared lines as one big
    difference.

  Save Settings, Exit Configuration
    Without this option, changes you make to any of the above settings are only
    effective until the tool is stopped.
    After using this option, changes you made to any of the above settings are
    will be in effect again the next time tool is started, including in new TSE
    sessions.
*/





/*
  T E C H N I C A L   B A C K G R O U N D   I N F O

  CONFIGURABLE KEYS - DESIGN

  Context:
    A key can be assigned to at most one action.
    An action can have any number of keys assigned to it.
    In TSE a key is identified by a 2-byte key code.
    TSE's theoretical maximum number of keys is 65536.
    Checking 65536 keys in memory takes only 0.03 seconds.

  Design:
    The macro always stores keys and actions by their names.
    The macro has a Datadef of the macro's actions and their default keys.
    The macro has a list of not-configurable keys.
      These are the keys in the help line, because the help line is fixed and
      continuously shown to the user, and the <Escape> key, so that a user
      cannot configure the tool to become unescapable.
    The macro has a not-configurable action "Set minimum matching lines",
    because the action does not make sense with other keys than <0> thru <9>.
    The macro optionally has a profile section with key-action pairs to when
    allowed overrule the default settings.

    At start-up the macro:
    - If there is a profile section for keys:
      - Will read the profile's keys and actions as buffer strings in memory.
      Else:
      - Will store the default keys for actions as buffer strings in memory.
        with the key as id and the action as value.
    - Will always add the mandatory keys and actions as buffer strings in
      memory.
    All these sources use the key as id and the action as value.

    At browse-time the macro:
    - Will convert keys to actions using the buffer strings.
    - Perform the actions.

    During key configuration the macro:
    - Will add, update and delete the buffer strings.
      - Via a user-friendly interface of two togglable shrink-as-you-type
        lists:
        - Actions with their keys.
          Selecting an action will give a sublist of keys in which keys can be
          added and deleted for the selected action.
        - Keys with their actions.
          You can delete a key, or add a key and select its action.
        Exiting the lists:
        - Deletes the whole profile section.
        - Writes all buffer strings to the profile section.
        The lists should have an option to restore the default settings.



  Totally aside:
    This made me think about a TSE key manager.
    It is not possible to simply extend the above design to a TSE key manager.
    That would have at least the following problems:
    - It cannot reference code in the .ui file.
    - The menus in the .ui file would not reflect the new key changes.
    There might be two possible "solutions":
    - Ignore the .ui file and accept a TSE key manager with deficiencies.
    - Design a solution that would include and compile an automatically copied
      and edited version of the .ui file.
      This would have risks of yet unknown severity:
      - A user .ui file that is not recognizable enough.
      - A .ui file that gets too big.
      - Not enough added value: Nobody cares for a key manager.
      It would be a lot more work, which if it has too little added value I
      would not care for.
    So my questions are, in what ways could a TSE key manager add value
    to TSE's existing solution, and would that be significant enough?
    Without going intio further details, I lean towards a "No".
*/





// Start of copy of CmpBuf.inc ...



/*
  Helper include file   CmpBuf.inc
  Author                Carlo Hogeveen
  Website               eCarlo.nl/tse
  Compatibility         TSE v4.50rc15 upwards, all variants
  Version               0.1   BETA   10 Aug 2024


  SUMMARY

  This is a helper macro for macro programmers.

  Given two input buffer ids and one output buffer id, it sequentially finds
  the closest blocks of lines that the input buffers have in common, and from
  that it derives the interjacent blocks of lines that differ between the two
  input buffers.

  In the output buffer it reports the line numbers of the alternating blocks of
  equal and different lines.

  It has options for ignoring case and whitespace differences, for requiring a
  number of lines to be equal, and for limiting the run-time.


  CALLING METHODS

  This macro is intended to be used as a helper macro by a "parent" macro.
  Such a parent macro needs to do any user interaction for input
  and needs to produce any required useful user-friendly output.
  The parent macro can supply options.

  There are 3 methods by which a parent macro can call this helper macro:

  Method 1
    The content of the .inc file is copied into the parent macro.
    This is the method that I prefer, because I distribute macros.
    Its huge advantage is, that the end-user does not have to deal with version
    management and dependencies between parent macros and helper macro.
    I.e. each parent macro is inextricably distributed with the version of the
    helper macro it was created for and tested with.
    A usually not applicable disadvantage is, that a parent macro can get too
    big if the helper macro is copied into it.

  Method 2
    The parent macro uses the include statement.
    For example:
      #include ['CmpBuf.inc']
    This has the advantage of being able to maintain the parent and helper
    macro separately while they can still be tightly integrated.
    A usually not applicable disadvantage is, that the parent macro would get
    too big if it would include the helper macro.
    A significant disadvantage is that it creates a dependency that cannot be
    maintained for distributed macros. After updating the helper macro its
    programmer must and can immediately retest all parent macros on their own
    machine. But when distributing the new helper macro (and possibly some new
    parent macros) the programmer has no control over which (other) parent
    macros the end-user installs or already has installed.

  Method 3
    The parent macro executes the helper macro.
    For example:
      The CmpBuf.s file is compiled to a CmpBuf.mac file.
      The parent macro executes the compiled .mac file:
        ExecMacro('CmpBuf 11 12 13 options=fi')
    A usually not applicable advantage is, that this method avoids the parent
    macro becoming too big if the helper macro were to be copied into it.
    It has the advantage of being able to maintain the parent and helper
    macro separately.
    It has the same significant dependency disadvantage as method 2, with its
    effect postponed until run-time.


  INPUT & OUTPUT

  Input and output parameters are each passed as one space-separated string.

  Example call for methods 1 and 2:
    <string-out> = CmpBuf(<string-in>)

  Example call for method 3:
    ExecMacro('CmpBuf <string-in>')
    <string-out> = Query(MacroCmdLine)


  INPUT

  The user can press <Escape> to interrupt the comparison.

  Input parameters are case-insensitive.

  <String-in> is a space-separated string of these fields:
    <id1>               Mandatory id of the 1st input buffer.
    <id2>               Mandatory id of the 2nd input buffer.
    <id3>               Mandatory id of the output buffer.
                        All 3 buffers must exist and not be in binary mode.
                        The output buffer does not need to be initialized,
                        and can be reused as needed.
    [options=<options>] Optional, where <options> can be any or none of the
                        letters "f" and "i", and/or a number.
                        Default: "".
    [start=<seconds>]   When to start progress indicator.
                        Default: 1.
    [stop=<seconds>]    When to stop comparing.
                        Default: 86400.  (86400 == a day.)

  These compare options are supported: "f", "i", and a number.
  "i" stands for "ignore-case".
  "f" stands for "filter-spaces".
  A number (default 1) indicates the number of lines that must be equal.

  Filter-spaces means that consecutive whitespace characters are compared as if
  they were one space.
  Here a whitespace character means a space, tab or newline character.
  For example, with the "f" option:
    "a typical" versus "atypical"     will     be found as a change.
    "a typical" versus "a typical"    will not be found as a change.
    "a typical" versus "a  typical"   will not be found as a change.
    A difference in indentation       will not be found as a change.
    A different number of empty lines will not be found as a change.

  A number indicates the number of consecutive lines that must be equal
  for them to be found as a block of equal lines.

  As an exaggarated example, "options=fi42" will only find blocks that
  case-insensitively and disregarding whitespace and empty lines have
  at least 42 consecutive lines in common.


  OUTPUT

  <String-out> is a string of just this field:
    <result code>         0 Means there was an error.
                            Errors can be caused by incorrect parameters
                            or by providing a buffer that is in binary mode.
                            The contents of the output buffer are undefined.
                          1 Means no problems at all.
                          2 Means the comparison was stopped prematurely,
                            either by the user or by a supplied run-time limit.
                            In the output buffer the remaining uncompared parts
                            of the input buffers are each logged as one block of
                            different lines.

  For example, <string-out> can be "1", indicating there were no problems
  at all.

  If the result code is not "0", then the output buffer will contain lines
  indicating which blocks of lines are equal and unequal between the input
  buffers.
  Such an output buffer has lines that alternate between these two formats:
    = <buf1 line from> <buf1 line to> <buf2 line from> <buf2 line to>
    ! <buf1 line from> <buf1 line to> <buf2 line from> <buf2 line to>

  The output buffer's line numers are justified into columns, for example:
    =           1           5           1           5
    !           6           8           6          12
    =           9          11          13          15
    !          12           0          16          19
    =          12          17          20          25
    !          18          22          26           0
    =          23          30          26          33

  When a block of unequal lines in one input buffer does not have a related
  block of unequal lines in the other input buffer, for example caused by a
  deletion in one input buffer or an addition in the other input buffer, then
  the missing block of lines is indicated in the output buffer with a "!" line
  with the "line from" field pointing to the next line and the "line to" field
  being 0.
  Note that in such a case a "line from" field can be 1 higher than the
  buffer's number of lines to indicate a deletion at the end of a buffer.
  In other words, we can think of the missing lines as missing above the "line
  from".
  A "line from" field can never be 0.


  SECONDARY DETAILS

  This helper macro was initially created to create the FindChange tool,
  which has been requested by users and which I would like to have myself.
  The FindChange tool was last requested on 7 July 2024 with specific UI
  requirements.

  Comparing buffers takes time.
  The used algorithm has the benefit that it will always find the
  sequentially-closest commonalities and differences, but at the cost of
  becoming disproportionally slower for larger differences.
  A comparison that takes "forever" is mitigated by showing a progress
  indicator and by letting the user <Escape> a comparison.

  This helper macro's algorithm is optimized for best results, not performance.
  It has no problem with an excessive amount of small differences, but
  performance will downgrade disproportionally the larger a single difference
  is.
  The user can decide in run-time if they want to abort a too long comparison,
  in which case the comparison degrades gracefully, logging the remaining lines
  of both buffers as different.

  A theoretical side note:
  There actually is such a thing as a non-sequential buffer comparison.
  For example,
  Assume a buffer1 contains 3 blocks of text; block1, block2, and block3.
  Assume a buffer2 contains the same 3 blocks of text, but in the order
  block3, block2, block1.
  There are compare programs that can actually recognize and report the
  switched blocks of text.
  I have an inkling of how to do so and how this might have some technical
  uses, but not of how an end-user program could in practice and in a useful
  way present such changes.
  Therefore no such functionality is supported by this helper macro.


  TODO
    MUST
    - More testing for correctness.
    SHOULD
    - Currently progress is shown as a TSE message.
      Instead show a small pop-up window that includes
      a "Press <Escape> to interrupt ..." helpline.
    COULD
    - Possibly a technical improvement:
      The current algorithm keeps comparing lines until the end of BOTH buffers
      is reached, meaning it can compare with non-existing lines past the end
      of one buffer.
      In practice this works well, and it only performs significantly less in
      exceptional cases, therefore it currently has no priority.
    - Possibly a technical improvement:
      Implement the partially thought-up alternative algorithm, that hopefully
      does not reduce performance disproportionally for a larger block of
      different lines. Implement it as a separate macro first, which can then
      be tested against CmpBuf.
      That said, so far, using it on ordinary files, the current CmpBuf
      performs surprisingly well, so currently there is no incentive to improve
      it.
    WONT


  HISTORY

  v0.0.0.1   30 Jul 2024
    Initial development release.

  v0.0.0.2    4 Aug 2024
    Made the output buffer a mandatory parameter. This simplified the input and
    output handling, It made the output string only contain the return code.

  v0.0.0.3    5 Aug 2024
    Added reporting not-equal lines to the output buffer.
    Found and fixed bugs.

  v0.0.0.4    6 Aug 2024
    Implemented the "start" parameter.
    Implemented a the progress indicator as a message.

  v0.0.0.5    7 Aug 2024
    Now explicitly requires TSE v4.50rc15 or later,
    because it needs that TSE version's update to CompareLines().
    Now implements the "stop" parameter's time limit.
    A running comparison can now can <Escape>ed by the user.

  v0.0.0.6    8 Aug 2024
    Implemented the number in the "options" parameter, indicating how many
    lines must be equal for an equal block of lines to be found. Default 1.

  v0.0.0.7    9 Aug 2024
    Hopefully fixed a badly reproduceable bug.

  v0.1   10 Aug 2024
    Optimized the "phase 2" code for brevity.
    Improved the documentation.
    Changed the macro's status from "development" to "beta".

*/





/*
  T E C H N I C A L   B A C K G R O U N D   I N F O

  NOTE

  This pogram uses two hardcoded constants, 12 and 49, which depend on each
  other.


  COMPARING TWO BUFFERS

  Phase 1 algorithm:
    Do an outer loop of "lines-from" from the start to the end of both buffers:
      Do a middle loop incresing a "look-ahead" from 0 to Max(NumLines):
        Determine "lines-to" as lines-from + look-ahead.
        Do an inner loop comparing the "lines-to" to a block form the other
        input buffer's "line-from" to "line-to".
      If equal lines were found then we now know the beginning of their block,
      and we can determine the end of the block:
        Do a simple single-loop breadth-first search for unequal lines, which
        gives us the end of the block of equal lines.
        Log the block of equal lines ito the output buffer with an "=" mark.

  Phase 2 algorithm:
    The output buffer only contains "=" lines.
    These describe the blocks of lines that are equal.
    Loop through the whole output buffer, deducing the blocks of lines that are
    unequal based on the blocks of lines that are equal, and log the the
    deduced blocks of unequal lines as "!" lines before, between, and after the
    "=" lines.

  Evaluation and additional requirements:
    Logically this algorithm is flawless in matching its requirements.
    However, performance will go down factorially the further equal lines
    are separated from each other, possibly causing unacceptable run-times.
    The chosen mitigations are:
      A progress indicator that includes the current look-ahead.
      The capability to <Escape> the algorithm.
      An optional time-limit.
    That said, preliminary tests show a good performance for typical files.

  Algorithm alternative:
    I think I came up with an alternative algorithm, the performance of which
    should nicely degrade linearly with the size of differences.
    The algorithm would use the fact that TSE's Sort is crazy fast.
    It involves creating meta files per input buffer with line numbers and
    checksums for each line, one sorted on line number and one sorted on
    checksum, with those meta lines deleted that do not represent a common
    checksum.
    A rethought:
      Maybe the checksums are an unnecessary detour, and the original line-text
      can be used.
    Using these meta files it should be possible
    to create an "N to M" relationship between equal lines
    and to continuously find the next two equal lines in linear time.
    For now it is too complex, costly and iffy to warrant an attempt to
    implement it.


  GRACEFUL DEGRADATION

  The user and a time limit can only interrupt the comparison in phase 1.
  The output buffer will therefore be empty or only logs of blocks of equal
  lines.
  This is valid input for the phase 2 algorithm.
  The phase 2 algorithm will mark the whole buffers or respectively their
  remaining lines as one block of unequal lines.
  The return code will be "2" (which is truthy).


  GLOBAL VARIABLES

  The code for comparing buffers needs to be split up in procedures.
  To optimize a program's maintainability, it usually is a good programming
  guideline to keep data fields as local as possible, and to only pass relevant
  data fields from procedure to procedure.
  However, testing parameters versus "var parameters" versus "global variables"
  showed, that global variables always perform best, and significantly so if
  the variables do not change across calls.
  Therefore CmpBuf uses global variables to optimize its run-time.

  Curious counter-intuitive test result:
  "var integer" parameters perform worse than "integer" parameters,
  both for run-time and for macro size.
  This is caused by a known oddity in the implementation of the macro language.
  I have documented the details elsewhere.

*/





// Start of compatibility restrictions and mitigations ...

#if INTERNAL_VERSION < 12377
  Compile error: This macro requires a v4.50rc15 or later release of TSE.
#endif

// End of compatibility restrictions and mitigations.





// Global constants and semi-constants
string CMPBUF_MACRO_NAME [MAXSTRINGLEN] = ''


// Global variables
integer cmpbuf_check_counter    = 0
integer cmpbuf_filter_spaces    = FALSE
integer cmpbuf_flags            = FALSE
integer cmpbuf_in1_eof          = FALSE
integer cmpbuf_in1_id           = 0
integer cmpbuf_in1_numlines     = 0
integer cmpbuf_in2_eof          = FALSE
integer cmpbuf_in2_id           = 0
integer cmpbuf_in2_numlines     = 0
integer cmpbuf_min_lines        = 0
string  cmpbuf_options  [12]    = ''
integer cmpbuf_out_id           = 0
integer cmpbuf_prev_run_time    = 0
integer cmpbuf_progress_start   = 0
integer cmpbuf_start_time       = 0
integer cmpbuf_stop             = 0


integer proc cmpbuf_error(string msg)
  if Query(Beep)
    Alarm()
  endif

  MsgBox(CMPBUF_MACRO_NAME + ' ERROR', msg)

  return(FALSE)
end cmpbuf_error


integer proc cmpbuf_check_progress(integer in1_line_from,
                                   integer in2_line_from,
                                   integer look_ahead)
  string  display_line    [85] = ''
  integer in1_numlines         = iif(cmpbuf_in1_numlines, cmpbuf_in1_numlines, 1)
  integer in2_numlines         = iif(cmpbuf_in2_numlines, cmpbuf_in2_numlines, 1)
  string  look_ahead_fmt   [8] = ''
  integer rc                   = 1
  integer run_time             = GetTime() - cmpbuf_start_time
  string  run_time_fmt    [10] = ''
  integer run_time_fmt_hours   = 0
  integer run_time_fmt_minutes = 0
  integer run_time_fmt_seconds = 0
  integer run_time_seconds     = 0

  if run_time < 0                 // If midnight happened during run-time,
    run_time = run_time + 8640000 // then add a day in hundredths of seconds.
  endif

  if     run_time - cmpbuf_prev_run_time > 99
    cmpbuf_check_counter = Max(10, cmpbuf_check_counter *  90 / 100)
  elseif run_time - cmpbuf_prev_run_time < 90
    cmpbuf_check_counter = Max(10, cmpbuf_check_counter * 110 / 100)
  endif

  cmpbuf_prev_run_time = run_time
  run_time_seconds     = run_time / 100

  if run_time_seconds > cmpbuf_progress_start
    run_time_fmt_hours   =  run_time_seconds  /  3600
    run_time_fmt_minutes = (run_time_seconds mod 3600) / 60
    run_time_fmt_seconds =  run_time_seconds mod   60

    if run_time_fmt_hours
      run_time_fmt = Format(run_time_fmt_hours        , ':',
                            run_time_fmt_minutes:2:'0', ':',
                            run_time_fmt_seconds:2:'0')
    elseif run_time_fmt_minutes
      run_time_fmt = Format(run_time_fmt_minutes      , ':',
                            run_time_fmt_seconds:2:'0')
    else
      run_time_fmt = Format(run_time_fmt_seconds)
    endif

    look_ahead_fmt =
      Format(
        look_ahead *   100 / Max(in1_numlines, in2_numlines),
        '.',
        look_ahead * 10000 / Max(in1_numlines, in2_numlines) mod 100: 2: '0')

    display_line = Format(CMPBUF_MACRO_NAME,
                          ':';
                          run_time_fmt,
                          ', buffer1';
                          in1_line_from * 100 / in1_numlines,
                          '%, buffer2';
                          in2_line_from * 100 / in2_numlines,
                          '%, look-ahead';
                          look_ahead_fmt,
                          '%.')
    Message(display_line)
  endif

  if (   KeyPressed()
     and GetKey() == <Escape>)
  or run_time_seconds >= cmpbuf_stop
    rc = 2
  endif

  return(rc)
end cmpbuf_check_progress


proc cmpbuf_log_unequal_block(integer use_add,
                              integer in1_line_from,
                              integer in1_line_to,
                              integer in2_line_from,
                              integer in2_line_to)
  string log_line [49] = Format('!', in1_line_from:12, in1_line_to:12,
                                     in2_line_from:12, in2_line_to:12)
  if use_add
    AddLine(log_line)
  else
    InsertLine(log_line)
    Down()
  endif
end cmpbuf_log_unequal_block


integer proc cmpbuf_get_field(integer n)
  return(Val(GetToken(GetText(1, 49), ' ', n)))
end cmpbuf_get_field


integer proc cmpbuf_are_lines_equal(integer in1_line, integer in2_line)
  integer result = TRUE

  //  Return a valid result for a past-end-of-file comparison.
  if     in1_line > cmpbuf_in1_numlines
    result = FALSE
  elseif in2_line > cmpbuf_in2_numlines
    result = FALSE
  elseif cmpbuf_filter_spaces
    //  If filtering whitespace, then two empty lines are not equal.
    //  ( This is true for searching for equal lines, and might need to be
    //    revisited if this proc is used for searching for inequal lines. )
    GotoBufferId(cmpbuf_in1_id)
    GotoLine(in1_line)

    if CurrLineLen() == 0
      GotoBufferId(cmpbuf_in2_id)
      GotoLine(in2_line)

      if CurrLineLen() == 0
        result = FALSE
      endif
    endif
  endif

  if result
    result = not CompareLines(in1_line     , in2_line,
                              cmpbuf_flags ,
                              cmpbuf_in1_id, cmpbuf_in2_id)
  endif

  return(result)
end cmpbuf_are_lines_equal


integer proc cmpbuf_non_empty_line(integer id, integer line)
  integer result = FALSE

  PushLocation()
  GotoBufferId(id)
  GotoLine(line)
  result = PosFirstNonWhite()
  PopLocation()

  return(result)
end cmpbuf_non_empty_line


integer proc cmpbuf_n_equal_lines(integer in1_line_from, integer in2_line_from)
  integer equal_lines = 1
  integer in1_line    = in1_line_from
  integer in2_line    = in2_line_from
  integer result      = FALSE

  // Pre-condition: The first lines are equal.

  repeat
    if cmpbuf_filter_spaces
      repeat
        in1_line = in1_line + 1
      until in1_line > cmpbuf_in1_numlines
         or cmpbuf_non_empty_line(cmpbuf_in1_id, in1_line)
      repeat
        in2_line = in2_line + 1
      until in2_line > cmpbuf_in2_numlines
         or cmpbuf_non_empty_line(cmpbuf_in2_id, in2_line)
    else
      in1_line = in1_line + 1
      in2_line = in2_line + 1
    endif

    // CompareLines() returns 0 (FALSE) if lines are equal,
    // and non-zero (truthy) if lines are not equal.
    // CompareLines() also returns 0 (FALSE) if a line > NumLines().
    if CompareLines(in1_line     , in2_line,
                    cmpbuf_flags ,
                    cmpbuf_in1_id, cmpbuf_in2_id)
      break
    else
      equal_lines = equal_lines + 1
    endif
  until in1_line    >  cmpbuf_in1_numlines
     or in2_line    >  cmpbuf_in2_numlines
     or equal_lines >= cmpbuf_min_lines

  result = (equal_lines >= cmpbuf_min_lines)

  return(result)
end cmpbuf_n_equal_lines


integer proc cmpbuf_compare_buffers()
  integer equal_lines_found  = FALSE
  integer in1_line           = 0
  integer in1_line_from      = 1
  integer in1_line_to        = 0
  integer in2_line           = 0
  integer in2_line_from      = 1
  integer in2_line_to        = 0
  integer look_ahead         = 0     // Starts at 0 at start of buffers.
  integer rc                 = 1
  integer prev_in1_line_to   = 0
  integer prev_in2_line_to   = 0
  integer progress_counter   = 0

  //  PHASE 1
  //    Here is where the equal blocks of lines are detected.
  //    Using 3 levels of loops, this is the hard and time-consuming part.
  //    It is optimized for speed.

  while     rc == 1
  and   not cmpbuf_in1_eof
  and   not cmpbuf_in2_eof
    equal_lines_found = FALSE

    while     rc == 1
    and   not (cmpbuf_in1_eof and cmpbuf_in2_eof)   // Intentional!
    and   not equal_lines_found
      in1_line    = in1_line_from
      in2_line    = in2_line_from
      in1_line_to = in1_line_from + look_ahead
      in2_line_to = in2_line_from + look_ahead

      while     rc == 1
      and   not (cmpbuf_in1_eof and cmpbuf_in2_eof)   // Intentional!
      and   not equal_lines_found
      and       in1_line <= in1_line_to   //  and in2_line <= in2_line_to
        progress_counter = progress_counter + 1

        if  progress_counter == cmpbuf_check_counter
        and rc               == 1
          rc = cmpbuf_check_progress(in1_line_from, in2_line_from, look_ahead)
          progress_counter = 0
        endif

        if     cmpbuf_are_lines_equal(in1_line, in2_line_to)
          if cmpbuf_min_lines == 1
          or cmpbuf_n_equal_lines(in1_line, in2_line_to)
            in1_line_from     = in1_line
            in2_line_from     = in2_line_to
            equal_lines_found = TRUE
          endif
        elseif cmpbuf_are_lines_equal(in1_line_to, in2_line)
          if cmpbuf_min_lines == 1
          or cmpbuf_n_equal_lines(in1_line_to, in2_line)
            in1_line_from     = in1_line_to
            in2_line_from     = in2_line
            equal_lines_found = TRUE
          endif
        endif

        in1_line       = in1_line + 1
        in2_line       = in2_line + 1
        cmpbuf_in1_eof = in1_line > cmpbuf_in1_numlines
        cmpbuf_in2_eof = in2_line > cmpbuf_in2_numlines
      endwhile

      look_ahead = look_ahead + 1
    endwhile

    look_ahead = 1

    if equal_lines_found
      in1_line_to = in1_line_from
      in2_line_to = in2_line_from

      repeat
        if cmpbuf_filter_spaces
          repeat
            in1_line_to = in1_line_to + 1
          until in1_line_to > cmpbuf_in1_numlines
             or cmpbuf_non_empty_line(cmpbuf_in1_id, in1_line_to)
          repeat
            in2_line_to = in2_line_to + 1
          until in2_line_to > cmpbuf_in2_numlines
             or cmpbuf_non_empty_line(cmpbuf_in2_id, in2_line_to)
        else
          in1_line_to = in1_line_to + 1
          in2_line_to = in2_line_to + 1
        endif

        cmpbuf_in1_eof = in1_line_to > cmpbuf_in1_numlines
        cmpbuf_in2_eof = in2_line_to > cmpbuf_in2_numlines
      until cmpbuf_in1_eof
         or cmpbuf_in2_eof
         or CompareLines(in1_line_to  , in2_line_to,
                         cmpbuf_flags ,
                         cmpbuf_in1_id, cmpbuf_in2_id)

      AddLine(Format('=', in1_line_from: 12, in1_line_to - 1: 12,
                          in2_line_from: 12, in2_line_to - 1: 12),
              cmpbuf_out_id)
      in1_line_from = in1_line_to
      in2_line_from = in2_line_to
    endif
  endwhile

  //  PHASE 2
  //    Here the already logged blocks of equal lines are augmented with
  //    intersticial blocks of unequal lines.
  //    Using a single loop that processes a single buffer sequentially,
  //    this process is superfast.
  //    It is therefore optimized for brevity of code.
  //    (The latter actually made the .mac file 341 bytes smaller too.)

  GotoBufferId(cmpbuf_out_id)
  BegFile()

  if GetText(1, 1) == '='
    in1_line_from = cmpbuf_get_field(2)
    in1_line_to   = cmpbuf_get_field(3)
    in2_line_from = cmpbuf_get_field(4)
    in2_line_to   = cmpbuf_get_field(5)

    if in1_line_from == 1
      if in2_line_from == 1
        NoOp()
      else
        cmpbuf_log_unequal_block(FALSE, 1, 0, 1, in2_line_from - 1)
      endif
    else
      if in2_line_from == 1
        cmpbuf_log_unequal_block(FALSE, 1, in1_line_from - 1, 1, 0)
      else
        cmpbuf_log_unequal_block(FALSE, 1, in1_line_from - 1,
                                        1, in2_line_from - 1)
      endif
    endif

    while rc
    and   Down()
      prev_in1_line_to   = in1_line_to
      prev_in2_line_to   = in2_line_to

      in1_line_from      = cmpbuf_get_field(2)
      in1_line_to        = cmpbuf_get_field(3)
      in2_line_from      = cmpbuf_get_field(4)
      in2_line_to        = cmpbuf_get_field(5)

      if     in1_line_from == prev_in1_line_to + 1
        cmpbuf_log_unequal_block(FALSE, in1_line_from       , 0,
                                        prev_in2_line_to + 1, in2_line_from - 1)
      elseif in2_line_from == prev_in2_line_to + 1
        cmpbuf_log_unequal_block(FALSE, prev_in1_line_to + 1, in1_line_from - 1,
                                        in2_line_from       , 0)
      else
        cmpbuf_log_unequal_block(FALSE, prev_in1_line_to + 1, in1_line_from - 1,
                                        prev_in2_line_to + 1, in2_line_from - 1)
      endif
    endwhile

    if in1_line_to < cmpbuf_in1_numlines
      if in2_line_to < cmpbuf_in2_numlines
        cmpbuf_log_unequal_block(TRUE, in1_line_to + 1, cmpbuf_in1_numlines,
                                       in2_line_to + 1, cmpbuf_in2_numlines)
      else
        cmpbuf_log_unequal_block(TRUE, in1_line_to + 1, cmpbuf_in1_numlines,
                                       in2_line_to + 1, 0                  )
      endif
    else
      if in2_line_to < cmpbuf_in2_numlines
        cmpbuf_log_unequal_block(TRUE, in1_line_to + 1, 0                  ,
                                       in2_line_to + 1, cmpbuf_in2_numlines)
      endif
    endif
  else
    cmpbuf_log_unequal_block(TRUE, 1, cmpbuf_in1_numlines,
                                   1, cmpbuf_in2_numlines)
  endif

  return(rc)
end cmpbuf_compare_buffers


integer proc cmpbuf_check_buffer_id(integer id)
  integer rc = 1

  if id
    PushLocation()
    GotoBufferId(id)

    if GetBufferId() == id
      if BinaryMode()
        rc = cmpbuf_error(Format('Binary mode not allowed for parameter buffer';
                                 id, '.'))
      endif
    else
      rc = cmpbuf_error(Format('Parameter buffer'; id; 'does not exist.'))
    endif

    PopLocation()
  endif

  return(rc)
end cmpbuf_check_buffer_id


string proc cmpbuf(string p_parameters)
  integer i                         = 0
  integer id_counter                = 0
  integer j                         = 0
  integer rc                        = TRUE
  string  parameter  [MAXSTRINGLEN] = ''
  string  parameters [MAXSTRINGLEN] = Lower(Trim(p_parameters))

  // When included in another macro, globals need initialization at run-time.
  CMPBUF_MACRO_NAME       = SplitPath(CurrMacroFilename(), _NAME_)
  if not Pos('cmpbuf', Lower(CMPBUF_MACRO_NAME))
    CMPBUF_MACRO_NAME     = CMPBUF_MACRO_NAME + ':CmpBuf'
  endif
  cmpbuf_check_counter    = 10000
  cmpbuf_filter_spaces    = FALSE
  cmpbuf_flags            = FALSE
  cmpbuf_in1_eof          = FALSE
  cmpbuf_in1_id           = 0
  cmpbuf_in2_eof          = FALSE
  cmpbuf_in2_id           = 0
  cmpbuf_min_lines        = 1
  cmpbuf_options          = ''
  cmpbuf_out_id           = 0
  cmpbuf_prev_run_time    = 0
  cmpbuf_progress_start   = 1         //  In seconds.
  cmpbuf_start_time       = GetTime() //  In hundredths of seconds.
  cmpbuf_stop             = 86400     //  In seconds: 86400 == a day.

  for i = 1 to NumTokens(parameters, ' ')
    parameter = GetToken(parameters, ' ', i)
    if Val(parameter) > 0
      id_counter = id_counter + 1
      case id_counter
        when 1
          cmpbuf_in1_id = Val(parameter)
        when 2
          cmpbuf_in2_id = Val(parameter)
        when 3
          cmpbuf_out_id = Val(parameter)
        otherwise
          rc = cmpbuf_error('No 4th integer parameter allowed.')
      endcase
    elseif parameter[1:8] == 'options='
      cmpbuf_options       = parameter[9:MAXSTRINGLEN]
      cmpbuf_filter_spaces = FALSE
      cmpbuf_min_lines     = 0
      if Length(cmpbuf_options) == SizeOf(cmpbuf_options)
        rc = cmpbuf_error('Parameter "options=" has too many options.')
      else
        for j = 1 to Length(cmpbuf_options)
          case cmpbuf_options[j]
            when 'f'
              cmpbuf_filter_spaces = TRUE
              cmpbuf_flags         = cmpbuf_flags | _FILTER_SPACES_
            when 'i'
              cmpbuf_flags         = cmpbuf_flags | _IGNORE_CASE_
            when '0' .. '9'
              cmpbuf_min_lines     = cmpbuf_min_lines * 10 +
                                     Val(cmpbuf_options[j])
            otherwise
              rc = cmpbuf_error('"' + cmpbuf_options[j] +
                                '" is not a valid option.')
              break
          endcase
        endfor
        if cmpbuf_min_lines == 0
          cmpbuf_min_lines = 1
        endif
      endif
    elseif parameter[1:6] == 'start='
      if Val(parameter[7:MAXSTRINGLEN]) >  0
      or     parameter[7:MAXSTRINGLEN] == '0'
        cmpbuf_progress_start = Val(parameter[7:MAXSTRINGLEN])
      else
        rc = cmpbuf_error('Parameter "start=" has an illegal value.')
      endif
    elseif parameter[1:5] == 'stop='
      if Val(parameter[6:MAXSTRINGLEN]) >  0
      or     parameter[6:MAXSTRINGLEN] == '0'
        cmpbuf_stop = Val(parameter[6:MAXSTRINGLEN])
      else
        rc = cmpbuf_error('Parameter "stop=" has an illegal value.')
      endif
    else
      rc = cmpbuf_error('Illegal parameter "' + parameter + '".')
    endif

    if not rc
      break
    endif
  endfor

  if rc
    if cmpbuf_in1_id == 0
    or cmpbuf_in2_id == 0
    or cmpbuf_out_id == 0
      rc = cmpbuf_error('Parameters require 2 input ids followed by 1 output id.')
    else
      rc = rc and cmpbuf_check_buffer_id(cmpbuf_in1_id)
      rc = rc and cmpbuf_check_buffer_id(cmpbuf_in2_id)
      rc = rc and cmpbuf_check_buffer_id(cmpbuf_out_id)
    endif
  endif

  if rc
    PushPosition()
    GotoBufferId(cmpbuf_in1_id)
    PushPosition()
    GotoBufferId(cmpbuf_in2_id)
    PushPosition()

    GotoBufferId(cmpbuf_in1_id)
    cmpbuf_in1_numlines = NumLines()
    if cmpbuf_in1_numlines == 0
      cmpbuf_in1_eof = TRUE
    endif

    GotoBufferId(cmpbuf_in2_id)
    cmpbuf_in2_numlines = NumLines()
    if cmpbuf_in2_numlines == 0
      cmpbuf_in2_eof = TRUE
    endif

    EmptyBuffer(cmpbuf_out_id)

    //  Above this comment rc is TRUE or FALSE (1 or 0), meaning ok or not ok.
    //
    //  Below this comment rc can also become 2, meaning that the macro was
    //  interrupted by the user or by the "stop" parameter's time limit, but
    //  that the output buffer still contains valid syntax by marking the
    //  remaining lines as different.

    rc = cmpbuf_compare_buffers()

    PopPosition()
    PopPosition()
    PopPosition()
  endif

  return(Str(rc))
end cmpbuf


// End of copy of CmpBuf.inc.





Datadef action_display_template
  "---------- ACTIONS WITH IMMUTABLE KEYS -------------"
  "Escape"
  "Show main help screen"
  "Show keys help screen"
  "Toggle ignore case"
  "Toggle filter whitespace"
  "Set minimum match lines"
  "Configure settings"
  ""
  "---------- ACTIONS WITH CONFIGURABLE KEYS ----------"
  "Toggle selected window"
  "Toggle window split type"
  "Find first difference"
  "Find last difference"
  "Find next difference"
  "Find previous difference"
  "Move cursors to begin"
  "Move cursors to end"
  "Move cursors page up"
  "Move cursors page down"
  "Move cursors up"
  "Move cursors down"
  "Move cursors left"
  "Move cursors right"
  "Move cursor to begin"
  "Move cursor to end"
  "Move cursor page up"
  "Move cursor page down"
  "Move cursor up"
  "Move cursor down"
  "Move cursor left"
  "Move cursor right"
end action_display_template


Datadef default_actions_and_keys
  "Toggle selected window;Tab,Ctrl Tab"
  "Toggle window split type;Spacebar"
  "Find first difference;Alt CursorUp,Alt GreyCursorUp,Alt U,Alt F"
  "Find last difference;Alt CursorDown,Alt GreyCursorDown,Alt D,Alt T"
  "Find next difference;Alt CursorRight,Alt GreyCursorRight,Alt R,Alt N,Enter,F3,Ctrl L"
  "Find previous difference;Alt CursorLeft,Alt GreyCursorLeft,Alt L,AltP,CtrlShift L"
  "Move cursors to begin;Home,GreyHome,H"
  "Move cursors to end;End,GreyEnd,E"
  "Move cursors page up;PgUp,GreyPgUp"
  "Move cursors page down;PgDn,GreyPgDn"
  "Move cursors up;CursorUp,GreyCursorUp,U"
  "Move cursors down;CursorDown,GreyCursorDown,D"
  "Move cursors left;CursorLeft,GreyCursorLeft,L"
  "Move cursors right;CursorRight,GreyCursorRight,R"
  "Move cursor to begin;Ctrl Home,Ctrl H,CtrlShift H"
  "Move cursor to end;Ctrl end,Ctrl E,CtrlShift E"
  "Move cursor page up;Ctrl PgUp,Ctrl GreyPgUp"
  "Move cursor page down;Ctrl PgDn,Ctrl GreyPgDn"
  "Move cursor up;Ctrl CursorUp,Ctrl GreyCursorUp,Ctrl U,CtrlShift U"
  "Move cursor down;Ctrl CursorDown,Ctrl GreyCursorDown,Ctrl D,CtrlShift D"
  "Move cursor left;Ctrl CursorLeft,Ctrl GreyCursorLeft,Ctrl L,CtrlShift L"
  "Move cursor right;Ctrl CursorRight,Ctrl GreyCursorRight,Ctrl R,CtrlShift R"
end default_actions_and_keys


Datadef immutable_actions_and_keys
  "Escape;Escape"
  "Show main help screen;F1,P"
  "Show keys help screen;K"
  "Toggle ignore case;I"
  "Toggle filter whitespace;F,W"
  "Set minimum match lines;1,2,3,4,5,6,7,8,9"
  "Configure settings;F10,C"
end immutable_actions_and_keys


// Global constants and pseudo-constants.

integer ACTION_LIST_ID                  = 0

#define CCF_FLAGS                         _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_

#define FIND_FIRST                        1
#define FIND_LAST                         2
#define FIND_NEXT                         3
#define FIND_PREVIOUS                     4

#define FROM_START_UP                     1
#define FROM_BROWSER                      2

#define HELP_SCREEN_MAIN                  1
#define HELP_SCREEN_ACTIONS               2
#define HELP_SCREEN_CONFIG_MENU           3

#define ID_MATCH_LINES                    1
#define ID_MSG_DURATION                   2
#define ID_PROGRESS_AFTER                 3
#define ID_TIME_LIMIT                     4

#define KEY_LIST_BY_ACTION                1
#define KEY_LIST_BY_KEY                   2
integer KEY_LIST_ID                     = 0

string  KEYS_SECTION     [MAXSTRINGLEN] = ''

integer MACRO_ID                        = 0
string  MACRO_NAME       [MAXSTRINGLEN] = ''

#define MAX_ACTION_LEN                    24
#define MAX_KEY_LEN                       37

#define MOVE_BEGIN                        1
#define MOVE_DOWN                         2
#define MOVE_END                          3
#define MOVE_LEFT                         4
#define MOVE_PAGE_DOWN                    5
#define MOVE_PAGE_UP                      6
#define MOVE_RIGHT                        7
#define MOVE_UP                           8

string  SETTINGS_SECTION [MAXSTRINGLEN] = ''

#define SPLIT_HORIZONTALLY                Asc('|')
#define SPLIT_VERTICALLY                  Asc('-')

#define START_UP_MENU_2_BUFFERS           1
#define START_UP_MENU_CHANGED_BUFFER      2
#define START_UP_MENU_SELECT_BUFFER       3


// Global variables
integer g_cfg_msg_duration                 = 2
integer g_cfg_window_split                 = SPLIT_VERTICALLY

integer g_cfg_filter_whitespace            = TRUE
integer g_cfg_ignore_case                  = TRUE
integer g_cfg_match_lines                  = 2
integer g_cfg_progress_after               = 5
integer g_cfg_time_limit                   = 86400

integer g_cfg_color_other                  = 0
integer g_cfg_color_selected               = 0
integer g_cfg_synhi_in_other               = 0
integer g_cfg_synhi_in_selected            = 0

integer g_block_pos                        = 0
integer g_config_menu_origin               = _NONE_
integer g_double_keystroke                 = FALSE
integer g_in1_id                           = 0
integer g_keys_were_changed                = FALSE
integer g_out_id                           = 0
integer g_out_line                         = 0
integer g_out_num_lines                    = 0
integer g_restart_action_list              = FALSE
integer g_restart_browser                  = FALSE
integer g_restart_key_list                 = FALSE
string  g_selected_action [MAX_ACTION_LEN] = ''
integer g_show_startup_message             = TRUE
integer g_tmp_buffer_created               = FALSE
integer g_tmp_buffer2_created              = FALSE
integer g_in2_id                           = 0

integer g_browse_in1_id                    = 0
integer g_browse_in2_id                    = 0
integer g_cfg_color_intra                  = 0


proc to_beep_or_not_to_beep()
  if Query(Beep)
    Alarm()
  endif
end to_beep_or_not_to_beep


proc pop_msg_open(string window_title, string msg)
  integer left_margin  = 1
  integer popup_width  = Max(Length(window_title), Length(msg)) + 2
  integer right_margin = 0

  if Length(msg) + 2 < Query(ScreenCols)
    left_margin = Max((Query(ScreenCols) - popup_width) / 2, 1)
  endif

  right_margin = left_margin + popup_width - 1

  PopWinOpen(left_margin,
             Query(ScreenRows) / 2 - 1,
             right_margin,
             Query(ScreenRows) / 2 + 1,
             1, window_title, Query(MenuBorderAttr))
  ClrScr()
  PutStrAttrXY(1, 1, msg, '', Query(MenuTextAttr))
end pop_msg_open


proc pop_msg_close()
  PopWinClose()
end pop_msg_close


proc pop_msg(string window_title, string msg, integer duration)
  if duration > 0
    pop_msg_open(window_title, msg)
    Delay(duration)
    pop_msg_close()
  endif
end pop_msg


proc pop_message(string msg)
  //  Tiny pause to draw attention to the transition from any previous screen
  //  to the message popping up.
  Delay(1)
  pop_msg(MACRO_NAME, msg, g_cfg_msg_duration * 18)
end pop_message


integer proc write_setting_int(string  item_name,
                               integer item_value)
  integer result = WriteProfileInt(SETTINGS_SECTION,
                                   item_name,
                                   item_value)
  if not result
    to_beep_or_not_to_beep()
    Warn(MACRO_NAME; 'failed to write setting configuration to file "tse.ini".')
  endif
  return(result)
end write_setting_int


proc show_help_screen(integer help_screen, integer help_caller)
  integer help_found               = FALSE
  integer help_id                  = 0
  string  help_name [MAXSTRINGLEN] = ''
  string  help_search_option   [1] = 'g'
  integer old_cursor               = 0
  integer old_DisplayMode          = 0
  integer old_ShowHelpLine         = 0
  integer old_ShowMainMenu         = 0
  integer old_ShowStatusLine       = 0
  integer old_WindowId             = 0
  integer org_id                   = GetBufferId()
  string  src_fqn   [MAXSTRINGLEN] = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_|_NAME_) + '.s'
  integer tmp_id                   = 0
  integer win1_id                  = 0
  integer win2_id                  = 0

  case help_screen
    when HELP_SCREEN_MAIN
      help_name = '*** ' + MACRO_NAME + ' - Main Help ***'
    when HELP_SCREEN_ACTIONS
      help_name = '*** ' + MACRO_NAME + ' - Action Help ***'
    when HELP_SCREEN_CONFIG_MENU
      help_name = '*** ' + MACRO_NAME + ' - Configuration Menu Help ***'
    otherwise
      help_name = '*** ' + MACRO_NAME + ' - Wrong Help ***'
  endcase

  help_id = GetBufferId(help_name)

  if help_id
    GotoBufferId(help_id)
  else
    tmp_id = CreateTempBuffer()

    if LoadBuffer(src_fqn)
      help_found = TRUE

      do help_screen times
        // Separate characters needed to not confuse old SynCase extension.
        if not lFind('/' + '*', help_search_option)
          help_found = FALSE
        endif

        help_search_option = '+'
      enddo

      if help_found
        PushBlock()
        UnMarkBlock()
        Down()
        MarkLine()
        if lFind('*' + '/', '')
          Up()
        else
          EndFile()
        endif
        MarkLine()
        Copy()
        help_id = CreateTempBuffer()
        Paste()
        UnMarkBlock()
        PopBlock()
        EndFile()
        AddLine()
        BegFile()
        InsertLine()
        #ifdef LINUX
          if help_screen == HELP_SCREEN_ACTIONS

            AddLine(
'  In Linux, typically in servers, some keys may do nothing or do something else.')
            AddLine('  That is what the alternative keys are for.')
            AddLine()
            BegFile()
          endif
        #endif
        ChangeCurrFilename(help_name, CCF_FLAGS)
        FileChanged(FALSE)
        BrowseMode(TRUE)
      else
        GotoBufferId(org_id)
        Warn('File "', src_fqn, '" has no multi-line comment block.')
      endif
    else
      GotoBufferId(org_id)
      Warn('File "', src_fqn, '" not found.')
    endif

    AbandonFile(tmp_id)
  endif

  if help_id
    if help_caller == FROM_BROWSER
      GotoBufferId(org_id)
      old_WindowId = WindowId()
      GotoWindow(1)
      win1_id = GetBufferId()
      GotoWindow(2)
      win2_id = GetBufferId()
      GotoWindow(old_WindowId)
      OneWindow()
    endif

    GotoBufferId(help_id)

    old_Cursor         = Set(Cursor        , OFF)
    old_ShowHelpLine   = Set(ShowHelpLine  , OFF)
    old_ShowStatusLine = Set(ShowStatusLine, OFF)
    old_ShowMainMenu   = Set(ShowMainMenu  , OFF)
    old_DisplayMode    = DisplayMode(_DISPLAY_HELP_)

    repeat
      UpdateDisplay()
      case GetKey()
        when <CursorDown>, <GreyCursorDown>
          if CurrLine() + Query(WindowRows) - CurrRow() < NumLines()
            RollDown()
          endif
        when <CursorUp>, <GreyCursorUp>
          RollUp()
        when <PgDn>, <GreyPgDn>
          do Query(WindowRows) - 1 times
            if CurrLine() + Query(WindowRows) - CurrRow() < NumLines()
              RollDown()
            endif
          enddo
        when <PgUp>, <GreyPgUp>
          RollUp(Query(WindowRows))
      endcase
    until Query(Key) == <Escape>

    DisplayMode(        old_DisplayMode   )
    Set(Cursor        , old_Cursor        )
    Set(ShowHelpLine  , old_ShowHelpLine  )
    Set(ShowStatusLine, old_ShowStatusLine)
    Set(ShowMainMenu  , old_ShowMainMenu  )
    GotoBufferId(org_id)
    UpdateDisplay()

    if help_caller == FROM_BROWSER
      if g_cfg_window_split == SPLIT_HORIZONTALLY
        HWindow()
      else
        VWindow()
      endif
      GotoWindow(1)
      GotoBufferId(win1_id)
      GotoWindow(2)
      GotoBufferId(win2_id)
      GotoWindow(old_WindowId)
    endif
  endif
end show_help_screen


integer proc write_key_str(string item_name,
                           string item_value)
  integer result = WriteProfileStr(KEYS_SECTION,
                                   item_name,
                                   item_value)
  if not result
    to_beep_or_not_to_beep()
    Warn(MACRO_NAME; 'failed to write key configuration to file "tse.ini".')
  endif
  return(result)
end write_key_str


integer proc is_immutable_key(string key_name)
  return(GetBufferInt('Immutable:' + key_name, MACRO_ID))
end is_immutable_key


proc install_actions_and_keys(integer mark_keys_as_immutable)
  string  action  [MAX_ACTION_LEN] = ''
  integer key_code                 = 0
  string  key_name   [MAX_KEY_LEN] = ''
  string  key_names [MAXSTRINGLEN] = ''
  integer token_number             = 0

  BegFile()
  repeat
    action    = GetToken(GetText(1, MAXSTRINGLEN), ';', 1)
    key_names = GetToken(GetText(1, MAXSTRINGLEN), ';', 2)

    for token_number = 1 to NumTokens(key_names, ',')
      key_name = GetToken(key_names, ',', token_number)
      SetBufferInt(action  , TRUE  , MACRO_ID)
      SetBufferStr(key_name, action, MACRO_ID)

      if mark_keys_as_immutable
        SetBufferInt('Immutable:' + key_name, TRUE, MACRO_ID)
      endif
    endfor
  until not Down()

  if mark_keys_as_immutable
    SetBufferInt('Immutable:Escape', TRUE, MACRO_ID)

    //  Disallow keys with characters in name that the browser internally uses
    //  to separate key names. Could be rewritten to use different separators.
    for key_code = 1 to 65535
      key_name = KeyName(key_code)

      if Pos(',', key_name)
      or Pos(';', key_name)
        SetBufferInt('Immutable:' + key_name, TRUE, MACRO_ID)
      endif
    endfor
  endif
end install_actions_and_keys


proc add_key()
  integer key_code               = 0
  string  key_name [MAX_KEY_LEN] = ''

  pop_msg_open('', 'Press its new key now ... ')
  key_code = GetKey()
  key_name = KeyName(key_code)
  pop_msg_close()

  if (key_name in 'a' .. 'z')
    key_name = Upper(key_name)
  endif

  if is_immutable_key(key_name)
    to_beep_or_not_to_beep()
    pop_message('You cannot add an immutable key.')
  else
    case GetBufferStr(key_name, MACRO_ID)
      when ''
        SetBufferStr(key_name, g_selected_action, MACRO_ID)
        g_keys_were_changed = TRUE
        g_restart_key_list  = TRUE
        PushKey(<Escape>)
      when g_selected_action
        to_beep_or_not_to_beep()
        pop_message('This key already exists for this action.')
      otherwise
        if MsgBox('Adding key ...',
                  Format('Delete key  "', key_name, '"', Chr(13),
                         'from action "',
                           GetBufferStr(key_name, MACRO_ID), '"', Chr(13),
                         Chr(13),
                         'and add key "', key_name, '"', Chr(13),
                         'to action   "', g_selected_action, '"?'),
                  _YES_NO_) == 1
          SetBufferStr(key_name, g_selected_action, MACRO_ID)
          g_keys_were_changed = TRUE
          g_restart_key_list  = TRUE
          PushKey(<Escape>)
        endif
    endcase
  endif
end add_key


proc del_key()
  string key_name [MAX_KEY_LEN] = Trim(GetText(1, MAX_KEY_LEN))

  if key_name == ''
    to_beep_or_not_to_beep()
    pop_message('No key to delete.')
  elseif is_immutable_key(key_name)
    to_beep_or_not_to_beep()
    pop_message('You cannot delete an immutable key.')
  else
    DelBufferVar(key_name, MACRO_ID)
    g_keys_were_changed = TRUE
    g_restart_key_list  = TRUE
    PushKey(<Escape>)
  endif
end del_key


Keydef key_list_keys
  <Del> del_key()
  <Ins> add_key()
end key_list_keys


proc key_list_cleanup()
  UnHook(key_list_cleanup)
  Disable(key_list_keys)
end key_list_cleanup


proc key_list_startup()
  UnHook(key_list_startup)
  Hook(_LIST_CLEANUP_, key_list_cleanup)
  Enable(key_list_keys)
  ListFooter('{Ins} Add key   {Del} Delete key')
end key_list_startup


proc show_key_list(string action)
  integer key_code               = 0
  string  key_name [MAX_KEY_LEN] = ''
  integer selection              = FALSE

  PushLocation()

  GotoBufferId(key_list_id)
  repeat
    EmptyBuffer()

    for key_code = 1 to 65535
      key_name = KeyName(key_code)

      if      GetBufferStr(key_name, MACRO_ID) == action
      and not lFind(key_name, '^g')
        EndFile()
        AddLine(key_name)
      endif
    endfor

    Hook(_LIST_STARTUP_, key_list_startup)
    g_selected_action  = action
    g_restart_key_list = FALSE
    selection          = lList('Keys for: ' + action,
                               Max(Length(action) + 17,
                                   Max(LongestLineInBuffer(),
                                       28)),
                               NumLines(), _NONE_)
  until not g_restart_key_list
    and not selection

  PopLocation()
end show_key_list


proc restore_default_keys()
  integer key_code               = 0
  string  key_name [MAX_KEY_LEN] = ''
  integer tmp_id                 = 0

  to_beep_or_not_to_beep()
  PushKey(<Tab>)

  if MsgBox('Are you sure?',
            'Delete your configured keys and restore the default keys?',
            _YES_NO_) == 1
    for key_code = 1 to 65535
      key_name = KeyName(key_code)
      DelBufferVar(key_name, MACRO_ID)
    endfor

    PushLocation()
    CreateTempBuffer()

    // Load default browser keys.
    PushBlock()
    InsertData(default_actions_and_keys)
    PopBlock()
    install_actions_and_keys(FALSE)

    // Add immutable browser keys.
    EmptyBuffer()
    PushBlock()
    InsertData(immutable_actions_and_keys)
    PopBlock()
    install_actions_and_keys(TRUE)

    PopLocation()
    AbandonFile(tmp_id)
  endif
end restore_default_keys


Keydef action_list_keys
  <F1>      show_help_screen(HELP_SCREEN_ACTIONS, FROM_BROWSER)
            g_restart_action_list = TRUE
            PushKey(<Escape>)

  <Alt R>   restore_default_keys()
            g_keys_were_changed   = TRUE
            g_restart_action_list = TRUE
            PushKey(<Escape>)
end action_list_keys


proc action_list_cleanup()
  UnHook(action_list_cleanup)
  Disable(action_list_keys)
end action_list_cleanup


proc action_list_startup()
  UnHook(action_list_startup)
  Hook(_LIST_CLEANUP_, action_list_cleanup)
  Enable(action_list_keys)
  ListFooter("{F1} Help   {Enter} Configure action's keys   {Alt R} Reset all keys")
end action_list_startup


proc show_action_list(integer list_caller)
  string  action [MAX_ACTION_LEN] = ''
  integer key_code                = 0
  string  key_name  [MAX_KEY_LEN] = ''
  integer old_WindowId            = 0
  integer org_id                  = GetBufferId()
  integer selection               = FALSE
  integer win1_id                 = 0
  integer win2_id                 = 0

  if list_caller == FROM_BROWSER
    GotoBufferId(org_id)
    old_WindowId = WindowId()
    GotoWindow(1)
    win1_id = GetBufferId()
    GotoWindow(2)
    win2_id = GetBufferId()
    GotoWindow(old_WindowId)
    OneWindow()
  endif

  repeat
    // Copy actions from their template.
    GotoBufferId(MACRO_ID)
    PushBlock()
    MarkLine(1, NumLines())

    GotoBufferId(action_list_id)
    PushLocation()

    EmptyBuffer()
    CopyBlock()
    PopBlock()

    for key_code = 1 to 65535
      key_name = KeyName(key_code)
      action   = GetBufferStr(key_name, MACRO_ID)

      if action <> ''
        if lFind(action, '^g')
          GotoPos(MAX_ACTION_LEN + 1)
          if  not lFind(' ' + key_name + ',', 'c')
          and not lFind(' ' + key_name      , 'c$')
            if GetText(MAX_ACTION_LEN + 2, 1) == ''
              GotoPos(MAX_ACTION_LEN + 2)
              InsertText(key_name, _INSERT_)
            else
              EndLine()
              InsertText(', ' + key_name, _INSERT_)
            endif
          endif
        else
          Warn('Error: Unknown action "', action, '" with key "', key_name, '".')
        endif
      endif
    endfor

    PopLocation()

    if CurrLine() == 1
      do 8 times
        PushKey(<CursorDown>)
      enddo
    endif

    g_restart_action_list = FALSE
    Hook(_LIST_STARTUP_, action_list_startup)
    selection = lList('Actions with their keys', LongestLineInBuffer(),
                      NumLines(), _ENABLE_HSCROLL_)
    if selection
      action = Trim(GetText(1, MAX_ACTION_LEN))
      if (action[1: 1] in '', '-')
        pop_message('You did not select an action.')
      else
        show_key_list(action)
      endif
      Hook(_LIST_STARTUP_, action_list_startup)
    endif
  until not g_restart_action_list
    and not selection

  GotoBufferId(org_id)
  UpdateDisplay()

  if list_caller == FROM_BROWSER
    if g_cfg_window_split == SPLIT_HORIZONTALLY
      HWindow()
    else
      VWindow()
    endif
    GotoWindow(1)
    GotoBufferId(win1_id)
    GotoWindow(2)
    GotoBufferId(win2_id)
    GotoWindow(old_WindowId)
  endif
end show_action_list


integer proc get_out_line(integer position)
  integer result = 0

  if  g_out_id
  and g_out_line
    PushLocation()
    GotoBufferId(g_out_id)
    GotoLine(g_out_line)

    result = Val(GetText(position, 12))

    PopLocation()
  endif

  return(result)
end get_out_line


integer proc both_blocks_have_at_most_1_line()
  integer buf1_block_line_from = 0
  integer buf1_block_line_to   = 0
  integer buf1_block_num_lines = 0
  integer buf2_block_line_from = 0
  integer buf2_block_line_to   = 0
  integer buf2_block_num_lines = 0
  integer result               = FALSE

  PushLocation()
  GotoBufferId(g_out_id)
  GotoLine(g_out_line)

  buf1_block_line_from = Val(GetText( 2, 12))
  buf1_block_line_to   = Val(GetText(14, 12))
  buf2_block_line_from = Val(GetText(26, 12))
  buf2_block_line_to   = Val(GetText(38, 12))

  buf1_block_num_lines = iif(buf1_block_line_to,
                             buf1_block_line_to - buf1_block_line_from + 1,
                             0)
  buf2_block_num_lines = iif(buf2_block_line_to,
                             buf2_block_line_to - buf2_block_line_from + 1,
                             0)
  result = (buf1_block_num_lines <= 1 and buf2_block_num_lines <= 1)

  PopLocation()
  return(result)
end both_blocks_have_at_most_1_line


integer proc get_distance(integer offset, integer line)
  return(Abs(Val(GetText(offset, 12)) - line))
end get_distance


proc find_difference(integer find_which)
  integer block_line_from       = 0
  integer block_line_to         = 0
  integer cur_window_id         = WindowId()
  integer distance              = 0
  integer found                 = FALSE
  integer min_distance          = MAXINT
  integer cur_line              = CurrLine()
  integer out_line_offset_from  = 0
  integer out_line_offset_to    = 0

  if      g_out_num_lines
  and not found
    if     find_which == FIND_FIRST
      g_out_line  = 1
      g_block_pos = _SEEK_BEGIN_
      found       = TRUE
    elseif find_which == FIND_LAST
      g_out_line  = g_out_num_lines
      g_block_pos = _SEEK_END_
      found       = TRUE
    endif
  endif

  if      g_out_num_lines
  and not found
    if cur_window_id == 1
      out_line_offset_from =  2
      out_line_offset_to   = 14
    else
      out_line_offset_from = 26
      out_line_offset_to   = 38
    endif
  endif

  if      g_out_num_lines
  and not found
  and     g_out_line == 0
    // Find the nearest difference
    PushLocation()
    GotoBufferId(g_out_id)
    BegFile()
    repeat
      distance = get_distance(out_line_offset_from, cur_line)

      if distance <= min_distance
        min_distance = distance
        g_out_line   = CurrLine()
        g_block_pos  = _SEEK_BEGIN_
        found        = TRUE
      endif

      distance = get_distance(out_line_offset_to  , cur_line)

      if distance <= min_distance
        min_distance = distance
        g_out_line   = CurrLine()
        g_block_pos  = _SEEK_END_
        found        = TRUE
      endif
    until not Down()
    PopLocation()
  endif

  //  Logically this block of code is superfluous, but it has the advantage
  //  that in typical situations it is faster then the next block of code.
  if      g_out_num_lines
  and not found
  and     (cur_line in get_out_line(out_line_offset_from),
                       get_out_line(out_line_offset_to  ))
    if find_which == FIND_NEXT
      if     g_block_pos == _SEEK_END_
      or (   g_block_pos == _SEEK_BEGIN_
         and both_blocks_have_at_most_1_line())
        if g_out_line < g_out_num_lines
          g_out_line  = g_out_line + 1
          g_block_pos = _SEEK_BEGIN_
          found       = TRUE
        endif
      else
        g_block_pos = _SEEK_END_
        found       = TRUE
      endif
    else
      if g_block_pos == _SEEK_BEGIN_
      or both_blocks_have_at_most_1_line()
        if g_out_line > 1
          g_out_line  = g_out_line - 1
          g_block_pos = _SEEK_END_
          found       = TRUE
        endif
      else
        g_block_pos = _SEEK_BEGIN_
        found       = TRUE
      endif
    endif
  endif

  if      g_out_num_lines
  and not found
    PushLocation()
    GotoBufferId(g_out_id)

    if find_which == FIND_NEXT
      BegFile()
      repeat
        if     Val(GetText(out_line_offset_from, 12)) > cur_line
          g_out_line  = CurrLine()
          g_block_pos = _SEEK_BEGIN_
          found       = TRUE
        elseif Val(GetText(out_line_offset_to  , 12)) > cur_line
          g_out_line  = CurrLine()
          g_block_pos = _SEEK_END_
          found       = TRUE
        endif
      until     found
         or not Down()
    else
      EndFile()
      repeat
        if     Val(GetText(out_line_offset_to  , 12)) < cur_line
          g_out_line  = CurrLine()
          g_block_pos = _SEEK_END_
          found       = TRUE
        elseif Val(GetText(out_line_offset_from, 12)) < cur_line
          g_out_line  = CurrLine()
          g_block_pos = _SEEK_BEGIN_
          found       = TRUE
        endif
      until     found
         or not Up()
    endif

    PopLocation()
  endif

  if g_out_num_lines
    if found
      GotoWindow(1)
      block_line_from = get_out_line( 2)
      block_line_to   = get_out_line(14)

      if g_block_pos   == _SEEK_BEGIN_
      or block_line_to == 0
        GotoLine(block_line_from)
      else
        GotoLine(block_line_to)
      endif

      ScrollToCenter()

      GotoWindow(2)
      block_line_from = get_out_line(26)
      block_line_to   = get_out_line(38)

      if g_block_pos   == _SEEK_BEGIN_
      or block_line_to == 0
        GotoLine(block_line_from)
      else
        GotoLine(block_line_to)
      endif

      ScrollToCenter()
      GotoWindow(cur_window_id)

      if   CurrLine() == cur_line
      and (find_which in FIND_FIRST, FIND_LAST)
        pop_message('Already there.')
      endif
    else
      if find_which == FIND_NEXT
        pop_message('No next difference.')
      else
        pop_message('No previous difference.')
      endif
    endif
  else
    pop_message('No differences found.')
  endif
end find_difference


proc toggle_window_split_setting()
  g_cfg_window_split = iif(g_cfg_window_split == SPLIT_HORIZONTALLY,
                           SPLIT_VERTICALLY,
                           SPLIT_HORIZONTALLY)
end toggle_window_split_setting


proc toggle_window_split(integer toggle_setting)
  integer old_WindowId = WindowId()
  integer win1_id      = 0
  integer win2_id      = 0

  GotoWindow(1)
  win1_id = GetBufferId()
  GotoWindow(2)
  win2_id = GetBufferId()

  OneWindow()

  if g_cfg_window_split == SPLIT_HORIZONTALLY
    VWindow()
  else
    HWindow()
  endif

  GotoWindow(1)
  GotoBufferId(win1_id)
  GotoWindow(2)
  GotoBufferId(win2_id)

  GotoWindow(old_WindowId)

  if toggle_setting
    toggle_window_split_setting()
  endif
end toggle_window_split


proc current_window(integer action)
  case action
    when MOVE_BEGIN
      if g_double_keystroke
        BegFile()
      else
        BegLine()
      endif
    when MOVE_END
      if g_double_keystroke
        if CurrLine() == NumLines()
          EndLine()
        else
          EndFile()
          BegLine()
        endif
      else
        EndLine()
      endif
    when MOVE_UP
      Up()
      if NumLines() - CurrLine() + 1 > Query(WindowRows) / 2
        ScrollToCenter()
      endif
    when MOVE_DOWN
      Down()
      if NumLines() - CurrLine() + 1 > Query(WindowRows) / 2
        ScrollToCenter()
      endif
    when MOVE_LEFT
      RollLeft()
    when MOVE_RIGHT
      RollRight()
    when MOVE_PAGE_UP
      PageUp()
      ScrollToCenter()
    when MOVE_PAGE_DOWN
      PageDown()
      if NumLines() - CurrLine() + 1 > Query(WindowRows) / 2
        ScrollToCenter()
      else
        while Query(WindowRows) - CurrRow() > NumLines() - CurrLine()
          ScrollUp()
        endwhile
      endif
  endcase
end current_window


proc toggle_browser_setting(integer setting)
  case setting
    when _IGNORE_CASE_
      g_cfg_ignore_case       = not g_cfg_ignore_case
      pop_message('Ignore Case is now ' +
                  iif(g_cfg_ignore_case, 'ON', 'OFF') + '.')
    when _FILTER_SPACES_
      g_cfg_filter_whitespace = not g_cfg_filter_whitespace
      pop_message('Filter Whitespace is now ' +
                  iif(g_cfg_filter_whitespace, 'ON', 'OFF') + '.')
  endcase

  g_restart_browser      = TRUE
  g_show_startup_message = TRUE
end toggle_browser_setting


proc set_minimum_match_lines(integer keystroke)
  integer old_cfg_match_lines = g_cfg_match_lines

  g_cfg_match_lines = LoByte(keystroke) - 48
  pop_message(Format('MatchLines changed from'; old_cfg_match_lines; 'to';
                     g_cfg_match_lines, '.'))
  g_restart_browser      = TRUE
  g_show_startup_message = TRUE
end set_minimum_match_lines


proc both_windows(integer action)
  integer old_window_id = WindowId()

  current_window(action)

  GotoWindow(iif(old_window_id == 1, 2, 1))
  current_window(action)

  GotoWindow(old_window_id)
end both_windows


string proc get_binary_option(integer option_value)
  return(iif(option_value, 'On', 'Off'))
end get_binary_option


proc toggle_binary_option(integer option_id)
  case option_id
    when _FILTER_SPACES_
      g_cfg_filter_whitespace = not g_cfg_filter_whitespace
    when _IGNORE_CASE_
      g_cfg_ignore_case       = not g_cfg_ignore_case
  endcase
end toggle_binary_option


proc set_cfg_integer(integer id, integer old_value)
  integer new_value = 0
  string  s     [9] = Str(old_value)

  new_value = iif(ReadNumeric(s), Max(Val(s), 1), old_value)

  case id
    when ID_MATCH_LINES
      g_cfg_match_lines    = new_value
    when ID_MSG_DURATION
      g_cfg_msg_duration   = new_value
    when ID_TIME_LIMIT
      g_cfg_time_limit     = new_value
    when ID_PROGRESS_AFTER
      g_cfg_progress_after = new_value
  endcase
end set_cfg_integer


string proc get_window_split()
  return(iif(g_cfg_window_split == SPLIT_HORIZONTALLY,
             'Horizontally', 'Vertically'))
end get_window_split


proc toggle_integer_variable(var integer integer_variable)
  integer_variable = not integer_variable
end toggle_integer_variable


string proc get_color_name(integer color_attr)
  integer color_background = color_attr  /  16
  integer color_foreground = color_attr mod 16
  string  color_name  [33] = 'Intense Bright Magenta on Magenta'
  string  color_names [46] = 'Black Blue Green Cyan Red Magenta Yellow White'

  color_name = iif(color_foreground > 7, 'Bright ' , '')
             + GetToken(color_names, ' ', (color_foreground mod 8) + 1)
             + ' on '
             + iif(color_background > 7, 'Intense ', '')
             + GetToken(color_names, ' ', (color_background mod 8) + 1)
  return(color_name)
end get_color_name


integer proc is_valid_text_color(integer color_attr)
  integer result           = TRUE
  integer background_color = color_attr  /  16
  integer foreground_color = color_attr mod 16
  if foreground_color == background_color
    result = FALSE
  endif
  return(result)
end is_valid_text_color


integer proc select_color(integer param_color, string param_prompt)
  integer background                  = 0
  string  color_name             [33] = 'Intense Bright Magenta on Magenta'
  integer cols_per_color              = (Query(ScreenCols) - 2) / 16
  integer foreground                  = 0
  integer grid_color                  = 0
  integer left_margin                 = 0
  integer mouse_background            = 0
  integer mouse_foreground            = 0
  integer old_attr                    = Set(Attr, Color(Bright White ON Black))
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

    PopWinOpen(left_margin,
               top_margin,
               left_margin + (cols_per_color * 16) + 1,
               top_margin  + (rows_per_color * 16) + 1,
               1,
               window_title,
               Color(Bright White ON Black))

    for foreground = 0 to 15 // Rows.
      for background = 0 to 15 // Columns.
        for sub_row = 1 to rows_per_color
          if foreground <> 0 // Skip a bug in the PutStrAttrXY command
          or background <> 0 // up to and including TSE 4.2.
            grid_color = background * 16 + foreground
            PutStrAttrXY(background * cols_per_color + 1,
                         foreground * rows_per_color + sub_row,
                         Format((grid_color)
                                :cols_per_color:'0':16),
                         '',
                         grid_color)
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
               Color(Bright White ON Black))
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


proc configure_color(var integer cur_attr, string target)
  integer stop_interrogation = FALSE
  integer new_attr           = cur_attr

  repeat
    new_attr = select_color(new_attr, 'Pick color for ' + target)

    if is_valid_text_color(new_attr)
      cur_attr = new_attr
      stop_interrogation = TRUE
    else
      Warn('Do not make text invisible with the same color for foreground and background.')
    endif
  until stop_interrogation
end configure_color


proc save_settings()
  integer ok = TRUE

  // Stop after the first error.

  if  write_setting_int('ColorOtherDiff'   , g_cfg_color_other      )
  and write_setting_int('ColorSelectedDiff', g_cfg_color_selected   )
  and write_setting_int('ColorIntraDiff'   , g_cfg_color_intra      )
  and write_setting_int('FilterWhitespace' , g_cfg_filter_whitespace)
  and write_setting_int('IgnoreCase'       , g_cfg_ignore_case      )
  and write_setting_int('MatchLines'       , g_cfg_match_lines      )
  and write_setting_int('MsgDuration'      , g_cfg_msg_duration     )
  and write_setting_int('ProgressAfter'    , g_cfg_progress_after   )
  and write_setting_int('SynHiInOther'     , g_cfg_synhi_in_other   )
  and write_setting_int('SynHiInSelected'  , g_cfg_synhi_in_selected)
  and write_setting_int('TimeLimit'        , g_cfg_time_limit       )
  and write_setting_int('WindowSplit'      , g_cfg_window_split     )
    NoOp()
  else
    ok = FALSE
  endif

  if ok
    pop_message('Settings saved.')
  endif
end save_settings


menu configuration_menu()
  title = 'Configuration'
  history

  'Configuration Help',
    show_help_screen(HELP_SCREEN_CONFIG_MENU, g_config_menu_origin),
    _MF_CLOSE_ALL_BEFORE_,
    'Show help for configuration menu.'

  'Look && feel',, _MF_DIVIDE_

  'Message &duration     (s)'
    [Format(g_cfg_msg_duration):9],
    set_cfg_integer(ID_MSG_DURATION, g_cfg_msg_duration),
    _MF_DONT_CLOSE_,
    'Set the number of seconds to pop up a message.'

  'Split &window'
    [get_window_split():12],
    toggle_window_split_setting(),
    _MF_DONT_CLOSE_,
    'Do not distinguish upper and lower case letters when comparing buffers.'

  'Colors for type of difference',, _MF_DIVIDE_

  'Selected'
    [get_color_name(g_cfg_color_selected):33],
    configure_color(g_cfg_color_selected, 'Selected Difference'),
    _MF_DONT_CLOSE_,
    'Select the color for a currently selected difference.'

  'with syntax hiliting'
    [iif(g_cfg_synhi_in_selected, 'Yes', 'No'):3],
    toggle_integer_variable(g_cfg_synhi_in_selected),
    _MF_DONT_CLOSE_,
    'Use syntax hiliting for the currently selected difference.'

  'Other'
    [get_color_name(g_cfg_color_other):33],
    configure_color(g_cfg_color_other, 'Not-Selected Differences'),
    _MF_DONT_CLOSE_,
    'Select the color for not-selected differences.'

  'with syntax hiliting'
    [iif(g_cfg_synhi_in_other, 'Yes', 'No'):3],
    toggle_integer_variable(g_cfg_synhi_in_other),
    _MF_DONT_CLOSE_,
    'Use syntax hiliting for not-selected differences.'

  'Intra-line changed words'
    [get_color_name(g_cfg_color_intra):33],
    configure_color(g_cfg_color_intra, 'Intra-Line Word Differences'),
    _MF_DONT_CLOSE_,
    'Select the color for changed characters within a matching diff line pair.'

  'Running the compare',, _MF_DIVIDE_

  '&Filter whitespace'
    [get_binary_option(g_cfg_filter_whitespace):3],
    toggle_binary_option(_FILTER_SPACES_),
    _MF_DONT_CLOSE_,
    'Do not distinguish multiple whitespace characters when comparing buffers.'

  '&Ignore case'
    [get_binary_option(g_cfg_ignore_case):3],
    toggle_binary_option(_IGNORE_CASE_),
    _MF_DONT_CLOSE_,
    'Do not distinguish upper and lower case letters when comparing buffers.'

  'Minimum &matching lines'
    [Format(g_cfg_match_lines):9],
    set_cfg_integer(ID_MATCH_LINES, g_cfg_match_lines),
    _MF_DONT_CLOSE_,
    'Set the minimum number of consecutive matching lines required.'

  'Start &progress after (s)'
    [Format(g_cfg_progress_after):9],
    set_cfg_integer(ID_PROGRESS_AFTER, g_cfg_progress_after),
    _MF_DONT_CLOSE_,
    "Number of seconds after which a compare should start showing its progress."

  'Stop  &compare  after (s)'
    [Format(g_cfg_time_limit):9],
    set_cfg_integer(ID_TIME_LIMIT, g_cfg_time_limit),
    _MF_DONT_CLOSE_,
    'Number of seconds after which to stop a compare.'

  '',, _MF_DIVIDE_

  '&Save settings, exit configuration',
    save_settings(),,
    'Save the current settings and exit the configuration menu.'

end configuration_menu


proc configure(integer origin)
  integer old_cfg_filter_whitespace = g_cfg_filter_whitespace
  integer old_cfg_ignore_case       = g_cfg_ignore_case
  integer old_cfg_match_lines       = g_cfg_match_lines
  integer old_cfg_window_split      = g_cfg_window_split

  g_config_menu_origin = origin

  repeat
    configuration_menu()
  until not MenuOption()
     or MenuStr(configuration_menu, MenuOption()) == 'Save settings, exit configuration'

  if g_cfg_filter_whitespace <> old_cfg_filter_whitespace
  or g_cfg_ignore_case       <> old_cfg_ignore_case
  or g_cfg_match_lines       <> old_cfg_match_lines
    g_restart_browser      = TRUE
    g_show_startup_message = TRUE
  endif

  if g_cfg_window_split      <> old_cfg_window_split
    if origin == FROM_BROWSER
      toggle_window_split(FALSE)
    endif
  endif
end configure


proc recolor_bg_only(integer new_attr, var string attrs)
  integer i = 0

  for i = 1 to Length(attrs)
    attrs[i] = Chr((new_attr / 16) * 16 + Asc(attrs[i]) mod 16)
  endfor
end recolor_bg_only


proc recolor_fg_and_bg(integer new_attr, var string attrs)
  attrs = Format('':Length(attrs):Chr(new_attr))
end recolor_fg_and_bg


// Apply intra-line word-diff highlighting.
// Called after the block color has already been applied to row_attrs.
// Compares the text of this line against its counterpart in the other buffer
// and highlights individual character positions that differ.
// Only applies when the diff block is a 1:1 line mapping (single line on each
// side, or positionally matched lines within equal-sized blocks).
proc recolor_intra_line(integer in_line_number,
                        integer other_buf_id,
                        integer other_line_number,
                        var string row_attrs)
  integer col              = 0
  string  other_text [255] = ''
  string  this_text  [255] = ''
  integer this_len         = 0
  integer other_len        = 0
  integer max_len          = 0

  if g_cfg_color_intra == 0
    return()
  endif

  PushLocation()

  // Read this buffer's line text (source buffer depends on which window)
  GotoBufferId(iif(other_buf_id == g_browse_in2_id, g_browse_in1_id, g_browse_in2_id))
  GotoLine(in_line_number)
  this_text = GetText(1, 255)
  this_len  = Length(this_text)

  // Read the counterpart line from the other buffer
  GotoBufferId(other_buf_id)
  GotoLine(other_line_number)
  other_text = GetText(1, 255)
  other_len  = Length(other_text)

  PopLocation()

  max_len = iif(this_len > other_len, this_len, other_len)

  for col = 1 to Length(row_attrs)
    if col > max_len
      break
    endif
    if col > this_len
      row_attrs[col] = Chr(g_cfg_color_intra)
    elseif col > other_len
      row_attrs[col] = Chr(g_cfg_color_intra)
    elseif this_text[col] <> other_text[col]
      row_attrs[col] = Chr(g_cfg_color_intra)
    endif
  endfor
end recolor_intra_line


proc recolor_line(    integer in_line_number,
                  var integer first_time,
                  var string  row_attrs)
  integer buf1_from    = 0
  integer buf1_to      = 0
  integer buf2_from    = 0
  integer buf2_to      = 0
  integer buf1_size    = 0
  integer buf2_size    = 0
  integer other_buf_id = 0
  integer other_line   = 0
  integer out_pos_from = 0
  integer out_pos_to   = 0
  integer this_offset  = 0

  PushLocation()
  GotoBufferId(g_out_id)

  if first_time
    BegFile()
    first_time = FALSE
  endif

  if WindowId() == 1
    out_pos_from = 2
    out_pos_to   = 14
  else
    out_pos_from = 26
    out_pos_to   = 38
  endif

  while in_line_number > Val(GetText(out_pos_to, 12))
  and   Down()
    NoOp()
  endwhile

  if  in_line_number >= Val(GetText(out_pos_from, 12))
  and in_line_number <= Val(GetText(out_pos_to  , 12))
    if CurrLine() == g_out_line
      if g_cfg_synhi_in_selected
        recolor_bg_only  (g_cfg_color_selected, row_attrs)
      else
        recolor_fg_and_bg(g_cfg_color_selected, row_attrs)
      endif
    else
      if g_cfg_synhi_in_selected
        recolor_bg_only  (g_cfg_color_other   , row_attrs)
      else
        recolor_fg_and_bg(g_cfg_color_other   , row_attrs)
      endif
    endif

    // Intra-line word diff: only when block sizes match (equal number of
    // changed lines on each side), so lines can be paired 1:1 by offset.
    if g_cfg_color_intra <> 0
      buf1_from = Val(GetText( 2, 12))
      buf1_to   = Val(GetText(14, 12))
      buf2_from = Val(GetText(26, 12))
      buf2_to   = Val(GetText(38, 12))
      buf1_size = buf1_to - buf1_from
      buf2_size = buf2_to - buf2_from
      if buf1_size == buf2_size and buf1_size >= 0
        if WindowId() == 1
          this_offset  = in_line_number - buf1_from
          other_buf_id = g_browse_in2_id
          other_line   = buf2_from + this_offset
        else
          this_offset  = in_line_number - buf2_from
          other_buf_id = g_browse_in1_id
          other_line   = buf1_from + this_offset
        endif
        if other_line > 0
          recolor_intra_line(in_line_number, other_buf_id, other_line, row_attrs)
        endif
      endif
    endif
  endif

  PopLocation()
end recolor_line


proc recolor_window(integer window_id)
  integer first_time               = TRUE
  integer in_line_number           = 0
  integer old_window_id            = WindowId()
  string  row_attrs [MAXSTRINGLEN] = ''
  integer row_length               = 0
  integer row_number               = 0
  string  row_text  [MAXSTRINGLEN] = ''

  GotoWindow(window_id)

  in_line_number = CurrLine() - CurrRow()  // Line before 1st window line.

  for row_number = 1 to Query(WindowRows)
    in_line_number = in_line_number + 1
    row_length  = GetStrAttrXY(Query(WindowX1),
                               Query(WindowY1) + row_number - 1,
                               row_text,
                               row_attrs,
                               Query(WindowCols))
    if row_length
      recolor_line(in_line_number, first_time, row_attrs)

      PutStrAttrXY(Query(WindowX1),
                   Query(WindowY1) + row_number - 1,
                   row_text,
                   row_attrs,
                   Query(WindowCols))
    endif
  endfor

  GotoWindow(old_window_id)
end recolor_window


proc recolor_screen()
  UpdateDisplay(_ALL_WINDOWS_REFRESH_)
  recolor_window(1)
  recolor_window(2)

  if Query(ShowHelpLine)
    VGotoXYAbs(1, iif(Query(StatusLineAtTop), Query(ScreenRows), 1))
    PutHelpLine(Format(Format(
' {F1}:Hel{p} {K}eys {I}gnoreCase {F}ilter{W}hitespace {1}-{9}:MatchLines {F10}:{C}onfigure'):
                       Query(ScreenCols) * -1))
  endif
end recolor_screen


proc rerecolor_screen()
  UnHook(rerecolor_screen)
  recolor_screen()

  if g_show_startup_message
    pop_message(Format(g_out_num_lines; 'difference',
                       iif(g_out_num_lines == 1, '', 's'), '.'))
    g_show_startup_message = FALSE
  endif
end rerecolor_screen


proc browse(integer in1_id, integer in2_id)
  string  action [MAX_ACTION_LEN] = ''
  integer key_code                = 0
  string  key_name  [MAX_KEY_LEN] = ''
  integer prev_key_code           = 0

  g_browse_in1_id = in1_id
  g_browse_in2_id = in2_id

  PushBlock()
  UnMarkBlock()
  OneWindow()

  if g_cfg_window_split == SPLIT_HORIZONTALLY
    HWindow()
  else
    VWindow()
  endif

  GotoWindow(1)
  GotoBufferId(in1_id)
  GotoWindow(2)
  GotoBufferId(in2_id)

  repeat
    recolor_screen()
    Hook(_NONEDIT_IDLE_, rerecolor_screen)
    key_code = GetKey()
    UnHook(rerecolor_screen)
    g_double_keystroke = key_code == prev_key_code

    key_name = KeyName(key_code)

    if (key_name in 'a' .. 'z')
      key_name = Upper(key_name)
    endif

    action = GetBufferStr(key_name, MACRO_ID)

    case action
      when 'Show main help screen'
        show_help_screen(HELP_SCREEN_MAIN, FROM_BROWSER)
      when 'Show keys help screen'
        // show_help_screen(HELP_SCREEN_ACTIONS, FROM_BROWSER)
        show_action_list(FROM_BROWSER)
      when 'Toggle ignore case'
        toggle_browser_setting(_IGNORE_CASE_)
      when 'Toggle filter whitespace'
        toggle_browser_setting(_FILTER_SPACES_)
      when 'Set minimum match lines'
        set_minimum_match_lines(key_code)
      when 'Configure settings'
        configure(FROM_BROWSER)
      when 'Toggle selected window'
        GotoWindow(iif(WindowId() == 1, 2, 1))
      when 'Toggle window split type'
        toggle_window_split(TRUE)
      when 'Find first difference'
        find_difference(FIND_FIRST)
      when 'Find last difference'
        find_difference(FIND_LAST)
      when 'Find next difference'
        find_difference(FIND_NEXT)
      when 'Find previous difference'
        find_difference(FIND_PREVIOUS)
      when 'Move cursors to begin'
        both_windows(MOVE_BEGIN)
      when 'Move cursors to end'
        both_windows(MOVE_END)
      when 'Move cursors page up'
        both_windows(MOVE_PAGE_UP)
      when 'Move cursors page down'
        both_windows(MOVE_PAGE_DOWN)
      when 'Move cursors up'
        both_windows(MOVE_UP)
      when 'Move cursors down'
        both_windows(MOVE_DOWN)
      when 'Move cursors left'
        both_windows(MOVE_LEFT)
      when 'Move cursors right'
        both_windows(MOVE_RIGHT)
      when 'Move cursor to begin'
        current_window(MOVE_BEGIN)
      when 'Move cursor to end'
        current_window(MOVE_END)
      when 'Move cursor page up'
        current_window(MOVE_PAGE_UP)
      when 'Move cursor page down'
        current_window(MOVE_PAGE_DOWN)
      when 'Move cursor up'
        current_window(MOVE_UP)
      when 'Move cursor down'
        current_window(MOVE_DOWN)
      when 'Move cursor left'
        current_window(MOVE_LEFT)
      when 'Move cursor right'
        current_window(MOVE_RIGHT)
      when 'Escape'
        NoOp()
      otherwise
        Warn('Program error: Unknown action "', action, '".')
    endcase

    prev_key_code = key_code
  until g_restart_browser
     or action == "Escape"

  PopBlock()

  if not g_restart_browser
    pop_message('Stopped.')
  endif
end browse


proc load_disk_file(string file_fqn)
  integer i                      = 0
  string  new_fqn [MAXSTRINGLEN] = ''
  string  prefix            [12] = ''

  PushLocation()

  //  g_tmp_buffer_created is set to TRUE if the buffer WILL BE created.
  g_tmp_buffer_created = (GetBufferId() == GetBufferId(file_fqn))

  if g_tmp_buffer_created
    g_in1_id = NewFile()
    if g_in1_id
      if LoadBuffer(file_fqn)
        repeat
          i       = i + 1
          prefix  = 'Disk' + iif(i == 1, '', '(' + Str(i) + ')') + ':'
          new_fqn = prefix + file_fqn
        until not GetBufferId(new_fqn)

        ChangeCurrFilename(new_fqn, CCF_FLAGS)
        FileChanged(FALSE)
        BrowseMode(TRUE)
      else
        PopLocation()
        AbandonFile(g_in1_id)
        PushLocation()
        g_in1_id = 0
      endif
    else
      g_tmp_buffer_created = FALSE
    endif
  else
    g_in1_id = EditThisFile(file_fqn, _DONT_PROMPT_)
  endif

  if not g_in1_id
    MsgBox('Error loading disk file:',
           file_fqn,
            _OK_)
  endif

  PopLocation()
end load_disk_file


// Loads a second disk file into a new temp buffer for Compare2DiskFiles mode.
// Sets g_in2_id and g_tmp_buffer2_created.
proc load_disk_file2(string file_fqn)
  integer i                      = 0
  string  new_fqn [MAXSTRINGLEN] = ''
  string  prefix            [12] = ''

  PushLocation()

  g_tmp_buffer2_created = (GetBufferId() == GetBufferId(file_fqn))

  if g_tmp_buffer2_created
    g_in2_id = NewFile()
    if g_in2_id
      if LoadBuffer(file_fqn)
        repeat
          i       = i + 1
          prefix  = 'Disk' + iif(i == 1, '', '(' + Str(i) + ')') + ':'
          new_fqn = prefix + file_fqn
        until not GetBufferId(new_fqn)

        ChangeCurrFilename(new_fqn, CCF_FLAGS)
        FileChanged(FALSE)
        BrowseMode(TRUE)
      else
        PopLocation()
        AbandonFile(g_in2_id)
        PushLocation()
        g_in2_id = 0
      endif
    else
      g_tmp_buffer2_created = FALSE
    endif
  else
    g_in2_id = EditThisFile(file_fqn, _DONT_PROMPT_)
  endif

  if not g_in2_id
    MsgBox('Error loading disk file:',
           file_fqn,
            _OK_)
  endif

  PopLocation()
end load_disk_file2


proc set_2_buffers()
  PushLocation()
  NextFile(_DONT_LOAD_)
  g_in1_id = GetBufferId()
  PopLocation()
end set_2_buffers


proc set_buffer_and_its_disk_file()
  load_disk_file(CurrFilename())
end set_buffer_and_its_disk_file


proc select_and_set_disk_file()
  string in1_fqn [MAXSTRINGLEN] = SplitPath(CurrFilename(), _DRIVE_|_PATH_)

  if AskFilename('Compare current buffer to?',
                 in1_fqn,
                 _FULL_PATH_|_MUST_EXIST_,
                 GetFreeHistory(MACRO_NAME + ':AskFilename'))
    load_disk_file(in1_fqn)
  endif
end select_and_set_disk_file


proc select_and_set_another_buffer()
  integer buffer_counter = 0
  integer lst_id         = 0
  integer org_id         = GetBufferId()

  lst_id = CreateTempBuffer()
  PrevFile(_DONT_LOAD_)

  repeat
    buffer_counter = buffer_counter + 1
    if GetBufferId() <> org_id
      AddLine(Format(GetBufferId():10;CurrFilename()), lst_id)
    endif
  until not NextFile(_DONT_LOAD_)
     or buffer_counter >= NumFiles()

  GotoBufferId(lst_id)
  BegFile()

  if List('Pick a buffer to compare the current buffer to', LongestLineInBuffer())
    g_in1_id = Val(GetText(1, 10))
  endif

  GotoBufferId(org_id)
  AbandonFile(lst_id)
end select_and_set_another_buffer


integer proc get_start_up_option_flag(integer menu_option)
  integer flag = _MF_CLOSE_ALL_BEFORE_|_MF_DISABLED_|_MF_GRAYED_|_MF_SKIP_

  case menu_option

    when START_UP_MENU_2_BUFFERS
      if NumFiles() == 2
        flag = _MF_CLOSE_ALL_BEFORE_|_MF_ENABLED_
      endif

    when START_UP_MENU_CHANGED_BUFFER
      if       FileChanged()
      and      FileExists(CurrFilename())
      and not (FileExists(CurrFilename()) & _DIRECTORY_)
        flag = _MF_CLOSE_ALL_BEFORE_|_MF_ENABLED_
      endif

    when START_UP_MENU_SELECT_BUFFER
      if NumFiles() > 2
        flag = _MF_CLOSE_ALL_BEFORE_|_MF_ENABLED_
      endif

  endcase

  return(flag)
end get_start_up_option_flag


menu start_up_menu()
  title = 'Start up ...'
  history

  'Compare the only &2 buffers',
    set_2_buffers(),
    get_start_up_option_flag(START_UP_MENU_2_BUFFERS),
    'There are exacly 2 buffers: Compare them.'

  'Compare the chan&ged current buffer to its disk file',
    set_buffer_and_its_disk_file(),
    get_start_up_option_flag(START_UP_MENU_CHANGED_BUFFER),
    'The current buffer is changed: Compare it to its disk file.'

  'Compare the current buffer to a &disk file ...',
    select_and_set_disk_file(),,
    'Select a disk file and compare the current buffer to it.'

  'Compare the current buffer to another &buffer ...',
    select_and_set_another_buffer(),
    get_start_up_option_flag(START_UP_MENU_SELECT_BUFFER),
    'Compare the current buffer to another buffer ...'

  'Configuration',, _MF_DIVIDE_

  '&Configure ',
    configure(FROM_START_UP),,
    "Configure the tool's settings, which can also be done from its browser."

  'Help',, _MF_DIVIDE_

  '&Key list',
    show_action_list(FROM_START_UP),,
    // show_help_screen(HELP_SCREEN_ACTIONS, FROM_START_UP),,
    'Show key list'

  'General hel&p',
    show_help_screen(HELP_SCREEN_MAIN, FROM_START_UP),,
    'Show general help'
end start_up_menu


proc WhenPurged()
  string  action [MAX_ACTION_LEN] = ''
  integer key_code                = 0
  string  key_name  [MAX_KEY_LEN] = ''
  integer ok                      = TRUE

  if g_keys_were_changed
    if      LoadProfileSection(KEYS_SECTION)
    and not RemoveProfileSection(KEYS_SECTION)
      to_beep_or_not_to_beep()
      Warn(MACRO_NAME; 'failed to delete old key configuration from file "tse.ini".')
      ok = FALSE
    endif

    if ok
      for key_code = 1 to 65535
        key_name = KeyName(key_code)
        action   = GetBufferStr(key_name, MACRO_ID)

        if action <> ''
          if (key_name in 'a' .. 'z')
            key_name = Upper(key_name)
          endif

          if not write_key_str(key_name, action)
            ok = FALSE
            break
          endif
        endif
      endfor
    endif

    if ok
      pop_message(Format('Saved changed keys.'))
    endif
  endif

  AbandonFile(ACTION_LIST_ID)
  AbandonFile(KEY_LIST_ID)
  AbandonFile(MACRO_ID)
end WhenPurged


proc WhenLoaded()
  string action [MAX_ACTION_LEN] = ''
  string key_name  [MAX_KEY_LEN] = ''

  MACRO_NAME       = SplitPath(CurrMacroFilename(), _NAME_)
  SETTINGS_SECTION = MACRO_NAME + ':Configuration'
  KEYS_SECTION     = MACRO_NAME + ':KeysToActions'

  PushLocation()

  ACTION_LIST_ID   = CreateTempBuffer()
  ChangeCurrFilename(MACRO_NAME + ':ActionList', CCF_FLAGS)

  KEY_LIST_ID      = CreateTempBuffer()
  ChangeCurrFilename(MACRO_NAME + ':KeyList'   , CCF_FLAGS)

  MACRO_ID         = CreateTempBuffer()
  ChangeCurrFilename(MACRO_NAME + ':Helper'    , CCF_FLAGS)

  if LoadProfileSection(KEYS_SECTION)
    // Load configured browser keys.
    while GetNextProfileItem(key_name, action)
      SetBufferInt(action  , TRUE  , MACRO_ID)
      // A profile cannot store same key in upeer and lower case,
      // so we make it a rule they are synonyms for single letter keys.
      if (key_name in 'a' .. 'z')
        SetBufferStr(Upper(key_name), action, MACRO_ID)
      else
        SetBufferStr(key_name, action, MACRO_ID)
      endif
    endwhile
  else
    // Load default browser keys.
    PushBlock()
    InsertData(default_actions_and_keys)
    PopBlock()
    install_actions_and_keys(FALSE)
  endif

  // Add immutable browser keys.
  EmptyBuffer()
  PushBlock()
  InsertData(immutable_actions_and_keys)
  PopBlock()
  install_actions_and_keys(TRUE)

  // Load action display template
  EmptyBuffer()
  PushBlock()
  InsertData(action_display_template)
  PopBlock()

  PopLocation()

  g_cfg_color_other       = GetProfileInt(SETTINGS_SECTION, 'ColorOtherDiff'   , Query(HiliteAttr))
  g_cfg_color_selected    = GetProfileInt(SETTINGS_SECTION, 'ColorSelectedDiff', Query(BlockAttr))
  g_cfg_color_intra       = GetProfileInt(SETTINGS_SECTION, 'ColorIntraDiff'   , Color(Bright Yellow ON Red))
  g_cfg_filter_whitespace = GetProfileInt(SETTINGS_SECTION, 'FilterWhitespace' , TRUE)
  g_cfg_ignore_case       = GetProfileInt(SETTINGS_SECTION, 'IgnoreCase'       , TRUE)
  g_cfg_match_lines       = GetProfileInt(SETTINGS_SECTION, 'MatchLines'       , 2)
  g_cfg_msg_duration      = GetProfileInt(SETTINGS_SECTION, 'MsgDuration'      , 2)
  g_cfg_progress_after    = GetProfileInt(SETTINGS_SECTION, 'ProgressAfter'    , 5)
  g_cfg_synhi_in_other    = GetProfileInt(SETTINGS_SECTION, 'SynHiInOther'     , OFF)
  g_cfg_synhi_in_selected = GetProfileInt(SETTINGS_SECTION, 'SynHiInSelected'  , Query(synhiinblocks))
  g_cfg_time_limit        = GetProfileInt(SETTINGS_SECTION, 'TimeLimit'        , 86400)
  g_cfg_window_split      = GetProfileInt(SETTINGS_SECTION, 'WindowSplit'      , SPLIT_VERTICALLY)

  Hook(_ON_ABANDON_EDITOR_, WhenPurged)
end WhenLoaded


proc Main()
  string  file1    [MAXSTRINGLEN] = ''
  string  file2    [MAXSTRINGLEN] = ''
  integer in2_id                  = GetBufferId()
  integer ok                      = TRUE
  string  options              [4] = ''
  integer rc                      = 0
  integer sep_pos                 = 0

  if Query(MacroCmdLine) == ''
    repeat
      UpdateDisplay()
      g_config_menu_origin = _NONE_
      start_up_menu()
    until g_in1_id <> 0
       or (not MenuOption() and g_config_menu_origin == _NONE_)
  else
    case Lower(Query(MacroCmdLine))
      when 'comparetodiskfile'
        if       FileExists(CurrFilename())
        and not (FileExists(CurrFilename()) & _DIRECTORY_)
          set_buffer_and_its_disk_file()
        else
          MsgBox('Error: No disk file exists for the current buffer:',
                 Format('Id  =', GetBufferId() , '.', Chr(13),
                        'Name=', CurrFilename(), '.'         ))
          ok = FALSE
        endif
      when 'comparetheonly2buffers'
        if NumFiles() == 2
          set_2_buffers()
        else
          MsgBox(MACRO_NAME,
                 Format('Cannot "Compare the only 2 buffers" for'; NumFiles();
                        'buffers.'))
          ok = FALSE
        endif
      otherwise
        // Try to interpret the command line as two space-separated disk file
        // paths: scan from the right for the last space position such that
        // everything to its right is an existing file (= file2), and
        // everything to its left is also an existing file (= file1).
        sep_pos = Length(Query(MacroCmdLine))
        while sep_pos > 1
          if SubStr(Query(MacroCmdLine), sep_pos, 1) == ' '
            file1 = SubStr(Query(MacroCmdLine), 1, sep_pos - 1)
            file2 = SubStr(Query(MacroCmdLine), sep_pos + 1, MAXSTRINGLEN)
            if      FileExists(file2)
            and not (FileExists(file2) & _DIRECTORY_)
            and     FileExists(file1)
            and not (FileExists(file1) & _DIRECTORY_)
              break
            endif
            file1 = ''
            file2 = ''
          endif
          sep_pos = sep_pos - 1
        endwhile
        if file1 == '' or file2 == ''
          MsgBox(MACRO_NAME,
                 'Illegal macro parameter(s):' + Chr(13) +
                 Query(MacroCmdLine))
          ok = FALSE
        else
          load_disk_file(file1)
          // UnMarkBlock() // [kn, ri, we, 11-03-2026 18:13:32]
          if g_in1_id
            load_disk_file2(file2)
            // UnMarkBlock() // [kn, ri, we, 11-03-2026 18:13:32]
            if g_in2_id
              in2_id = g_in2_id
            else
              ok = FALSE
            endif
          else
            ok = FALSE
          endif
        endif
    endcase
  endif

  if ok
    if g_in1_id
      g_out_id = CreateTempBuffer()
      ChangeCurrFilename(MACRO_NAME + ':Out', CCF_FLAGS)
    else
      ok = FALSE
    endif
  endif

  if ok
    repeat
      g_restart_browser = FALSE
      options           = Format(iif(g_cfg_filter_whitespace, 'f', ''),
                                 iif(g_cfg_ignore_case      , 'i', ''),
                                     g_cfg_match_lines                )
      pop_msg_open(MACRO_NAME, 'Comparing ...')
      rc = Val(cmpbuf(Format(g_in1_id; in2_id; g_out_id;
                             'options=', options;
                             'start='  , g_cfg_progress_after;
                             'stop='   , g_cfg_time_limit)))
      pop_msg_close()

      if rc
        PushLocation()
        GotoBufferId(g_out_id)
        while lFind('=', '^')
        or    lFind('=', 'g^')
          KillLine()
        endwhile
        BegFile()
        g_out_num_lines = NumLines()
        PopLocation()

        browse(g_in1_id, in2_id)
      endif
    until not rc
       or not g_restart_browser
  endif

  if g_tmp_buffer_created
    GotoWindow(2)
    OneWindow()
    AbandonFile(g_in1_id)
  endif

  if g_tmp_buffer2_created
    AbandonFile(g_in2_id)
  endif

  PurgeMacro(CurrMacroFilename())
end Main

