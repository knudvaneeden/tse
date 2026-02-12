/*
   Macro          SyncDir
   Author         Carlo.Hogeveen@xs4all.nl
   Date           1 July 2001
   Compatibility  TSE Pro 2.8 (at least)
   Version        0.1
   Warranty       None! This macro was not built for or checked for
                  correctness. It is just something I hacked together
                  for myself, and I offer it as is.

   This macro synchronizes files from a MicroSoft directory
   to a unix directory and the other way around.

   The directories are specified in a file SynDir.dat in TSE's "mac"
   directory: containing for instance:

      #  Note: A line with a "#" on column 1 is considered a comment.
      #  Note: The file must end with an empty line.
      #  Note: It is absolutely forbidden to transfer the same file(s) both
      #        ways between directories. Because files are also transferred
      #        based on a difference in size, there would be no way to tell
      #        which way a file would be transferred. On the plus side, also
      #        basing file transfers on size makes sure that partially
      #        created or transferred files are transferred again.
      #  Note: It is allowed and efficient to transfer different files in
      #        opposite ways between the "from" and the "to" directory.
      #        Hereto an optional "filespec_back" directive is available.
      #  Note: The "pause" and "log_file" directives are optional and global,
      #        and need not be repeated for the other directories.
      #        The defaults are "10" seconds and file "c:\tseftp.log".
      #  Note: Instead of a general "pause" you may use "middle_pause" for
      #        pauses in the middle of the list and "end_pause" for the pause
      #        after the list has been traversed.
      #  Note: By supplying a username after a unix filespec, you won't be
      #        asked for it.

      dir_from         d:\zest3
      dir_to           ftp.provider.com:/home/me
      filespec         \.fmb$                      username
      filespec_back    \.sts$
      pause            10
      middle_pause     3
      end_pause        57
      log_file         c:\tseftp2.log

      dir_from         d:\zest4
      dir_to           ftp.provider.com:/home/me
      filespec         \.sts                       username
      filespec_back    \.fmb

   The filespec must be expressed as a TSE regular expression,
   and may not contain a "^".

   Directories are not transferred recursively.

   Within a directory files are transferred in alphabetical order.
   This might be used for transferring a semafoor file after a big file.

   SyncDir runs under TSE Pro 32 only. TSE 2.5 and below are not supported.

   Installation takes to steps:
   -  Install "macpar3.zip" from Semware's website.
   -  Copy this file to TSE's "mac" directory, and compile it.
   -  Copy the indented lines above to a newly created file SyncDir.dat,
      also in TSE's "mac" directory, and adjust them to your needs.
*/



#include ["initpar.si"]



// Global constants and variables:

#define CCF_FLAGS _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_
#define SA_FLAGS  _DONT_PROMPT_|_OVERWRITE_

integer syncdir_loops = MAXINT // Set to MAXINT for production, or to a digit for testing.

string log_file [255] = "c:\tseftp.log"
string in_file   [12] = "c:\tseftp.in"
string bat_file  [13] = "c:\tseftp.bat"
string out_file  [13] = "c:\tseftp.out"

string parameter_password [255] = ""

integer pause           = 10
integer middle_pause    = 10
integer end_pause       = 10
integer log_retrieved   = FALSE
integer log_id          = 0
integer in_id           = 0
integer out_id          = 0
integer bat_id          = 0
integer dat_id          = 0
integer dirlist_id      = 0
integer transfer_id     = 0
integer restrict_id     = 0
integer clock_ticks     = 0



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

    integer proc CreateFile(string fn:cstrval, integer mode, integer sec, integer Attr, integer flags, integer junk1, integer junk2) : "CreateFileA"
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
   End of Semware's lines from their f.s macro.
*/



proc wait(integer seconds)
   integer counter = seconds
   while not KeyPressed()
   and   counter > 0
      Delay(18)
      counter = counter - 1
   endwhile
end

proc my_dos(string bat_file)
   Delay(1)
   Dos(bat_file, _DONT_PROMPT_|_DONT_CLEAR_)
   Delay(1)
end

proc error(string text)
   Alarm()
   UpdateDisplay()
   Message("Error: ", text)
   Delay(180)
end

