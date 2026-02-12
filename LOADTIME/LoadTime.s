/*
   Macro          LoadTime
   Author         Carlo.Hogeveen@xs4all.nl
   Date           6 jan 2008
   Compatibility  TSE Pro 4.0 upwards

   This macro tells you what the date/time on disk of a file was,
   at the time it was loaded, except when you changed the filename
   inside TSE and have not saved it yet.

   Installation:
      Copy this source file to TSE's "mac" directory, and compile it.
      Add the macro to the Macro AutoLoad List.
      Restart TSE.

   Usage:
      Execute the macro to display the dates/times of the current file.
*/

string macro_name [255] = ""
string changed_message [255] = "Filename in TSE changed"

string proc get_disk_date_time()
   string result            [20] = "Unknown"
   integer old_DateFormat
   integer old_DateSeparator
   integer old_TimeFormat
   integer old_TimeSeparator
   if FileExists(CurrFilename())
      if FindThisFile(CurrFilename())
         old_DateFormat    = Set(DateFormat   , 6)
         old_DateSeparator = Set(DateSeparator, Asc("-"))
         old_TimeFormat    = Set(TimeFormat   , 1)
         old_TimeSeparator = Set(TimeSeparator, Asc(":"))
         result = FFDateStr() + " " + FFTimeStr()
         Set(DateFormat   , old_DateFormat)
         Set(DateSeparator, old_DateSeparator)
         Set(TimeFormat   , old_TimeFormat)
         Set(TimeSeparator, old_TimeSeparator)
      else
         result = "Not retreivable"
      endif
   else
      result = "Not a disk file"
   endif
   return(result)
end

proc remember_disk_date_time()
   string date_time [20] = get_disk_date_time()
   SetBufferStr(macro_name + ":old_Filename", CurrFilename())
   SetBufferStr(macro_name + ":CurrFilename", CurrFilename())
   SetBufferStr(macro_name + ":date_time"   , date_time)
end

proc on_changing_files()
   // If the filename changed inside TSE, then there is no
   // relevant "disk date/time when loaded".
   if GetBufferStr(macro_name + ":CurrFilename") <> CurrFilename()
      SetBufferStr(macro_name + ":CurrFilename", CurrFilename())
      SetBufferStr(macro_name + ":date_time"   , changed_message)
   endif
end

proc show_all_dates_times()
   /* Display layout:

      Disk
         Date Time      2007-12-31 13:14:00

      Memory
         Date Time      2008-01-02 23:34:11

         Cur Filename   d:\tmp1.txt
         Old Filename   d:\tmp1.txt
   */
   integer old_cursor = Set(Cursor, OFF)
   PopWinOpen(1,
              Query(ScreenRows) / 2 - 6,
              Query(ScreenCols),
              Query(ScreenRows) / 2 + 5,
              1,
              "Current File Info",
              Query(MenuBorderAttr))
   Set(Attr, Query(MenuTextAttr))
   VGotoXY(1, 1)
   ClrScr()
   VGotoXY(1, 2)
   WriteLine("Disk")
   WriteLine("   Date Time      ", get_disk_date_time())
   WriteLine(" ")
   WriteLine("Memory")
   WriteLine("   Date Time      ", GetBufferStr(macro_name + ":date_time" ))
   WriteLine(" ")
   if GetBufferStr(macro_name + ":date_time") == changed_message
      WriteLine("   Cur Filename   ", CurrFilename())
      WriteLine("   Old Filename   ", GetBufferStr(macro_name + ":old_Filename"))
   else
      WriteLine("   Filename       ", CurrFilename())
   endif
   GetKey()
   PopWinClose()
   Set(Cursor, old_cursor)
end

proc WhenLoaded()
   macro_name = SplitPath(CurrMacroFilename(), _NAME_)
   Hook(_ON_FILE_LOAD_     , remember_disk_date_time)
   Hook(_ON_CHANGING_FILES_, on_changing_files      )
   Hook(_AFTER_FILE_SAVE_  , remember_disk_date_time)
end

proc Main()
   show_all_dates_times()
end

