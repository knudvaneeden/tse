/*
   Macro.         ChFilTim.
   Author.        Carlo.Hogeveen@xs4all.nl.
   Date-written.  23 december 1999.

   This macro changes the date/time of all files in a given directory and
   all its subdirectories by adding or subtracting an amount of time.

   It was originally written to make the files on a LAN server an hour older
   (by adding -1 hour) to solve a synchronization problem when the outside
   world switches from summertime to wintertime.

   When the outside world switches from summertime to wintertime, and clocks
   go an hour back, then file-times on Windows pcs also go an hour back (*),
   but file-times on a LAN do not. So if files on Windows pcs are
   synchronized from a LAN-directory based on date/time, then the switch to
   wintertime suddenly makes files on Windows pcs APPEAR one hour older than
   the same files on a LAN, and inadvertenly triggers synchronization.

   (*) There are also advantages to this: A running Windows process doesn't
   see a just created file suddenly becoming an hour older or newer.
   Which for instance also means that a process cannot create files "in the
   future" :-)

   The macro prompts for:
      The directory.
      The type of time-unit: years, months, days, hours, minutes, seconds.
      The positive or negative number of time-units to add.
      Whether to Simulate or Make the changes.

   DISCLAIMER!
   Use this macro at your own risk. It is not perfect.
   Always do a simulation first, and especially search the resulting report
   for "overflow", which means that a certain date will not be changed.

   This macro is for 32-bit versions of TSE only.
*/



/*
   The following lines were copied from Semware's f.s macro.
*/

dll "<kernel32.dll>"
    integer proc GetLastError() : "GetLastError"
    integer proc Mk_Dir(string dir:cstrval, integer sa) : "CreateDirectoryA"
    integer proc Rm_Dir(string dir:cstrval) : "RemoveDirectoryA"
    integer proc Copy_File(string src:cstrval, string dst:cstrval, integer fail_if_exists) : "CopyFileA"
    integer proc Move_File(string src:cstrval, string dst:cstrval) : "MoveFileA"
    integer proc MoveFileEx(string src:cstrval, string dst:cstrval, integer flags) : "MoveFileExA"
    integer proc GetDiskFreeSpace(string root_dir:cstrval,
                    var integer SectorsPerCluster,
                    var integer BytesPerSector,
                    var integer NumberOfFreeClusters,
                    var integer TotalNumberOfClusters) : "GetDiskFreeSpaceA"

    integer proc CreateFile(string fn:cstrval, integer mode, integer sec, integer attr, integer flags, integer junk1, integer junk2) : "CreateFileA"
    integer proc CloseHandle(integer handle) : "CloseHandle"
    integer proc DosDateTimeToFileTime(integer date:word,
            integer time:word, string FILETIME:StrPtr) : "DosDateTimeToFileTime"
    integer proc LocalFileTimeToFileTime(string in_time:StrPtr, string out_time:StrPtr) : "LocalFileTimeToFileTime"
    integer proc SetFileTime(integer handle,
//            string FILETIME_Creation:StrPtr,
            integer FILETIME_Creation,
//            string FILETIME_LastAccess:StrPtr,
            integer FILETIME_LastAccess,
            string FILETIME_LastWrite:StrPtr) : "SetFileTime"
    integer proc GetShortPathName(string long_fn:cstrval,
            var string short_fn:strptr, integer n) : "GetShortPathNameA"
end

/***********************************************************************
    Low level DOS call to actually set the date and time
***********************************************************************/
integer proc LoSetDateTime(string fn, integer month, integer day, integer year,
                            integer hours, integer mins, integer secs)
    integer handle, time, date, ok
    string FILETIME[8] = "        "    // needs to be at least 64 bits long

    time = (hours shl 11) | (mins shl 5) | (secs / 2)
                                        //  Bitfields for file time:
                                        //   15-11  hours (0-23)
                                        //   10-5   minutes
                                        //   4-0    seconds/2
    date = ((year - 1980) shl 9) | (month shl 5) | day
                                        //  Bitfields for file date:
                                        //   15-9   year - 1980
                                        //   8-5    month
                                        //   4-0    day
    if not DosDateTimeToFileTime(date, time, FILETIME)
        return (Warn("Error on DosDateTimeToFileTime()"))
    endif
    // the two 0's are FILETIME_Creation and FILETIME_LastAccess, but to pass
    // 0 they have to have been declared as integers.
