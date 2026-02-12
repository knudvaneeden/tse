/*
  Extension       PickList
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   TSE v4.41.44 upwards; GUI, Console, Linux.
  Version         v0.6   BETA   8 Dec 2022


  This extension shrinks a TSE picklist to only those files, that contain a
  typed search string.

  In TSE a picklist is a file list with a known TSE format.
  It is used by the File Open menu, TSE's file manager, and more.

  EXCEPTION
  If the picklist was started from the File Open prompt with the <TAB> key
  instead of the <ENTER> or <F10> key, then the picklist is not enhanced and
  works the old way.

  You can configure PickList to do the same for SOME regular lists:

  DANGER!
  It depends on the regular list whether this is safe.
  It it NOT SAFE for a regular list that is not refreshed every time,
  or a regular list that a user can update, like Potpourri's list.
  Known safe lists: List Open, View Finds.
  Known unsafe lists: List Recent, Potpourri.



  INSTALLATION

  Copy this file into TSE's "mac" folder and compile it there,
  for example by opening the file in TSE and applying the Macro Compile menu.

  Add "PickList" to TSE's Macro AutoLoad List menu, and restart TSE.

  The extensions "PickList" and "PickListFind" should not both be installed.
  Delete "PickListFind" from TSE's Macro AutoloadList menu if you installed it.

  WARNING:
  Make a backup of TSE before configuring a regular list that is not verified
  as safe here.

  Menu -> Macro -> Execute PickList to configure PickList to also work for
  specific regular lists. Regular lists are lists for which PickList does not
  work out of the box.

  Regular lists can be configured by a unique part of their title.
  For example:
    Safe List           Title part (case-sensitive and spaces-sensitive)
    =========           ==========
    List Open menu      " Buffer List "
    View Finds result   " View Finds "

  Known UNSAFE regular lists are:
    List Recent: A shrunken list of recent files is permanently saved.
    Potpourri  : A shrunken and modified macro list is permanently saved.


  KNOWN BUGS

  Using tagged files in combination with (un)shrinking a list has
  counter-intuitive results.
  The worst one is files, that became invisible, still being tagged.
  I am looking into this.

  If you scroll the picklist horizontally, the hiliting of the search string
  will not follow. Currently TSE's HiliteFoundText() function is used, which
  has this documented behavior. I do not plan to fix this one.

  In List Open the typed string is often not hilited.
  This is caused by a programming choice in the ListOpen.s macro.
  If the two lines "BufferVideo()" and "UnBufferVideo()" are removed,
  then PickList will hilite the typed string.
  For now you can choose to change and recompile ListOpen.s yourself.
  Semware will do so in the next TSE relelease.
  Currently the latest TSE release is v4.48.


  HISTORY

  v0.1   BETA   21 Nov 2022
    Initial release as a beta.
    This extension hacks TSE's picklists.
    Unforseeable side effects are expected.

  v0.2   BETA   22 Nov 2022
    Documented that at the File Open prompt the TAB key makes a picklist
    work the old way.
    Checks and documents the extension's TSE compatibility.

  v0.3   BETA   23 Nov 2022
    Fixed: v0.2 reported debug information to TSE's window title.

  v0.4   BETA   28 Nov 2022
    Fixed: If (re)entering a picklist by typing a menu letter,
           the menu letter no longer becomes a picklist search letter.
    Fixed: When selecting a subfolder in a picklist, that was shrunk by a
           search string, the subfolder's picklist no longer inherits the
           search string.
    Fixed: The search string hiliting in a picklist no longer disappears if you
           perform an action on the picklist that does not leave it.
           For example: Sorting a shrunken picklist in the TSE File Manager.

  v0.5   BETA    2 Dec 2022
    Allows PickList to work for SOME regular lists for which it is safe.

  v0.6   BETA    8 Dec 2022
    Typing any letter in one of the EditFile macro's prompts (typically y/n),
    no longer adds that letter to PickList's search string.

*/



