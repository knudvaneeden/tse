/*
   Macro:   ExpTabs.
   Author:  Carlo Hogeveen (hyphen@xs4all.nl).
   Date:    17 March 1999.

   Version: 2. Fixes a bug when setting a non-default TabWidth.
   Date:    21 June 1999.

   Purpose: Removes physical tabs from files in a user friendly way.

   Install: Copy exptabs.s to TSE's mac directory and compile it.

            You can either put it in your Macro AutoLoad List to check
            all files as you open them, or you can Execute the macro
            to check the current file only, or you can do both.

   Notes:   The macro determines what the original TabWidth probably was,
            and lets the user check and change that while viewing
            especially the interesting lines with physical tabs.

            While viewing, the macro determines what lines are interesting.

            While viewing, the <home>, <ctrl pgup>, <end> and <ctrl pgdn>
            keys are available to skip to the begin or end of file.
*/

#define MAXTAB 16
#define MAXSTRING 255
#define WEIGHT 8

integer exptabs_id = 0
integer whenloaded_id = 0

integer proc ask_user_confirmation(var integer tab_width)
   integer result = 13
   integer old_tabwidth = Query(TabWidth)
   integer old_expandtabs = Set(ExpandTabs, ON)
   Set(TabWidth, tab_width)
   PopPosition()
   BegLine()
   if lFind("[~\t]\t", "ix")
      lFind("\t", "ix")
   else
      if lFind("[~\t]\t", "bix")
         lFind("\t", "ix")
      else
         if not lFind("\t", "ix")
            lFind("\t", "bix")
         endif
      endif
   endif
   Set(ExpandTabs, OFF)
   UpdateDisplay()
   Message("Physical tabs detected! The original TabWith was probably ", tab_width,
           ". Press any key ...")
   GetKey()
   Set(ExpandTabs, ON)
   repeat
      UpdateDisplay()
      Message("TabWidth = ", Query(TabWidth), " (was ", tab_width,
              "), ARROWS change view, ENTER accepts changes, ESCAPE quits")
      case GetKey()
         when <Escape>
            Message("No changes to file ", CurrFilename())
            result = FALSE
         when <enter>
            Message("Physical tabs removed from ", CurrFilename())
            tab_width = Query(TabWidth)
            result = TRUE
         when <cursorright>, <greycursorright>
            if Query(TabWidth) < MAXTAB
               Set(TabWidth, Query(TabWidth) + 1)
            endif
         when <cursorleft>, <greycursorleft>
            if Query(TabWidth) > 1
               Set(TabWidth, Query(TabWidth) - 1)
            endif
         when <cursordown>, <greycursordown>
            if lFind("[~\t]\t", "ix+")
               lFind("\t", "ix")
            else
               lFind("\t", "ix+")
            endif
         when <cursorup>, <greycursorup>
            PrevChar()
            if lFind("[~\t]\t", "bix")
               lFind("\t", "ix")
            else
               NextChar()
               lFind("\t", "bix")
            endif
         when <home>, <greyhome>, <ctrl pgup>, <ctrl greypgup>
            BegFile()
         when <end>, <greyend>, <ctrl pgdn>, <ctrl greypgdn>
            EndFile()
      endcase
   until result <> 13
   Set(ExpandTabs, old_expandtabs)
   Set(TabWidth, old_tabwidth)
   PushPosition()
   return(result)
end

proc file_ExpandTabsToSpaces(integer tab_width)
   integer curr_col, num_spaces
   BegFile()
   while lFind("\t", "ix")
      // ExpandTabsToSpaces()  // Does not work, so use the following:
      #ifdef WIN32
         curr_col = CurrCol() - 1 + Query(ZeroBasedTab)
      #else
         curr_col = CurrCol() - 1
      #endif
      num_spaces = Tab_Width - curr_col mod Tab_Width
      DelChar()
      InsertText(Format("":num_spaces), _INSERT_)
      PrevChar()
   endwhile
end