proc Ask_password(string question, var string password)
   integer x = 1
   PopWinOpen( 5, 5, 5 + 70 + 2, 7, 4, question, 15)
   Set(Attr, Color(bright white ON black))
   ClrScr()
   GotoXY(1,1)
   while GetKey() <> <Enter>
      case Query(Key)
      when <Escape>
         password = ""
         PushKey(<Enter>)
      when <BackSpace>
         if x > 1
            x = x - 1
            password[x] = ""
            GotoXY(X, 1)
            PutChar(" ")
            GotoXY(x, 1)
         else
            Alarm()
         endif
      when 33 .. 254
         if x < 70
            PutChar("*")
            password[X] = Chr(Query(Key))
            x = x + 1
            GotoXY(x, 1)
         else
            Alarm()
         endif
      otherwise
         Alarm()
      endcase
   endwhile
   // Message("password=", password, ".")
   // Delay(99)
   PopWinClose()
end

integer proc get_env(var string dir, var string machine, var string user_password)
   integer  result         = FALSE
   string   user     [255] = user_password
   string   password [255] = ""
   if dir == ""
      error("Dir_from or dir_to is unknown in .dat file")
   else
      machine = GetToken(dir, ":", 1)
      dir     = GetToken(dir, ":", 2)
      if Length(machine) == 0
         error("Dir_from or dir_to has no drive or machine_name before the colon")
      else
         if Length(machine) == 1
            if dir [Length(dir)] == "\"
               dir = SubStr(dir, 1, Length(dir) - 1)
            endif
            user_password = ""
            result = TRUE
         else
            if dir [Length(dir)] == "/"
               dir = SubStr(dir, 1, Length(dir) - 1)
            endif
            user_password = GetGlobalStr("SyncDir:" + machine)
            if user_password == ""
               ClrScr()
               Message(dir)
               if user == ""
                  Ask("User for " + machine + ":", user)
               endif
               password = Trim(password)
               if password == ""
                  password = parameter_password
                  password = Trim(password)
               endif
               if password == ""
                  Ask_password("Password for " + machine + ", " + user + ":",
                               password)
               endif
               user     = Trim(user)
               password = Trim(password)
               if user     == ""
               or password == ""
                  error("No user and/or password supplied")
               else
                  user_password = user + " " + password
                  SetGlobalStr("SyncDir:" + machine, user_password)
                  result = TRUE
               endif
            else
               result = TRUE
            endif
         endif
      endif
   endif
   return(result)
end

string proc ff_date_str()
   string result [10] = FFDateStr()
   #ifdef EDITOR_VERSION
   #else
      if result [1:2] < "50"
         result = "20" + Format(Trim(result):8:"0")
      else
         result = "19" + Format(Trim(result):8:"0")
      endif
   #endif
   return(result)
end

