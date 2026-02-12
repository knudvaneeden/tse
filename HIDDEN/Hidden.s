/*
  Macro          Hidden
  Author         Carlo Hogeveen
  Website        eCarlo.nl/tse
  Version        1.3.1   4 Mar 2022
  Compatibility  Windows TSE Pro v4.0 upwards,
                 Linux TSE (Tested with Linux TSE 4.42)


  When executed this tool shows a list of all buffers in memory
  those of files as well as hidden and system buffers.

  From the list you can select a buffer:
  - A normal buffer is just switched to.
  - A hidden or system buffer is made a copy of to a normal buffer,
    and then the copy is switched to.

  The advantage of this tool over TSE's own "buffers" macro is,
  that for system and hidden buffers the "buffers" macro switches you to the
  real buffer and makes it editable, which usually is a risk instead of a
  benefit, while the Hidden tool lets you safely view a copy of those buffers.


  INSTALLATION

  Copy this file to TSE's "mac" folder, open it there with TSE,
  and apply the Macro -> Compile menu.


  USAGE

  Just execute "Hidden" as a macro, either from the Macro -> Compile menu,
  or by adding it to the PotPourri menu and executing it from there.


  HISTORY

  v1.0 ~ 13 May 2011
    Initial version

  v1.1 ~ 26 Jun 2011
    Cosmetic improvements.

  v1.2 -  9 Aug 2020
    Translated its text parts to English, and first-time published it.

  v1.3 - 29 Aug 2020
    Added some missing buffer descriptions learned from Semware's "buffers"
    macro.
    Modernized and optimized the code.

  v1.3.1 - 4 Mar 2022
    Bug fixed: Now if you select a system or hidden buffer more than once,
    its copy-buffer is refreshed.

*/


#define ID_STRING_LENGTH 10

#if EDITOR_VERSION < 4500h
  integer proc MaxBufferId()
    integer tmp_id = 0
    PushLocation()
    tmp_id = CreateTempBuffer()
    PopLocation()
    AbandonFile(tmp_id)
    return(tmp_id)
  end MaxBufferId
#endif

proc select_buffer()
  string  buf_description [MAXSTRINGLEN] = ''
  string  buf_fqn         [MAXSTRINGLEN] = ''
  integer buf_id                         = 0
  string  buf_name        [MAXSTRINGLEN] = ''
  string  buf_type        [MAXSTRINGLEN] = ''
  integer lst_id                         = 0
  integer org_id                         = GetBufferId()

  lst_id = CreateTempBuffer()
  for buf_id = 1 to MaxBufferId()
    if GotoBufferId(buf_id)
    or GetBufferId() == buf_id
      buf_fqn = CurrFilename()

      case BufferType()
        when _NORMAL_
          buf_type = 'normal'
        when _HIDDEN_
          buf_type = 'hidden'
        when _SYSTEM_
          buf_type = 'system'
        otherwise
          buf_type = '??????'
      endcase

      case buf_id
        when  1
          buf_description = 'Clipboard'
        when  2
          buf_description = 'Global variables'
        when  3
          buf_description = 'Deletion buffer'
        when  4
          buf_description = 'Loaded & public macros'
        when  5
          buf_description = 'Keyboard macros'
        when  6
          buf_description = 'History lists'
        when  7
          buf_description = 'Help Headers'
        when  8
          buf_description = 'Help Topic'
        when  9
          buf_description = 'Help Control'
        when 10
          buf_description = 'Help Index'
        when 11
          buf_description = 'Visited Dirs'
        when 12
          buf_description = 'Capture'
        when 13
          buf_description = 'Work #1'
        when 14
          buf_description = 'Work #2'
        when 15
          buf_description = 'Work #3'
        when 16
          buf_description = 'Work #4'
        when 17
          buf_description = 'Work #5'
        when 18
          buf_description = 'Work #6'
        when 19
          buf_description = 'Work #7'
        when 20
          buf_description = 'Work #8'
        when  lst_id
          buf_description = 'This list (Not selectable)'
        otherwise
          buf_description = ''
      endcase

      GotoBufferId(lst_id)
      EndFile()
      AddLine(Format(buf_id:ID_STRING_LENGTH,
                     '':3,
                     buf_type:-9,
                     buf_fqn,
                     iif(buf_fqn == '', '', '   '),
                     buf_description))
    endif
  endfor
  GotoBufferId(lst_id)
  BegFile()
  if List('Select a buffer to view its content', LongestLineInBuffer())
    buf_id          = Val (GetText( 1, ID_STRING_LENGTH))
    buf_type        = Trim(GetText(14,                9))
    buf_description = Trim(GetText(23,     MAXSTRINGLEN))
    if buf_id == lst_id
      UpdateDisplay()
      Warn('You cannot select the buffer of this list you were viewing.')
      buf_id        = org_id
    endif
  else
    buf_id          = org_id
  endif

  GotoBufferId(buf_id)
  AbandonFile(lst_id)

  if  GetBufferId() <> org_id
  and BufferType()  <> _NORMAL_
    buf_name = CurrFilename()
    if buf_description == ''
      if buf_name == ''
        buf_name = '[Copy of ' + buf_type + ' buffer ' + Str(buf_id) + ']'
      else
        buf_name = '[Copy of '
                + buf_name
                + ' ('
                + buf_type
                + ' buffer '
                + Str(buf_id)
                + ')]'
      endif
    else
      buf_name = '['
              + buf_description
              + ' (Copy of '
              + buf_type
              + ' buffer '
              + Str(buf_id)
              + ')]'
    endif
    MarkLine(1, NumLines())
    if GetBufferId(buf_name)
      GotoBufferId(GetBufferId(buf_name))
      EmptyBuffer()
    else
      CreateBuffer(buf_name)
    endif
    CopyBlock()
    UnMarkBlock()
    BegFile()
    FileChanged(FALSE)
  endif
end select_buffer

proc Main()
  integer old_hookstate = SetHookState(OFF)
  PushBlock()
  select_buffer()
  SetHookState(old_hookstate)
  PopBlock()
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main