integer proc determine_tabwidth(string first_line, string second_line)
   integer result = 0
   integer org_id = GetBufferId()
   integer first_linelen = 0
   integer second_linelen = 0
   integer tab_width = 0
   if not exptabs_id
      exptabs_id = CreateBuffer("ExpTabs workspace", _SYSTEM_)
   endif
   GotoBufferId(exptabs_id)
   repeat
      tab_width = tab_width + 1
      EmptyBuffer()
      AddLine(first_line)
      AddLine(second_line)
      File_ExpandTabsToSpaces(tab_width)
      GotoLine(1)
      first_linelen = CurrLineLen()
      GotoLine(2)
      second_linelen = CurrLineLen()
   until tab_width > MAXTAB
      or first_linelen == second_linelen
   if first_linelen == second_linelen
      result = tab_width
   endif
   GotoBufferId(org_id)
   return(result)
end

proc ExpTabs()
   integer found = FALSE
   integer index = 0
   integer max_num = 0
   integer tab_width = 1
   integer biggest_tab_width = 0
   integer first_length = 0
   integer second_length = 0
   string counters [MAXTAB] = Format("":MAXTAB:Chr(0))
   string first_line  [255] = ""
   string second_line [255] = ""
   PushPosition()
   PushBlock()
   /* Try to determine the used TabWidth.
      We do this by finding two consecutive lines with tabs in the middle,
      and by assuming, that if the first nonwhite characters after those tabs
      are not ON the same column then they should be.
      Since this is not a foolproof method, we do it as much as Possible,
      and then choose between the tabwidth that occured most and the tabwidth
      that was the biggest.
   */
   if lFind("\t", "gix")
      if Query(Beep)
         Alarm()
      endif
      BegFile()
      while not found
      and   lFind("[~\t]\t", "ix")
      and   lFind("[~\t ]", "cix+")
         Message("Physical tabs detected! Determining the original TabWidth (",
                 CurrLine() * 100 / NumLines(),
                 "%) ...")
         PushPosition()
         first_length = CurrPos()
         Down()
         if  lFind("[~\t]\t", "cgix")
         and lFind("[~\t ]", "cix+")
            second_length = CurrPos()
            if  first_length  < MAXSTRING
            and second_length < MAXSTRING
            and first_length <> second_length
               // We have found a spot, where we can determine the TabWidth.
               second_line = GetText(1, CurrPos())
               Up()
               GotoPos(first_length)
               first_line = GetText(1, CurrPos())
               Tab_Width = determine_tabwidth(first_line, second_line)
               if tab_width
                  if Asc(counters[tab_width]) == 255
                     found = TRUE
                     found = found
                  else
                     counters[tab_width] = Chr(Asc(counters[tab_width]) + 1)
                  endif
               endif
            endif
         endif
         PopPosition()
         EndLine()
      endwhile
      tab_width = 0
      for index = 1 to MAXTAB
         if Asc(counters[index]) > 0
            biggest_tab_width = index
            if Asc(counters[index]) >= max_num
               max_num = Asc(counters[index])
               tab_width = index
            endif
         endif
      endfor
      // If we don't have a guess, then we use our own TabWidth.
      if tab_width == 0
         tab_width = Query(TabWidth)
      else
         /* My gut feeling (how is that for a design decision) says, that the
            biggest TabWidth is more likely to be the right one than the most
            occurring TabWidth. So I am going to weigh my decision in favour
            of the biggest TabWidth.
         */
         if Asc(counters[biggest_tab_width]) * WEIGHT >= max_num
            tab_width = biggest_tab_width
         endif
      endif
      if Ask_user_confirmation(tab_width)
         // Replace tabs by spaces through the whole file.
         file_ExpandTabsToSpaces(tab_width)
      endif
   endif
   PopBlock()
   PopPosition()
end

proc WhenLoaded()
   whenloaded_id = GetBufferId()
   Hook(_ON_FIRST_EDIT_, exptabs)
end

proc WhenPurged()
   AbandonFile(exptabs_id)
end

proc Main()
   if whenloaded_id == GetBufferId()
      UnHook(exptabs)
   endif
   exptabs()
   if whenloaded_id == GetBufferId()
      PurgeMacro("exptabs")
   endif
end