//    handle = fOpen(fn, _OPEN_WRITEONLY_|_OPEN_DENYALL_)// open handle
    handle = CreateFile(fn, 0x40000000, 0, 0, 3, 0, 0)      // GENERIC_WRITE and OPEN_EXISTING
    if handle == -1
        return (Warn("Error ", GetLastError(), " opening file ", fn))
    endif
    LocalFileTimeToFileTime(FILETIME, FILETIME)
    ok = SetFileTime(handle, 0, 0, FILETIME)
    if not ok
        Warn("Error ", GetLastError(), " setting time, handle:", handle)
    endif
//    fClose(handle)
    CloseHandle(handle)
    return (ok)
end

/*
   End of Semware's procedures from their f.s macro.
*/



#define ALL _NORMAL_|_HIDDEN_|_SYSTEM_|_DIRECTORY_

integer years   = 0
integer months  = 0
integer days    = 0
integer hours   = 0
integer minutes = 0
integer seconds = 0

integer simulate = TRUE

integer proc add(integer old_value, integer addition,
                 integer minimum, integer maximum, var integer overflow)
   integer result = old_value + addition + overflow
   if result > maximum
      overflow = 1
      result   = result - maximum
   else
      if result < minimum
         overflow = -1
         result   = maximum + result - minimum + 1
      else
         overflow = 0
      endif
   endif
   return (result)
end

integer proc number_of_days(integer month, integer year)
   integer result = 0
   if month in 1 .. 12
      result = Val(SubStr("312831303130313130313031", month * 2 - 1, 2))
   endif
   if month == 2
      if year mod 4 == 0
         if year mod 100 == 0
            if year mod 400 == 0
               result = 29
            endif
         else
            result = 29
         endif
      endif
   endif
   return(result)
end

