/*
   Macro:   Chksave.
   Author:  Carlo Hogeveen <hyphen@xs4all.nl>.
   Date:    10 Februari 1999.
   Version: 2 (14 Februari 1999).
   Version: 3 (16 Februari 1999).
   Version: 4 (26 Februari 1999).

   Purpose: Macro Chksave gives the user the choice what to do, when
            during editing a loaded file is changed by another process.

            If you ignore this choice, then there is a mandatory choice
            when saving the file.

   Target:  This macro was specifically written for TSE 2.50e.
            Users of earlier versions can upgrade TSE or adjust this macro.
            Users of 32-bit TSE versions can use Chgnot13.zip instead.

   Install: Put and compile Chksave.s in TSE's "mac" directory,
            and add Chksave to your macro autoloadlist.

   Notes:   ChkSave doens't check TSE's hidden and system files.

            If a file is renamed inside TSE, then the checking starts anew
            based on the disc date/time of the new filename, and is not
            based on the date/time of the old filename.

            While you are typing, no file-checking is done.
            This ensures that editing is not slowed down.

            ChkSave reacts different to SaveFile() and Saveas( ... ):

               Use SaveFile() in your macro, if you want to check saves
               during the macro and the saved file is still loaded afterwards.

               Use SaveAs(currfilename(), _overwrite_) in your macro,
               if you don't want to check saves during the macro, but this
               means that if the saved file is still loaded afterwards,
               then ChkSave will give an inappropriate warning.

   History: Version 2 only checks non-hidden and non-system files,
            and adds the notify capability (in version 1 files were
            only checked when you saved them).

            Version 3 solves a bug for users who have TSE time configured
            to be represented in 12-hour format: in this format the
            seconds are not shown, so the ChkSave macro wouldn't see it,
            if two users loaded the same file within the same minute.

            Version 4 solves a bug: when closing and opening the same file
            within one TSE session, ChkSave incorrectly thought that the
            file was being modified by another process.
*/



/*
   The following variable says after how many seconds the editor should
   check files for updates by other processes.
   A low value checks often, but might slow down the editor and the computer.
   A high value doesn't interfere with anything, but takes long to notify you.
*/
#define wait_time 5



#define delimiter 3
string temp_filename [255] = "c:\chksave.tse"
string old_filename [255] = ""
integer old_filechanged = 0
integer refresh_id = 0
integer check_id = 0
integer check_time = 0
integer standard_waiting = 18
integer waiting = 18
integer proc blind_changecurrfilename(string new_filename)
   integer old_hookstate = sethookstate(off)
   integer result = changecurrfilename(new_filename, _dont_prompt_|_overwrite_)
   sethookstate(old_hookstate)
   return(result)
end
string proc get_date_time(string filename)
   integer old_timeformat = set(timeformat, 1)
   string result [255] = ""
   string dta [80] = ""
   string s   [80] = ""
   SetDTA(dta)
   if FindFirst(filename)
      s = DecodeDTA(dta)
      result = s[26:8] + " " + s[35:8]
   endif
   set(timeformat, old_timeformat)
   return(result)
end
string proc old_date_time(string filename, integer from_disc)
   string result [255] = ""
   integer file_id = getbufferid()
   if  gotobufferid(check_id)
   and lfind(filename + chr(delimiter), "gi^")
      if from_disc
         result = gettoken(gettext(1, currlinelen()), chr(delimiter), 2)
      else
         result = gettoken(gettext(1, currlinelen()), chr(delimiter), 3)
      endif
   endif
   gotobufferid(file_id)
   return(result)
end
proc dont_save_file()
   old_filename = currfilename()
   old_filechanged = filechanged()
   erasediskfile(temp_filename)
   blind_changecurrfilename(temp_filename)
end
proc refresh_date_time(integer after_saving_or_reloading_a_file)
   integer file_id = getbufferid()
   string filename [255] = currfilename()
   if  gotobufferid(check_id)
   and lfind(filename + chr(delimiter), "gi^")
      lfind(chr(delimiter), "cgi")
      if after_saving_or_reloading_a_file
         right()
         killtoeol()
         inserttext(get_date_time(filename)
                    + chr(delimiter)
                    + get_date_time(filename),
                    _insert_)
      else
         lfind(chr(delimiter), "ci+")
         right()
         killtoeol()
         inserttext(get_date_time(filename), _insert_)
      endif
   endif
   gotobufferid(file_id)
end
proc reload_file()
   pushblock()
   emptybuffer()
   insertfile(currfilename())
   unmarkblock()
   popblock()
   filechanged(false)
   refresh_date_time(true)
end
proc restore_old_filename()
   integer org_id = getbufferid()
   if  old_filename <> ""
   and getbufferid(temp_filename)
      erasediskfile(temp_filename)
      gotobufferid(getbufferid(temp_filename))
      blind_changecurrfilename(old_filename)
      filechanged(old_filechanged)
      if getbufferid() == org_id
         updatedisplay()
      else
         gotobufferid(org_id)
      endif
   endif
   old_filename = ""
   if refresh_id <> 0
      gotobufferid(refresh_id)
      if getbufferid() == refresh_id
         refresh_date_time(true)
      endif
      refresh_id = 0
      gotobufferid(org_id)
   endif