/*
  T E C H N I C A L   B A C K G R O U N D   I N F O


  TAB KEY

    In the File Open prompt, the TAB key has a definition which disables (*)
    the _AFTER_NONEDIT_COMMAND_ hook in the following picklist.

    Reproducing PickList's same behavior without access to the
    _AFTER_NONEDIT_COMMAND_ hook would complicate this macro significantly.

    I chose to not complicate what is relatively a small straitforward macro
    with exceptions just to support a TAB-key-opened picklist in the File Open
    prompt.

    (*) One user reports that the TAB key works for PickList too.
        I have not been able to reproduce this yet.


  PICKLIST BUFFER

    TSE picklists are nice and standard.

    Because DisplayMode(_DISPLAY_PICKLIST_) is used to display a picklist,
    what we see differs wildly from the actual content of its buffer.

    Despite the buffer containing lots of characters that do not have a text
    meaning, a picklist buffer has a _NORMAL_ Buffertype().
    All its lines are 283 characters long.
    In the buffer, filenames are located in columns 18 - 272.


  REGULAR LIST BUFFER

    Regular lists are not standard at all.
    They often (!) turn out to have different behavior programmed into them.

    The friendly ones only change the lists coloring.

    The scary ones, from PickList's point of view, are the ones that do not
    refresh their content for each usage, and the ones that save
    their PickList-shrunken contents back to disk.

*/





// Start of compatibility restrictions and mitigations

#ifdef LINUX
  #define WIN32 FALSE
#endif

#ifdef WIN32
#else
   16-bit versions of TSE are not supported. You need at least TSE 4.41.44.
#endif

#ifdef EDITOR_VERSION
#else
   Editor Version is older than TSE 3.0. You need at least TSE 4.41.44.
#endif

#if EDITOR_VERSION < 4000h
   Editor Version is older than TSE 4.0. You need at least TSE 4.41.44.
#endif

#ifndef INTERNAL_VERSION
   Editor Version is older than TSE 4.41.44. You need at least TSE 4.41.44.
#endif

// End of compatibility restrictions and mitigations



// Global constants and semi-constants

string MACRO_NAME                    [MAXSTRINGLEN] = ''
string TITLES_SEARCH_STRINGS_SECTION [MAXSTRINGLEN] = ''



// Global variables

integer enhanced_list_id             = 0
integer full_list_id                 = 0
integer is_a_configured_list         = FALSE
integer is_list_key_stroke           = 0
integer list_popwinx1                = 0
string  search_string [MAXSTRINGLEN] = ''
integer title_search_strings_id      = 0



string proc unquote(string s)
  string r [MAXSTRINGLEN] = s
  if (r[1] in '"', "'")
  and r[1] == r[Length(r)]
    r = r[2:(Length(r) - 2)]
  endif
  return(r)
end unquote


integer proc go_down(integer lines_down)
  return(iif(lines_down, Down(lines_down), TRUE))
end go_down


proc nonedit_idle()
  if  search_string    <> ''
  and QueryEditState() == 96  // In a picklist or list?
  and Query(PopWinX1)  == list_popwinx1 // Not in an EditFile macro's prompt
    if DisplayMode() == _DISPLAY_PICKFILE_
      PushBlock()
      MarkColumn(1, 18, NumLines(), 272)
      if lFind(search_string, 'cgil')
      or lFind(search_string,  'gil')
        // _DISPLAY_PICKFILE_ magic:
        // Hiliting buffer columns also hilites its different screen columns.
        HiLiteFoundText()
      endif
      PopBlock()
    elseif is_a_configured_list
      if lFind(search_string, 'cgi')
      or lFind(search_string,  'gi')
        HiLiteFoundText()
      endif
    endif
  endif
end nonedit_idle


