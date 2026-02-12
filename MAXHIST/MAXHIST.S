/*
   Macro:   MaxHist.
   Author:  Carlo Hogeveen (hyphen@xs4all.nl).
   Date:    21 Februari 1999.
   Version: 2 (22 Februari 1999).

   Purpose: If MaxHistoryPerList * number of history lists > MaxHistorySize,
            then an infrequently used history list can get "pushed out"
            by a frequently used history list.

            The MaxHist macro maximizes MaxHistorySize and calculates
            MaxHistoryPerList based on MaxHistorySize and the number
            of history lists.

            Even if later on new history lists are added, or TSE allows
            a different maximum value for MaxHistorySize, then this macro
            automatically adjusts and protects your history lists.

   Install: Put and compile MaxHist.s in TSE's "mac" directory,
            and put MaxHist in your macro autoloadlist.

   Notes:   Use of this macro only makes sense if PersistentHistory
            is set to ON, so this macro sets it to ON.

            MaxHist purges itself from memory right after startup,
            so it doesn't take up any macro space.

            The macro's run time could not be measured,
            because it is less than 1/18 of a second.

   History: Version 2 also maximizes MaxHistoryPerList,
            if there are very few history lists.
*/
#define history_id 6
proc maxhist()
   integer org_id = getbufferid()
   integer minimum = 1
   integer maximum = MAXINT / 2
   integer between = 0
   integer histories = 0
   integer index = 0
   integer old_maxhistorysize = query(maxhistorysize)
   integer old_maxhistoryperlist = query(maxhistoryperlist)
   integer old_msglevel = set(msglevel, _none_)
   string character [255] = format("":255:"n")
   string text_old_historysize [255] = ""
   string text_old_listsize [255] = ""
   set(persistenthistory, on)
   // Set MaxHistorySize to TSE's maximum.
   repeat
      between = (minimum + maximum) / 2
      set(maxhistorysize, between)
      if query(maxhistorysize) == between
         minimum = between
      else
         maximum = between
      endif
   until maximum - minimum < 2
   // Set MaxHistoryPerList to TSE's maximum.
   minimum = 1
   maximum = query(maxhistorysize)
   repeat
      between = (minimum + maximum) / 2
      set(maxhistoryperlist, between)
      if query(maxhistoryperlist) == between
         minimum = between
      else
         maximum = between
      endif
   until maximum - minimum < 2
   // Count the number of history lists.
   gotobufferid(history_id)
   pushposition()
   begfile()
   repeat
      if currchar() in 1 .. 255
         character[currchar()] = "j"
      endif
   until not down()
   popposition()
   gotobufferid(org_id)
   for index = 1 to 255
      if character[index] == "j"
         histories = histories + 1
      endif
   endfor
   set(maxhistoryperlist, query(maxhistorysize) / histories)
   set(msglevel, old_msglevel)
   // If MaxHistorySize or MaxHistoryPerList changed,
   // then notify the user and save the new settings.
   if query(maxhistorysize) <> old_maxhistorysize
      text_old_historysize = str(old_maxhistorysize) + " -> "
   endif
   if query(maxhistoryperlist) <> old_maxhistoryperlist
      text_old_listsize = str(old_maxhistoryperlist) + " -> "
   endif
   if text_old_historysize <> ""
   or text_old_listsize    <> ""
      message("Total history size: ", text_old_historysize,
              query(maxhistorysize), ", lists: ", histories, ", list size: ",
              text_old_listsize, query(maxhistoryperlist))
      delay(99)
      savesettings()
      updatedisplay()
   endif
   purgemacro("maxhist")
end
proc idle()
   maxhist()
end
proc whenloaded()
   hook(_idle_, idle)
end
proc main()
   whenloaded()
end