integer proc make_ms_dirlist(string way, string dir, string machine)
   integer result = FALSE
   integer handle = -1
   integer eofs = FALSE
   GotoBufferId(dirlist_id)
   if FileExists(machine + ":" + dir + "\" + "*")
      result = TRUE
      handle = FindFirstFile(machine + ":" + dir + "\" + "*", -1)
      if handle <> -1
         while not eofs
            if not (FFAttribute() & (_VOLUME_|_DIRECTORY_))
               AddLine(Format(way, " ", ff_date_str():10:"0", "_",
                              Trim(FFTimeStr()):8:"0", " ", FFSize():10:"0",
                              " ", FFName()))
            endif
            eofs = not FindNextFile(handle, -1)
         endwhile
         FindFileClose(handle)
      endif
   endif
   return(result)
end

string proc month_to_digits(string month)
   string result [2] = ""
   string months [36] = "janfebmaraprmayjunjulaugsepoctnovdec"
   result = Format((Pos(Lower(month), months) + 2) / 3 :2:"0")
   return(result)
end

string proc get_system_datetime()
   string result [19] = GetDateStr()
   #ifdef EDITOR_VERSION
   #else
      if result[1:2] < "50"
         result = "20" + Format(Trim(result):8:"0")
      else
         result = "19" + Format(Trim(result):8:"0")
      endif
   #endif
   result = result + "_" + Format(Trim(GetTimeStr()):8:"0")
   return(result)
end

proc get_system_date(var integer system_month, var integer system_year)
   string result [19] = get_system_datetime()
   system_year = Val(result[1:4])
   system_month = Val(result[6:2])
end

string proc cd_dir(string machine, string dir)
   /*
      The macro stores directories without traling slashes. When a traling
      slash might be needed for a "cd" command, this proc is called.
   */
   string result [255] = dir
   if Length(dir) == 0
      if Length(machine) == 1
         result = dir + "\"
      else
         result = dir + "/"
      endif
   endif
   return(result)
end

proc retrieve_log()
   GotoBufferId(log_id)
   if not log_retrieved
      EmptyBuffer()
      InsertFile(log_file, _DONT_PROMPT_)
      UnMarkBlock()
      log_retrieved = TRUE
      EndFile()
      AddLine("")
      AddLine("")
      AddLine("")
      AddLine("Syncdir started at: " + get_system_datetime() + ".")
      SaveAs(log_file, SA_FLAGS)
   endif
   EndFile()
   BegLine()
end

integer proc make_unix_dirlist(string way, string dir, string machine, string user_password)
   integer result       = TRUE
   integer system_month = 0
   integer system_year  = 0

   string bytes       [11] = ""
   string filename   [255] = ""
   string year_or_time [5] = ""
   string year         [4] = ""
   string time         [8] = ""
   string month        [3] = ""
   string day          [2] = ""

   Message("Getting dirlist from ", machine, ":", dir)
   get_system_date(system_month, system_year)
   GotoBufferId(in_id)
   EmptyBuffer()
   AddLine("user " + user_password)
   AddLine("cd " + cd_dir(machine, dir))
   AddLine("ls -la")
   AddLine("bye")
   SaveAs(in_file, SA_FLAGS)
   EmptyBuffer()
   GotoBufferId(bat_id)
   EmptyBuffer()
   AddLine("@echo off")
   AddLine("ftp -n -i -s:" + in_file + " " + machine + " > " + out_file)
   SaveAs(bat_file, SA_FLAGS)
   EmptyBuffer()
   my_dos(bat_file)
   EraseDiskFile(in_file)
   EraseDiskFile(bat_file)
   GotoBufferId(out_id)
   EmptyBuffer()
   result = result and InsertFile(out_file, _DONT_PROMPT_)
   UnMarkBlock()
   if lFind("^530", "gx")
      retrieve_log()
      AddLine("")
      AddLine("Wrong user/password for " + machine + " on " + get_system_datetime() + ".")
      SaveAs(log_file, SA_FLAGS)
      GotoBufferId(out_id)
      result = FALSE
   elseif lFind("Not connected.", "g")
      retrieve_log()
      AddLine("")
      AddLine("No connection with " + machine + " on "+ get_system_datetime() + ".")
      SaveAs(log_file, SA_FLAGS)
      GotoBufferId(out_id)
      result = FALSE
   else
      BegFile()
      repeat
         if not lFind("^\-", "cgx")
            KillLine()
            Up()
         endif
      until not Down()
      BegFile()
      if not lFind("^\-", "cgx")
         KillLine()
      endif
      if PosFirstNonWhite()
         BegFile()
         repeat
            BegLine()
            WordRight(4)
            bytes = GetWord()
            WordRight()
            month = GetWord()
            WordRight()
            day = GetWord()
            WordRight()
            year_or_time = GetWord()
            WordRight()
            filename = GetText(CurrPos(), 255)
            // Solve a bug in ftp: it returns chars 13 13 10 at eol.
            // TSE 3.0 can handle that, TSE 2.8 not.
            if SubStr(filename, Length(filename), 1) == Chr(13)
               filename = SubStr(filename, 1, Length(filename) - 1)
            endif
            month = month_to_digits(month)
            if Pos(":", year_or_time)
               time = Format(year_or_time + ":00" :8:"0")
               if Val(month) <= system_month
                  year = Format(system_year:4:"0")
               else
                  year = Format(system_year - 1:4:"0")
               endif
            else
               /*
                  It is important to make the time maximal, so that files older
                  than six months are not copied to unix again and get an at
                  least six months newer system date, but so that they are
                  copied from unix to ms again which makes the date on the ms
                  side less than twentyfour hours wrong.
               */
               year = year_or_time
               time = "23:59:59"
            endif
            GotoBufferId(dirlist_id)
            AddLine(Format(way, " ", year, "-", month, "-", day:2:"0", "_",
                           time, " ", bytes:10:"0", " ", filename))
            GotoBufferId(out_id)
         until not Down()
      endif
   endif
   GotoBufferId(out_id)
   EmptyBuffer()
   EraseDiskFile(out_file)
   return(result)
end

integer proc make_dirlist(string way, string dir, string machine, string user_password)
   integer result = FALSE
   if Length(machine) == 1
      result = make_ms_dirlist(way, dir, machine)
   else
      result = make_unix_dirlist(way, dir, machine, user_password)
   endif
   return(result)
end

integer proc make_transfer_list()
   /*
      Assumption: Before the sort all "f" ways are before all "t" ways.
      We assume the sort does not change that for files with the same name.
   */
   integer result = TRUE
   integer last_line = 0

   string prev_way        [2] = ""
   string prev_datetime  [20] = ""
   string prev_bytes     [11] = ""
   string prev_filename [255] = ""

   string next_way        [2] = ""
   string next_datetime  [20] = ""
   string next_bytes     [11] = ""
   string next_filename [255] = ""

   GotoBufferId(transfer_id)
   EmptyBuffer()
   GotoBufferId(dirlist_id)
   MarkColumn(1, 34, NumLines(), LongestLineInBuffer())
   ExecMacro("Sort")
   UnMarkBlock()
   BegFile()
   InsertLine()
   repeat
      if  prev_way == ""
      and Down()
         BegLine()
         prev_way = GetWord()
         WordRight()
         prev_datetime = GetWord()
         WordRight()
         prev_bytes = GetWord()
         WordRight()
         prev_filename = GetText(CurrPos(), 255)
      endif
      if  next_way == ""
      and Down()
         BegLine()
         next_way = GetWord()
         WordRight()
         next_datetime = GetWord()
         WordRight()
         next_bytes = GetWord()
         WordRight()
         next_filename = GetText(CurrPos(), 255)
      endif
      if prev_way == ""
         last_line = NumLines()
         error("What am I doing here?")
         result = FALSE
      else
         if prev_filename == next_filename
            /*
            The "or"'s are why two-way file transfers are forbidden: there
            would be no way to tell which way a file would be transferred.
            On the plus side, the "or" makes sure, that partial transfers or
            transfers of partially created files are redone!
            */
            if prev_datetime > next_datetime
            or prev_bytes   <> next_bytes
               GotoBufferId(transfer_id)
               AddLine(Format("norm ", prev_datetime, " ", prev_filename))
               GotoBufferId(dirlist_id)
            endif
            if prev_datetime < next_datetime
            or prev_bytes   <> next_bytes
               GotoBufferId(transfer_id)
               AddLine(Format("back ", next_datetime, " ", next_filename))
               GotoBufferId(dirlist_id)
            endif
            prev_way = ""
            next_way = ""
            last_line = CurrLine()
         else
            if prev_way == "f"
               GotoBufferId(transfer_id)
               AddLine(Format("norm ", prev_datetime, " ", prev_filename))
               GotoBufferId(dirlist_id)
            endif
            if prev_way == "t"
               GotoBufferId(transfer_id)
               AddLine(Format("back ", prev_datetime, " ", prev_filename))
               GotoBufferId(dirlist_id)
            endif
            if next_way == ""
               prev_way  = ""
               last_line = CurrLine()
            else
               prev_way       = next_way
               prev_datetime  = next_datetime
               prev_bytes     = next_bytes
               prev_filename  = next_filename
               next_way       = ""
               next_datetime  = ""
               next_bytes     = ""
               next_filename  = ""
               last_line = CurrLine() - 1
            endif
         endif
      endif
   until  prev_way == ""
      and next_way == ""
      and last_line == NumLines()

   GotoBufferId(dirlist_id)
   EmptyBuffer()
   return(result)
end

proc restrict_transfer_word(string filename, string filespec)
   integer org_id = GetBufferId()
   GotoBufferId(restrict_id)
   EmptyBuffer()
   InsertText(filename)
   if  not lFind(".bak"  , "cgi$")
   and     lFind(filespec, "cgix")
      MarkFoundText()
      if Lower(GetMarkedText()) == Lower(GetText(1, CurrLineLen()))
         UnMarkBlock()
         GotoBufferId(org_id)
      else
         UnMarkBlock()
         GotoBufferId(org_id)
         KillLine()
         Up()
      endif
   else
      GotoBufferId(org_id)
      KillLine()
      Up()
   endif
end

proc restrict_transfer_line(string filespec, string filespec_back)
   BegLine()
   if GetWord() == "norm"
      WordRight(2)
      restrict_transfer_word(GetWord(), filespec)
   else
      WordRight(2)
      restrict_transfer_word(GetWord(), filespec_back)
   endif
end

integer proc restrict_transfer_list(string filespec, string filespec_back)
   integer result = TRUE
   GotoBufferId(transfer_id)
   BegFile()
   repeat
      restrict_transfer_line(filespec, filespec_back)
   until not Down()
   BegFile()
   restrict_transfer_line(filespec, filespec_back)
   return(result)
end

integer proc make_unix_cmd_list( string dir_from,
                                 string dir_to,
                                 string machine_from,
                                 string machine_to,
                                 string user_password_from,
                                 string user_password_to
                               )
   integer result                   = TRUE
   string  ms_machine         [255] = ""
   string  ms_dir             [255] = ""
   string  unix_dir           [255] = ""
   string  unix_machine       [255] = ""
   string  unix_user_password [255] = ""
   string  unix_norm_cmd        [3] = ""
   string  unix_cmd             [3] = ""
   string  filename           [255] = ""
   string  curr_drive           [1] = ""
   string  curr_dir           [255] = ""
   string  datetime            [45] = ""
   string  direction            [4] = ""

   Message("Transferring: ", machine_from, ":", dir_from,
           " -> "          , machine_to  , ":", dir_to  )

   if Length(machine_from) > 1
      ms_machine           = machine_to
      ms_dir               = dir_to
      unix_dir             = dir_from
      unix_machine         = machine_from
      unix_user_password   = user_password_from
      unix_norm_cmd        = "get"
   else
      ms_machine           = machine_from
      ms_dir               = dir_from
      unix_dir             = dir_to
      unix_machine         = machine_to
      unix_user_password   = user_password_to
      unix_norm_cmd        = "put"
   endif

   GotoBufferId(in_id)
   EmptyBuffer()
   AddLine(Format("user ", unix_user_password))
   AddLine("binary")
   AddLine(Format("cd "  , cd_dir(unix_machine, unix_dir)))
   retrieve_log()
   AddLine("")
   AddLine("File transfer at: " + get_system_datetime())
   GotoBufferId(transfer_id)
   BegFile()
   repeat
      BegLine()
      if GetWord() == "norm"
         direction = " -> "
         unix_cmd = unix_norm_cmd
      else
         direction = " <- "
         if unix_norm_cmd == "get"
            unix_cmd = "put"
         else
            unix_cmd = "get"
         endif
      endif
      WordRight()
      datetime = GetWord()
      if Length(machine_to) > 1
         datetime = datetime + " -> ñ " + get_system_datetime()
      endif
      WordRight()
      filename = GetText(CurrPos(), 255)
      GotoBufferId(in_id)
      AddLine(Format(unix_cmd, " ", filename))
      GotoBufferId(log_id)
      AddLine(Format(machine_from, ":", dir_from, direction,
                     machine_to  , ":", dir_to  , ": ",
                     filename, " (", datetime, ")"))
      GotoBufferId(transfer_id)
   until not Down()
   GotoBufferId(log_id)
   SaveAs(log_file, SA_FLAGS)
   GotoBufferId(in_id)
   AddLine("bye")
   SaveAs(in_file, SA_FLAGS)
   EmptyBuffer()
   GotoBufferId(bat_id)
   EmptyBuffer()
   curr_drive = GetDrive()
   curr_dir   = GetToken(SubStr(CurrDir(), 1, Length(CurrDir()) - 1), ":", 2)
   AddLine("@echo off")
   AddLine(ms_machine + ":")
   AddLine("cd " + cd_dir(ms_machine, ms_dir))
   AddLine("ftp -n -i -s:" + in_file + " " + unix_machine + " > " + out_file)
   AddLine(curr_drive + ":")
   AddLine("cd " + cd_dir("?", curr_dir))
   SaveAs(bat_file, SA_FLAGS)
   EmptyBuffer()
   my_dos(bat_file)
   EraseDiskFile(in_file)
   EraseDiskFile(bat_file)
   GotoBufferId(transfer_id)
   BegFile()
   repeat
      BegLine()
      if GetWord() == "norm"
         unix_cmd = unix_norm_cmd
      else
         if unix_norm_cmd == "get"
            unix_cmd = "put"
         else
            unix_cmd = "get"
         endif
      endif
      if unix_cmd == "get"
         WordRight()
         datetime = GetWord()
         WordRight()
         filename = GetText(CurrPos(), 255)
         Delay(2)
         if not LoSetDateTime(ms_machine + ":" + ms_dir + "\" + filename,
                              Val(datetime [ 6:2]),
                              Val(datetime [ 9:2]),
                              Val(datetime [ 1:4]),
                              Val(datetime [12:2]),
                              Val(datetime [15:2]),
                              Val(datetime [18:2]) )
            result = FALSE
         endif
         GotoBufferId(transfer_id)
      endif
   until not Down()
   Message("Transferred: ", machine_from, ":", dir_from,
           " -> "         , machine_to  , ":", dir_to  )
   return(result)
end

integer proc make_ms_cmd_list()
   integer result = TRUE
   error("Copying from ms to ms not implemeted yet")
   result = FALSE
   return(result)
end

integer proc syncdir()
   integer result                      = TRUE
   integer non_global_directives_found = FALSE
   integer Key                         = 0
   string  dir_from              [255] = ""
   string  dir_to                [255] = ""
   string  machine_from          [255] = ""
   string  machine_to            [255] = ""
   string  user_password_from    [255] = ""
   string  user_password_to      [255] = ""
   string  filespec              [255] = ""
   string  filespec_back         [255] = ""
   string  directive             [255] = ""
   // Goto the next not empty line, including the current line.
   while GetText(1,1) == "#"
   or    not PosFirstNonWhite()
      if not Down()
         BegFile()
         if end_pause == 0
            Message("Syncdir finished.")
            Delay(36)
            PushKey(<Escape>)
            Delay(36)
         elseif end_pause < 0
            Message("Press any key for the next synchronization or Escape to stop ... ")
            Key = GetKey()
            PushKey(Key)
         else
            wait(end_pause)
         endif
         while KeyPressed()
            if GetKey() == <Escape>
               result = FALSE
            endif
         endwhile
      endif
   endwhile
   // Read parameters until filespec parameter or empty line or end of file.
   if result
      repeat
         directive = Trim(Lower(GetToken(GetText(1, CurrLineLen()), " ", 1)))
         case directive
            when "pause"
               pause = Val(Trim(Lower(GetToken(GetText(1, CurrLineLen()), " ", 2))))
               if pause == 0
                  pause = 10
               endif
               middle_pause = pause
               end_pause    = 0
            when "middle_pause"
               middle_pause = Val(Trim(Lower(GetToken(GetText(1, CurrLineLen()), " ", 2))))
               if middle_pause == 0
                  middle_pause = 10
               endif
            when "end_pause"
               end_pause = Val(Trim(Lower(GetToken(GetText(1, CurrLineLen()), " ", 2))))
            when "log_file"
               log_file = Trim(Lower(GetToken(GetText(1, CurrLineLen()), " ", 2)))
            when "user"
               user_password_from = Trim(GetToken(GetText(1, CurrLineLen()), " ", 2))
               user_password_to   = user_password_from
            when "dir_from"
               non_global_directives_found = TRUE
               dir_from = Trim(GetToken(GetText(1, CurrLineLen()), " ", 2))
            when "dir_to"
               non_global_directives_found = TRUE
               dir_to   = Trim(GetToken(GetText(1, CurrLineLen()), " ", 2))
            when "filespec"
               non_global_directives_found = TRUE
               filespec      = Trim(GetToken(GetText(1, CurrLineLen()), " ", 2))
            when "filespec_back"
               non_global_directives_found = TRUE
               filespec_back = Trim(GetToken(GetText(1, CurrLineLen()), " ", 2))
            otherwise
               if  PosFirstNonWhite() <> 0
               and GetText(1,1) <> "#"
                  error("Unexpected parameter in .dat file")
                  result = FALSE
               endif
         endcase
      until not result
         or not Down()
         or (   non_global_directives_found
            and PosFirstNonWhite() == 0)
   endif
   if result
      result = get_env(dir_from, machine_from, user_password_from)
   endif
   if result
      result = get_env(dir_to, machine_to, user_password_to)
   endif
   if result
      if  Length(machine_from) > 1
      and Length(machine_to  ) > 1
         error("Cannot synchronize from unix to unix")
         result = FALSE
      endif
   endif
   if result
      GotoBufferId(dirlist_id)
      EmptyBuffer()
      result = make_dirlist("f", dir_from, machine_from, user_password_from)
   endif
   if result
      result = make_dirlist("t", dir_to, machine_to, user_password_to)
   endif
   if result
      result = make_transfer_list()
   endif
   if result
      result = restrict_transfer_list(filespec, filespec_back)
   endif
   if result
      if PosFirstNonWhite()
         if Length(machine_from) > 1
         or Length(machine_to  ) > 1
            result = make_unix_cmd_list(dir_from, dir_to, machine_from,
                                        machine_to, user_password_from,
                                        user_password_to)
         else
            result = make_ms_cmd_list()
         endif
      else
         Message("Nothing: ", machine_from, ":", dir_from,
                 " -> ",      machine_to,   ":", dir_to)
      endif
   endif
   retrieve_log()
   UpdateDisplay()
   wait(middle_pause)
   GotoBufferId(dat_id)
   // Test lines:
   syncdir_loops = syncdir_loops - 1
   if syncdir_loops <= 0
      result = FALSE
   endif
   // End of test lines.
   return(result)
end

proc Main()
   #ifdef EDITOR_VERSION
      integer old_dateformat = Set(DateFormat, 6)
   #else
      integer old_dateformat = Set(DateFormat, 3)
   #endif
   integer old_timeformat    = Set(TimeFormat, 1)
   integer old_dateseparator = Set(DateSeparator, Asc("-"))
   integer old_timeseparator = Set(TimeSeparator, Asc(":"))
   string  old_wordset  [32] = Set(WordSet, ChrSet("\d033-\d255"))
   integer old_break         = Set(break, ON)
   integer stop              = FALSE
   parameter_password = poppar()
   initpar()
   PushPosition()
   PushBlock()
   dirlist_id = CreateTempBuffer()
   ChangeCurrFilename("SyncDir:dirlist", CCF_FLAGS)
   transfer_id = CreateTempBuffer()
   ChangeCurrFilename("SyncDir:transfer", CCF_FLAGS)
   restrict_id = CreateTempBuffer()
   ChangeCurrFilename("SyncDir:restrict", CCF_FLAGS)
   in_id = CreateTempBuffer()
   ChangeCurrFilename("SyncDir:in", CCF_FLAGS)
   out_id = CreateTempBuffer()
   ChangeCurrFilename("SyncDir:out", CCF_FLAGS)
   bat_id = CreateTempBuffer()
   ChangeCurrFilename("SyncDir:bat", CCF_FLAGS)
   log_id = CreateTempBuffer()
   ChangeCurrFilename("SyncDir:log", CCF_FLAGS)
   clock_ticks = GetClockTicks()
   dat_id = CreateTempBuffer()
   ChangeCurrFilename("SyncDir:dat", CCF_FLAGS)
   InsertFile(LoadDir() + "mac\SyncDir.dat", _DONT_PROMPT_)
   UnMarkBlock()
   repeat
      while KeyPressed()
         if GetKey() == <Escape>
            stop = TRUE
         endif
      endwhile
      if GetClockTicks() < clock_ticks
         clock_ticks = GetClockTicks()
      else
         if GetClockTicks() - clock_ticks > 15 * 60 * 18    // 15 minutes.
            clock_ticks = GetClockTicks()
            retrieve_log()
            if GetText(1,20) <> "SyncDir running at: "
               AddLine("")
            endif
            AddLine("SyncDir running at: " + get_system_datetime() + ".")
            SaveAs(log_file, SA_FLAGS)
            GotoBufferId(dat_id)
         endif
      endif
   until stop
      or not syncdir()
   retrieve_log()
   AddLine("")
   AddLine("SyncDir stopped at: " + get_system_datetime() + ".")
   SaveAs(log_file, SA_FLAGS)
   PopPosition()
   PopBlock()
   AbandonFile(dirlist_id)
   AbandonFile(transfer_id)
   AbandonFile(restrict_id)
   AbandonFile(in_id)
   AbandonFile(bat_id)
   AbandonFile(log_id)
   AbandonFile(dat_id)
   Set(DateFormat,    old_dateformat)
   Set(TimeFormat,    old_timeformat)
   Set(DateSeparator, old_dateseparator)
   Set(TimeSeparator, old_timeseparator)
   Set(WordSet,       old_wordset)
   Set(break,         old_break)
   Message("SyncDir stopped")
   PurgeMacro("SyncDir")
   if NumFiles() == 0
   or (   NumFiles()                   == 1
      and SubStr(CurrFilename(), 2, 7) == "unnamed")
      if not isMacroLoaded("UtPeg")
         AbandonEditor()
      endif
   endif
end