end
proc compare_current_file_to_disc()
   integer org_id = getbufferid()
   string old_filename [255] = currfilename()
   if blind_changecurrfilename(splitpath(old_filename, _drive_)
                               + "\*loaded*"
                               + splitpath(old_filename, _path_|_name_|_ext_))
      pushkey(<enter>)
      pushkey(<spacebar>)
      pushkey(<enter>)
      pushkeystr(old_filename)
      pushblock()
      unmarkblock()
      pushposition()
      begfile()
      execmacro("cmpfiles")
      onewindow()
      popposition()
      popblock()
      while getbufferid(old_filename)
         gotobufferid(getbufferid(old_filename))
         updatedisplay()
         message("Identical loaded filenames: change the new file's name")
         changecurrfilename()
      endwhile
      gotobufferid(org_id)
      blind_changecurrfilename(old_filename)
   else
      message("Cannot change name to: ",
              splitpath(old_filename, _drive_)
              + "*loaded*"
              + splitpath(old_filename, _path_|_name_|_ext_))
      delay(99)
      message("Current filename: ", currfilename())
      delay(99)
   endif
   updatedisplay()
end
proc idle_check_file()
   string answer [1] = ""
   restore_old_filename()
   if buffertype() == _normal_
      if get_date_time(currfilename()) <> old_date_time(currfilename(), false)
         repeat
            updatedisplay()
            answer = " "
            if ask(
"File updated by another process: C(ompare), R(eload) or <escape>?",
                   answer)
            else
               answer = "n"
            endif
            answer = lower(answer)
            if answer == "c"
               compare_current_file_to_disc()
            endif
         until answer in "r", "n"
         case answer
            when "r"
               reload_file()
               updatedisplay()
            otherwise // answer = "n"
               refresh_date_time(false)
         endcase
         check_time = getclockticks()
      endif
   endif
end
proc idle()
/* It is quite possible to miss "if clockticks mod waiting == 0"
   when it comes along, because the editor is busy or it is running
   in the background. If this happens, then "waiting" is temporarily
   set to the low value of one second, to speed things up: this trick
   really helps for instance to get a quicker notification as soon as the
   editor becomes the foreground process again (tested with Windows98).
*/
   integer org_id = getbufferid()
   integer start_id = 0
   integer clockticks = getclockticks()
   if clockticks - check_time > waiting
      if clockticks mod waiting == 0
         if buffertype() == _normal_
            start_id = getbufferid()
         else
            nextfile()
            start_id = getbufferid()
         endif
         if start_id
            repeat
               nextfile()
               idle_check_file()
            until getbufferid() == start_id
         endif
         gotobufferid(org_id)
         waiting = standard_waiting
      else
         waiting = 18
      endif
   endif
end
proc after_command()
   check_time = getclockticks()
end
proc on_file_save()
   string answer [1] = ""
   restore_old_filename()
   if buffertype() == _normal_
      if get_date_time(currfilename()) <> old_date_time(currfilename(), true)
         repeat
            updatedisplay()
            answer = " "
            ask(
"File updated by another process: C(ompare), O(verwrite), R(eload) or N(osave)?",
                answer)
            answer = lower(answer)
            if answer == "c"
               compare_current_file_to_disc()
            endif
         until answer in "o", "r", "n"
         case answer
            when "o"
               refresh_id = getbufferid() // File is saved after hook.
            when "r"
               reload_file()
               dont_save_file()
            otherwise // answer = "n"
               dont_save_file()
         endcase
      else
         refresh_id = getbufferid() // File is saved after hook.
      endif
   endif
end
proc on_first_edit()
   integer file_id = getbufferid()
   string filename [255] = currfilename()
   if buffertype() == _normal_
      if check_id == 0
         check_id = createtempbuffer()
      endif
      gotobufferid(check_id)
      if lfind(filename + chr(delimiter), "gi^")
         killline()
      endif
      addline(filename
              + chr(delimiter)
              + get_date_time(filename)
              + chr(delimiter)
              + get_date_time(filename))
      gotobufferid(file_id)
   endif
end
proc on_changing_files()
   integer file_id = getbufferid()
   string filename [255] = currfilename()
   if buffertype() == _normal_
      if check_id == 0
         check_id = createtempbuffer()
      endif
      gotobufferid(check_id)
      if not lfind(filename + chr(delimiter), "gi^")
         addline(filename
                 + chr(delimiter)
                 + get_date_time(filename)
                 + chr(delimiter)
                 + get_date_time(filename))
      endif
      gotobufferid(file_id)
   endif
end
proc Whenloaded()
   standard_waiting = wait_time * 18
   waiting = standard_waiting

   hook(_on_first_edit_,      on_first_edit)
   hook(_on_changing_files_,  on_changing_files)
   hook(_on_file_save_,       on_file_save)
   hook(_after_command_,      after_command)
   hook(_idle_,               idle)

   hook(_idle_,               restore_old_filename)
   hook(_on_changing_files_,  restore_old_filename)
   hook(_on_file_quit_,       restore_old_filename)
   hook(_on_exit_called_,     restore_old_filename)
   hook(_after_command_,      restore_old_filename)
end
