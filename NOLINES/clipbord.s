/*
   Macro:   ClipBord.
   Author:  Carlo Hogeveen (hyphen@xs4all.nl).
   Date:    5 April 1999.

   Version: 2.
   Date:    28 June 1998.

   Purpose: Push and pop clipboards onto and from a stack.

            You typically use these at the begin and end of a (piece of)
            macro to ensure the macro cannot change the clipboard.

            The idea is the same as that behind the PushPosition,
            PopPosition, Pushblock and PopBlock commands.

   Usage:   execmacro("clipbord push")
            ...
            execmacro("clipbord pop")

            Because I like my macroes to be executable from the PotPourri
            as well (because I can document them there), it is also possible
            to start ClipBord without parameters, and then it will ask
            whether to push or pop a clipboard.

   Install: First download and install Global.zip and MacPar3.zip.

            Then copy ClipBord.s to TSE's "mac" directory, and compile it.

   Notes:   The maximum number of clipboards that can be pushed is only
            limited by the available memory and TSE's built-in limits.

            (  One of those built-in limits denies us pushing more than
               65536 clipboards. Tragic, isn't it?                      )

            This macro contains an excessive amount of checks and warnings.

            You get a warning if you pop more clipboards than you have pushed.
            This warning can be temporarily turned off with TSE's editor
            variable "MsgLevel".

            The macro always remains in memory for speed and resource
            reasons, because I expect to use it a lot and in frequently
            used macroes.

   History: Version 2 uses Global.zip to avoid a TSE bug,
            and it uses MacPar3.zip (an updated version) for the same reason.
*/

#include["global.si"]

#include["initpar.si"]

integer clipbord_top = 0

proc push_clipbord()
   integer old_uap = Set(UnMarkAfterPaste, OFF)
   integer clipbord_id = 0
   clipbord_top = clipbord_top + 1
   clipbord_id = get_global_int("clipbord_id_" + Str(clipbord_top))
   if clipbord_id == 0
      clipbord_id = CreateBuffer("clipbord_stack_element_" + Str(clipbord_top),
                    _SYSTEM_)
      if clipbord_id
         set_global_int("clipbord_id_" + Str(clipbord_top), clipbord_id)
      else
         Warn("ClipBord: cannot create stack element")
      endif
   endif
   if GotoBufferId(clipbord_id)
   or GetBufferId() == clipbord_id
      UnMarkBlock()
      EmptyBuffer()
      if Paste()
      or (   NumLines()    == 0
         and CurrLineLen() == 0)
         set_global_int("clipbord_type_" + Str(clipbord_top), isBlockMarked())
      else
         Warn("ClipBord: cannot paste")
      endif
   else
      Warn("ClipBord: stack element to push into not found ")
   endif
   Set(UnMarkAfterPaste, old_uap)
end

proc pop_clipbord()
   integer clipbord_id = 0
   integer clipbord_type = 0
   if clipbord_top == 0
      if Query(MsgLevel) <> _NONE_
         Warn("ClipBord: there are no more clipboards to pop")
      endif
   else
      clipbord_id = get_global_int("clipbord_id_" + Str(clipbord_top))
      if GotoBufferId(clipbord_id)
      or GetBufferId() == clipbord_id
         clipbord_type = get_global_int("clipbord_type_" + Str(clipbord_top))
         if clipbord_type
            case clipbord_type
               when _LINE_
                  MarkLine(1, NumLines())
               when _COLUMN_
                  MarkColumn(1, 1, NumLines(), CurrLineLen())
               when _INCLUSIVE_, _NONINCLUSIVE_
                  BegFile()
                  MarkChar()
                  EndFile()
               otherwise
                  Warn("Clipbord: unknown blocktype")
            endcase
            if Copy()
               EmptyBuffer()
            else
               Warn("ClipBord: cannot copy")
            endif
         else
            if GotoBufferId(Query(ClipBoardId))
            or GetBufferId() == Query(ClipBoardId)
               EmptyBuffer()
            else
               Warn("Clipbord: cannot locate clipboard buffer")
            endif
         endif
      else
         Warn("ClipBord: stack element to pop from not found")
      endif
      clipbord_top = clipbord_top - 1
   endif
end

menu clipbord_menu()
   TITLE = "Push or pop a clipboard onto or from the clipboard stack"
   X = 5
   Y = 5
   NOKEYS
   "P&ush clipboard onto the stack", push_clipbord(),, "Push the current content of the clipboard onto the clipboard stack"
   "P&op  clipboard from the stack", pop_clipbord() ,, "Pop a new content for the clipboard from the clipboard stack"
end

proc Main()
   integer org_id = GetBufferId()
   string action [5] = Lower(poppar())
   PushBlock()
   initpar()
   case action
      when ""
         clipbord_menu()
      when "push"
         push_clipbord()
      when "pop"
         pop_clipbord()
      otherwise
         Warn("ClipBord macro called with illegal parameter")
   endcase
   GotoBufferId(org_id)
   PopBlock()
end