proc enhance_picklist()
  integer down_lines = 0
  integer found      = FALSE

  if enhanced_list_id
    // Restore the full picklist.
    PushBlock()
    GotoBufferId(full_list_id)
    MarkLine(1, NumLines())
    GotoBufferId(enhanced_list_id)
    EmptyBuffer()
    CopyBlock()
    PopBlock()
  else
    // Save the full picklist.
    enhanced_list_id = GetBufferId()
    PushBlock()
    MarkLine(1, NumLines())
    GotoBufferId(full_list_id)
    EmptyBuffer()
    CopyBlock()
    GotoBufferId(enhanced_list_id)
    PopBlock()
  endif

  if search_string <> ''
    PushBlock()
    if DisplayMode() == _DISPLAY_PICKFILE_
      MarkColumn(1, 18, NumLines(), 272) // The picklist filename column.
    else
      MarkLine(1, NumLines())
    endif
    GotoBlockBegin()
    repeat
      found = lFind(search_string, 'cgil')
      if found
        down_lines = 1
      else
        KillLine()
        down_lines = 0
      endif
    until NumLines() == 0
       or CurrLine() > NumLines()
       or not go_down(down_lines)
    PopBlock()
  endif

  BegFile()
end enhance_picklist


string proc get_list_title_line()
  string list_title_line [MAXSTRINGLEN] = ''
  GetStrXY(0, 0, list_title_line, MAXSTRINGLEN)
  return(list_title_line)
end get_list_title_line


integer proc is_configured_list()
  string list_title_line [MAXSTRINGLEN] = get_list_title_line()

  PushLocation()
  GotoBufferId(title_search_strings_id)
  BegFile()
  is_a_configured_list = FALSE
  repeat
    if Pos(unquote(GetText(1, MAXSTRINGLEN)), list_title_line)
      is_a_configured_list = TRUE
    endif
  until is_a_configured_list
     or not Down()
  PopLocation()

  return(is_a_configured_list)
end is_configured_list


proc stop_enhancing_list()
  enhanced_list_id = 0
  search_string    = ''
  list_popwinx1    = 0
end stop_enhancing_list


proc after_command()
  if  enhanced_list_id
  and GetBufferId() <> enhanced_list_id
    stop_enhancing_list()
  endif
end after_command


proc after_nonedit_command()
  if  (  is_list_key_stroke
      or list_popwinx1 == 0)
  and QueryEditState() == 96  // In a picklist or list.
  and (  DisplayMode() == _DISPLAY_PICKFILE_
      or is_configured_list())
    case Query(Key)
      when <BackSpace>
        search_string = search_string[1: Length(search_string) - 1]
        enhance_picklist()
      when <Enter>, <GreyEnter>
        stop_enhancing_list()
      when 32 .. 255
        search_string = search_string + Chr(Query(Key))
        enhance_picklist()
    endcase
    if list_popwinx1 == 0
      list_popwinx1 = Query(PopWinX1)
    endif
  else
    after_command()
  endif
end after_nonedit_command


proc after_getkey()
  if  QueryEditState() == 96  // In a picklist or regular list
  and Query(PopWinX1)  == list_popwinx1 // Not in an EditFile macro's prompt
  and (  DisplayMode() == _DISPLAY_PICKFILE_ // In a picklist
      or is_configured_list())
    is_list_key_stroke = TRUE
  else
    is_list_key_stroke = FALSE
  endif

  is_a_configured_list = FALSE
end after_getkey


proc get_title_search_strings()
  string item_id               [1] = '' // Dummy for now, so minimum length.
  string item_value [MAXSTRINGLEN] = ''
  PushLocation()
  GotoBufferId(title_search_strings_id)
  EmptyBuffer()
  if LoadProfileSection(TITLES_SEARCH_STRINGS_SECTION)
    while GetNextProfileItem(item_id, item_value)
      if     Pos('potpourri'  , Lower(item_value))
        Warn('Potpourri blocked in PickList config: It could corrupt potpourr.dat.')
      elseif Pos('list recent', Lower(item_value))
        Warn('List Recent blocked in PickList config: It would be saved shrunken.')
      else
        AddLine(item_value)
      endif
    endwhile
  else
    item_id = item_id // Dummy statement to pacify compiler.
  endif
  PopLocation()
