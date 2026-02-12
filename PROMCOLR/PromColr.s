/*
   Macro          PromColr
   Author         Carlo.Hogeveen@xs4all.nl
   Date           24 May 2004
   Compatibility  Tse Pro 4.0 upwards

   This macro colors TSE prompts consistently with other TSE color settings,
   and will solve the viewing problem if some prompt colors are the same,
   or will let you set the prompt colors yourself.

   It changes the color of normal prompt text default to the same color as
   the current line in editing text.

   It changes the color of marked prompt text default using an algorithm
   to avoid identical colors.

   If the defaults are not to your liking, the you can configure these
   colors yourself.

   This macro can NOT change the color of a prompt title. I tried
   implementing it extensively, but it just could not be done properly.

   Installation:

      Copy this file to TSE's "mac" directory, and compile it.
      Add this macro to TSE's Macro AutoLoad List.
      Restart TSE.

   Configuration:

      Probably not necessary, because the defaults should do a good job,
      but you can do it explicitly by executing PromColr instead of just
      (auto)loading it.

      For configuring PromColr uses the macro SlctColr, which therefore
      should be pre-installed.

   Techical notes:

      Prompts without this macro:
      +  The title gets the color of MsgAttr.
         (Even before the _on_prompt_startup_ hook, so before this macro.)
      -  Normal text gets the color of MsgAttr.
      .  Marked text gets the color of BlockAttr.
         (Text is also marked if a prompt shows a previous value.)
      -  You have a viewing problem if MsgAttr matches BlockAttr.

      Prompts with this macro:
      +  The title gets the color of MsgAttr.
      +  Normal text default gets the color of CursorAttr, or otherwise
         a color you select.
      .  Marked text default gets the first color not equal to MsgAttr and
         CursorAttr and "bright white on black" from the list
         "CursorInBlockAttr, BlockAttr, HiliteAttr, MenuSelectAttr,
         MenuTextAttr, TextAttr", and otherwise a color you configure.
      +  It is highly unlikely that MsgAttr default matches BlockAttr,
         and otherwise you can do something about it.

      The macro will compile for some versions below TSE Pro 4.0,
      but in those TSE prompts do not use color attributes the same way,
      so this macro will give odd results in lower versions of TSE.
*/

integer old_msg_attr
integer new_msg_attr
integer old_cursor_attr
integer new_cursor_attr

proc prompt_startup()
   // Devious peculiarity in TSE 4.0 upwards: inside this hook marked text
   // is no longer colored with BlockAttr, but with CursorAttr!
   old_msg_attr    = Set(MsgAttr   , new_msg_attr   )
   old_cursor_attr = Set(CursorAttr, new_cursor_attr)
end

proc prompt_cleanup()
   Set(BlockAttr, old_cursor_attr)
   Set(MsgAttr  , old_msg_attr)
end

proc get_new_prompt_colors(var integer new_msg_attr,
                           var integer new_cursor_attr)
   // Note: this proc is not valid during prompts,
   // because then attributes can have different values an meanings.
   integer msg_attr    = Query(MsgAttr)
   integer cursor_attr = Query(CursorAttr)
   // Inside prompts bright white on black just never looks like marked text
   // because the prompt title is also bright white on black.
   integer title_attr  = Color(bright white ON black)
   // Get the color to use for normal text in prompts.
   if GetProfileStr("PromColr", "PromptTextAttr", "") == ""
      new_msg_attr = Query(CursorAttr)
   else
      new_msg_attr = Val(GetProfileStr("PromColr", "PromptTextAttr", ""), 16)
   endif
   // Get the color to use for marked text in prompts.
   if GetProfileStr("PromColr", "PromptBlockAttr", "") == ""
      if Query(CursorInBlockAttr) in msg_attr, cursor_attr, title_attr
         if Query(BlockAttr) in msg_attr, cursor_attr, title_attr
            if Query(HiLiteAttr) in msg_attr, cursor_attr, title_attr
               if Query(MenuSelectAttr) in msg_attr, cursor_attr, title_attr
                  if Query(MenuTextAttr) in msg_attr, cursor_attr, title_attr
                     if Query(TextAttr) in msg_attr, cursor_attr, title_attr
                        // Failed: use the default after all.
                        new_cursor_attr = Query(BlockAttr)
                     else
                        new_cursor_attr = Query(TextAttr)
                     endif
                  else
                     new_cursor_attr = Query(MenuTextAttr)
                  endif
               else
                  new_cursor_attr = Query(MenuSelectAttr)
               endif
            else
               new_cursor_attr = Query(HiLiteAttr)
            endif
         else
            new_cursor_attr = Query(BlockAttr)
         endif
      else
         new_cursor_attr = Query(CursorInBlockAttr)
      endif
   else
      new_cursor_attr = Val(GetProfileStr("PromColr", "PromptBlockAttr", ""), 16)
   endif
end

proc WhenLoaded()
   get_new_prompt_colors(new_msg_attr, new_cursor_attr)
   Hook(_PROMPT_STARTUP_, prompt_startup)
   Hook(_PROMPT_CLEANUP_, prompt_cleanup)
end

proc Main()
   integer ok               = TRUE
   integer prev_msg_attr    = new_msg_attr
   integer prev_cursor_attr = new_cursor_attr
   string  answer      [10] = ""
   repeat
      answer = "yes"
      Message('Press the "End" key to see the color of normal text in a prompt.')
      ok = Ask("Are you satisfied with the coloring of this prompt?", answer)
      Message("")
      if  ok
      and answer <> "yes"
         ExecMacro("SlctColr "
                   + Str(new_msg_attr, 16)
                   + " Normal Text in Prompts")
         answer = Query(MacroCmdLine)
         if answer <> ""
            new_msg_attr = Val(answer, 16)
         endif
         ExecMacro("SlctColr "
                   + Str(new_cursor_attr, 16)
                   + " Marked Text in Prompts")
         answer = Query(MacroCmdLine)
         if answer <> ""
            new_cursor_attr = Val(answer, 16)
         endif
      endif
   until answer == "yes"
      or not ok
   if ok
      if YesNo("Save changed prompt colors for future TSE sessions?") == 1
         WriteProfileStr("PromColr", "PromptTextAttr" , Str(new_msg_attr   , 16))
         WriteProfileStr("PromColr", "PromptBlockAttr", Str(new_cursor_attr, 16))
         Message("Prompt colors are changed permanently.")
      else
         Message("Prompt colors are only changed for this TSE session.")
      endif
   else
      Message("Prompt colors are not changed.")
      new_msg_attr    = prev_msg_attr
      new_cursor_attr = prev_cursor_attr
   endif
end