proc ChFilTim(string dirname)
   string old_date [10] = ""
   string old_time  [8] = ""
   string new_date [10] = ""
   string new_time  [8] = ""
   integer old_year   = 0
   integer old_month  = 0
   integer old_day    = 0
   integer old_hour   = 0
   integer old_minute = 0
   integer old_second = 0
   integer new_year   = 0
   integer new_month  = 0
   integer new_day    = 0
   integer new_hour   = 0
   integer new_minute = 0
   integer new_second = 0
   integer overflow   = 0
   integer handle = FindFirstFile(dirname + "\*", ALL)
   if handle <> -1
      repeat
         Message(dirname + "\" + FFName())
         if FFAttribute() & _DIRECTORY_
            if  FFName() <> "."
            and FFName() <> ".."
               Delay(1)
               ChFilTim(dirname + "\" + FFName())
            endif
         else
            old_date   = FFDateStr()
            old_time   = FFTimeStr()
            old_year   = Val(GetToken(old_date, "-", 1))
            old_month  = Val(GetToken(old_date, "-", 2))
            old_day    = Val(GetToken(old_date, "-", 3))
            old_hour   = Val(GetToken(old_time, ":", 1))
            old_minute = Val(GetToken(old_time, ":", 2))
            old_second = Val(GetToken(old_time, ":", 3))
            overflow   = 0
            new_second = add(old_second, seconds, 0, 59, overflow)
            new_minute = add(old_minute, minutes, 0, 59, overflow)
            new_hour   = add(old_hour  , hours  , 0, 23, overflow)
            new_day    = add(old_day   , days   , 1, number_of_days(old_month, old_year), overflow)
            new_month  = add(old_month , months , 1, 12, overflow)
            new_year   = add(old_year  , years  , 1980, 2099, overflow)
            if overflow == 0
               new_date = Format(new_year:4:"0", "-", new_month:2:"0", "-", new_day:2:"0")
               new_time = Format(new_hour:2:"0", ":", new_minute:2:"0", ":", new_second:2:"0")
               AddLine(Format(old_date:-11,
                              old_time:-8,
                              " -> ",
                              new_date:-11,
                              new_time:-8,
                              "   ",
                              dirname + "\" + FFName()))
               if not simulate
                  Delay(1)
                  LoSetDateTime( dirname + "\" + FFName(),
                                 new_month,
                                 new_day,
                                 new_year,
                                 new_hour,
                                 new_minute,
                                 new_second)
               endif
            else
               AddLine(Format(old_date:-11,
                              old_time:-8,
                              " -> ",
                              "overflow":-19,
                              "   ",
                              dirname + "\" + FFName()))
            endif
         endif
         Delay(1)
      until not FindNextFile(handle, ALL)
      FindFileClose(handle)
   endif
end

proc Ask_Change(string text, integer minimum, integer maximum)
   integer result = 0
   string value [3] = ""
   Message("Enter a number between ", minimum, " and ", maximum)
   repeat
      Ask("Add how many " + text + " to the date/time of each file:", value)
      result = Val(value)
   until result in minimum .. maximum
   Message("")
   case text
      when "years"
         years   = result
      when "months"
         months  = result
      when "days"
         days    = result
      when "hours"
         hours   = result
      when "minutes"
         minutes = result
      when "seconds"
         seconds = result
   endcase
end

menu choose_field()
   TITLE = "Choose a field to change"
   "Change years   of files ...", Ask_Change("years"  , -19, 99)
   "Change months  of files ...", Ask_Change("months" , -12, 12)
   "Change days    of files ...", Ask_Change("days"   , -31, 31)
   "Change hours   of files ...", Ask_Change("hours"  , -23, 23)
   "Change minutes of files ...", Ask_Change("minutes", -59, 59)
   "Change seconds of files ...", Ask_Change("seconds", -59, 59)
end

proc set_update(integer truth)
   simulate = not truth
end

menu simulate_or_update()
   TITLE = "Simulate or Update"
   "Simulate: Just make a list of the changes that would be made.", set_update(FALSE)
   "Update  : Change all files in the given directory.", set_update(TRUE)
end

proc Main()
   integer teller = 0
   integer old_DateFormat = Set(DateFormat, 6)
   integer old_TimeFormat = Set(TimeFormat, 1)
   integer old_DateSeparator = Set(DateSeparator, Asc("-"))
   integer old_timeSeparator = Set(TimeSeparator, Asc(":"))
   integer old_break = Set(Break, ON)
   string dirname [255] = ""

   #ifdef EDITOR_VERSION
   #else
      #define EDITOR_VERSION 0
   #endif

   if EDITOR_VERSION >= 0x3000
      Ask ("For which directory do you want to change the date/time of files:",
            dirname)
      if dirname <> ""
         if  dirname [Length(dirname)] == "\"
         and Length(dirname) > 1
            dirname = SubStr(dirname, 1, Length(dirname) - 1)
         endif
         if FileExists(dirname) & _DIRECTORY_
            choose_field()
            simulate_or_update()
            repeat
               teller = teller + 1
            until GetBufferId("ChFilTim." + Str(teller)) == 0
            if CreateBuffer("ChFilTim." + Str(teller))
               #if EDITOR_VERSION
                  SetUndoOff()
               #endif
               ChFilTim(dirname)
               BegFile()
               #if EDITOR_VERSION
                  SetUndoOn()
               #endif
            else
               Warn("ChFilTim could not create buffer: ", "ChFilTim." + Str(teller))
            endif
         else
            Warn("Not a directory name: ", dirname)
         endif
      endif
   else
      Warn("This macro requires version 3.00 of TSE")
   endif
   Set(DateFormat, old_DateFormat)
   Set(TimeFormat, old_TimeFormat)
   Set(DateSeparator, old_DateSeparator)
   Set(TimeSeparator, old_timeSeparator)
   Set(Break, old_break)
   PurgeMacro("ChFilTim")
end