end get_title_search_strings


proc add_title_search_string()
  string s[MAXSTRINGLEN] = ''

  if  Ask('New list title search string:   (Use spaces, they matter!)', s)
  and Trim(s) <> ''
  and not lFind(s, '^g$')
    if     Pos('Potpourri', s)
      Warn('Potpourri blocked from PickList config: It could corrupt potpourr.dat.')
    elseif Pos('List Recent', s)
      Warn('List Recent blocked from PickList config: It would be saved shrunken.')
    else
      if NumLines()    == 0
      or CurrLineLen() == 0
        InsertLine(QuotePath(s))
      else
        AddLine(QuotePath(s))
      endif
    endif
  endif
end add_title_search_string


proc delete_title_search_string()
  KillLine()
  if CurrLine() > NumLines()
    Up()
  endif
end delete_title_search_string


proc edit_title_search_string()
  string s[MAXSTRINGLEN] = unquote(GetText(1, MAXSTRINGLEN))
  if  Trim(s) <> ''
  and Ask('Edit list title search string:   (Use spaces, they matter!)', s)
  and Trim(s) <> ''
  and not lFind(s, '^g$')
    BegLine()
    KillToEol()
    InsertText(s)
  endif
end edit_title_search_string


Keydef list_keys
  <Ins>       add_title_search_string()
  <GreyIns>   add_title_search_string()
  <Del>       delete_title_search_string()
  <GreyDel>   delete_title_search_string()
  <Enter>     edit_title_search_string()
  <GreyEnter> edit_title_search_string()
end list_keys


proc list_cleanup()
  UnHook(list_cleanup)
  Disable(list_keys)
end list_cleanup


proc list_startup()
  UnHook(list_startup)
  Hook(_LIST_CLEANUP_, list_cleanup)
  if Enable(list_keys)
    ListFooter('{Ins}-Add {Del}-Delete {Enter}-Edit {Escape}-Save&Exit')
  endif
  while lFind('^ @$', 'gx')
    KillLine()
  endwhile
  BegFile()
  FileChanged(FALSE)
  BreakHookChain()
end list_startup


proc configure_title_search_strings()
  integer i = 0

  PushLocation()
  GotoBufferId(title_search_strings_id)

  while NumLines() < Query(ScreenRows)
    EndFile()
    AddLine()
  endwhile
  BegFile()

  Hook(_LIST_STARTUP_, list_startup)
  List('Regular Lists: Title Search Strings',
       Query(ScreenCols))

  if FileChanged()
    RemoveProfileSection(TITLES_SEARCH_STRINGS_SECTION)
    BegFile()
    repeat
      if Trim(GetText(1, MAXSTRINGLEN)) <> ''
        i = i + 1
        WriteProfileStr(TITLES_SEARCH_STRINGS_SECTION, Str(i),
                        QuotePath(GetText(1, MAXSTRINGLEN)))
      endif
    until not Down()
    BegFile()
  endif

  PopLocation()
end configure_title_search_strings


proc WhenPurged()
  AbandonFile(full_list_id)
  AbandonFile(title_search_strings_id)
end WhenPurged


proc WhenLoaded()
  MACRO_NAME                    = SplitPath(CurrMacroFilename(), _NAME_)
  TITLES_SEARCH_STRINGS_SECTION = MACRO_NAME + ':title_search_strings'

  PushLocation()
  full_list_id            = CreateTempBuffer()
  title_search_strings_id = CreateTempBuffer()
  PopLocation()

  get_title_search_strings()

  Hook(_AFTER_COMMAND_        , after_command)
  Hook(_AFTER_GETKEY_         , after_getkey)
  Hook(_AFTER_NONEDIT_COMMAND_, after_nonedit_command)
  Hook(_NONEDIT_IDLE_         , nonedit_idle         )
end WhenLoaded


proc Main()
  configure_title_search_strings()
end Main

