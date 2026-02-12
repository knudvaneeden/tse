/*
  Macro:    OnlyOneSplitLinesWarning
  Author:   Carlo.Hogeveen@xs4all.nl
  Version:  1.0  -  8 Nov 2018

  Without this macro when loading a lot of files with lines that are too long
  for TSE, then you have to press OK on the "Long lines split" warning for each
  such file.

  Let us define a user action as any action that
      starts with opening the editor or with a text editing prompt
  AND ends with closing the editor or a text editing prompt.

  Then after the first "Long lines split" warning this macro disables ALL the
  editor's other warnings for the duration of the current user action.

  Yes, this is an imperfect solution, imposed by the limits of what the macro
  language can do. Note though, that as long as there is no "Long lines split"
  warning during a user action, you still get TSE's other warnings as usual,
  and that for the next user action TSE's warnings are enabled again.

  Note:
    Only the editor's own warnings are temporarily suppressed, not those of
    any macros you might have installed.

  Installation:
    Compile this file as a macro and execute it once or permanently put it in
    your Macro AutoLoad List.
*/

integer old_msglevel            = _ALL_MESSAGES_
integer skip_all_other_warnings = FALSE

proc idle()
  if skip_all_other_warnings
    Set(MsgLevel, old_msglevel)
    skip_all_other_warnings = FALSE
  endif
end idle

proc nonedit_idle()
  string  message_attr [MAXSTRINGLEN] = ''
  string  message_text [MAXSTRINGLEN] = ''
  GetStrAttrXY(2, 2, message_text, message_attr, MAXSTRINGLEN)
  if  SubStr(message_text, 1, 18) == 'Long lines split: '
  and SubStr(message_attr, 1, 18) == Format('':18:Chr(Query(MenuTextAttr)))
  and not skip_all_other_warnings
    old_msglevel = Set(MsgLevel, _NONE_)
    skip_all_other_warnings = TRUE
  endif
end nonedit_idle

proc WhenLoaded()
  Hook(_IDLE_        , idle)
  Hook(_NONEDIT_IDLE_, nonedit_idle)
end WhenLoaded

proc Main()
  NoOp()
end Main

