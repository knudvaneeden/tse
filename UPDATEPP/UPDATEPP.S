/*
   Macro.         Updatepp.
   Author.        Carlo Hogeveen (hyphen@xs4all.nl).
   Date-written.  4 May 1998.

   This macro might typically be used to update a local Potpourri
   from a server, not overwriting the user's private Potpourri
   descriptions.

   This macro should be executed from within TSE with Macro Execute:

      updatepp inquiry|update <source_drive_path_filename> <destination_drive_path_filename>

   This will update the macro descriptions in the destination potpourr.dat
   based on the macro descriptions in the source potpourr.dat:
    - macro's that exist only in the source are added to the destination.
    - macro's that exist only in the destination are left there unchanged.
    - macro's that exist and differ in both potpourr.dat files are ruthlessly
      updated in the destination potpourr.dat.

   The macro ends in an unsaved logfile "c:\updatepp.log",
   which will consist of an empty line, if there were no updates.
*/


proc find_next_macro(integer file_id, var string macro_name, var integer macro_id)
   gotobufferid(file_id)
   if lfind("^[~ ]", "x+")
      macro_name = lower(getword())
      pushposition()
      markline()
      if lfind("^[~ ]", "x+")
         up()
      else
         endfile()
      endif
      while not lfind("[~ ]", "cgx")
         up()
      endwhile
      markline()
      copy()
      gotobufferid(macro_id)
      emptybuffer()
      paste()
      endfile()
      addline("")
      begfile()
      popposition()
   else
      macro_name = chr(255)
      endfile()
   endif
end


proc add_source_macro_to_destination(var integer source_macro_id, var integer destination_file_id)
   gotobufferid(source_macro_id)
   markline(1, numlines())
   copy()
   gotobufferid(destination_file_id)
   if currline() == numlines()
      addline()
   endif
   paste()
   if not lfind("^[~ ]", "x+")
      endfile()
   endif
end


integer proc macros_equal(integer source_macro_id, integer destination_macro_id)
   integer result                 = true
   integer source_lines           = 0
   integer destination_lines      = 0
   integer line                   = 0
   string  source_line      [255] = ""
   string  destination_line [255] = ""
   gotobufferid(source_macro_id)
   begfile()
   source_lines = numlines()
   gotobufferid(destination_macro_id)
   begfile()
   destination_lines = numlines()
   if source_lines == destination_lines
      for line = 1 to source_lines
         gotobufferid(source_macro_id)
         endline()
         source_line = gettext(1, currcol() - 1)
         down()
         gotobufferid(destination_macro_id)
         endline()
         destination_line = gettext(1, currcol() - 1)
         down()
         if source_line <> destination_line
            result = false
         endif
      endfor
   else
      result = false
   endif
   return(result)
end


proc update_macro(integer source_macro_id, integer destination_file_id)
   gotobufferid(destination_file_id)
   markline()
   if lfind("^[~ ]", "x+")
      up()
   else
      endfile()
   endif
   markline()
   killblock()
   if currline() == numlines()
      addline()
   endif
   gotobufferid(source_macro_id)
   markline(1, numlines())
   copy()
   gotobufferid(destination_file_id)
   paste()
end


proc update_log(integer log_id, string macro_name, integer destination_file_id, integer new_macro)
   string destination_file_name [50] = ""
   gotobufferid(destination_file_id)
   destination_file_name = currfilename()
   gotobufferid(log_id)
   endfile()
   if new_macro
      addline("rem   In "
              + destination_file_name
              + ": "
              + macro_name
              + " added.")
   else
      addline("rem   In "
              + destination_file_name
              + ": "
              + macro_name
              + " updated.")
   endif
end


proc updatepp(integer source_file_id, integer destination_file_id, integer log_id)
   string  source_macro_name      [12] = ""
   string  destination_macro_name [12] = ""
   integer old_uap  = set(unmarkafterpaste, on)
   integer old_ilba = set(insertlineblocksabove, on)
   integer source_macro_id = createtempbuffer()
   integer destination_macro_id = createtempbuffer()
   pushblock()
   unmarkblock()

   find_next_macro(source_file_id, source_macro_name, source_macro_id)
   find_next_macro(destination_file_id, destination_macro_name, destination_macro_id)
   while source_macro_name      <> chr(255)
   or    destination_macro_name <> chr(255)
      if source_macro_name < destination_macro_name
         add_source_macro_to_destination(source_macro_id, destination_file_id)
         update_log(log_id, source_macro_name, destination_file_id, true)
         find_next_macro(source_file_id, source_macro_name, source_macro_id)
      else
         if source_macro_name > destination_macro_name
            find_next_macro(destination_file_id, destination_macro_name, destination_macro_id)
         else
            if not macros_equal(source_macro_id, destination_macro_id)
               update_macro(source_macro_id, destination_file_id)
               update_log(log_id, source_macro_name, destination_file_id, false)
            endif
            find_next_macro(source_file_id, source_macro_name, source_macro_id)
            find_next_macro(destination_file_id, destination_macro_name, destination_macro_id)
         endif
      endif
   endwhile

   gotobufferid(source_macro_id)
   abandonfile()
   gotobufferid(destination_macro_id)
   abandonfile()
   popblock()
   set(unmarkafterpaste, old_uap)
   set(insertlineblocksabove, old_ilba)
end


integer proc load_file(var string file_name, var integer file_id)
   integer result = false
   if file_name > " "
      if file_name[2] == ":"
         if getbufferid(file_name)
            warn("Updatepp error: parameter ", file_name, " is already loaded")
         else
            if fileexists(file_name)
               file_id = editfile(file_name)
               result = true
            else
               warn("Updatepp error: parameter ", file_name, " does not exist")
            endif
         endif
      else
         warn("Updatepp error: parameters should be full drive/path/filenames")
      endif
   else
      warn("Updatepp error: parameter(s) missing")
   endif
   return(result)
end


proc main()
   string inquiry_or_update      [8] = gettoken(query(macrocmdline), " ", 1)
   string source_file_name      [50] = gettoken(query(macrocmdline), " ", 2)
   string destination_file_name [50] = gettoken(query(macrocmdline), " ", 3)
   integer source_file_id = 0
   integer destination_file_id = 0
   integer log_id = 0

   if lower(inquiry_or_update) in "inquiry", "update"
      if editfile("c:\updatepp.log")
         log_id = getbufferid()
         emptybuffer()
         if load_file(source_file_name, source_file_id)
            if load_file(destination_file_name, destination_file_id)
               updatepp(source_file_id, destination_file_id, log_id)
               gotobufferid(destination_file_id)
               if inquiry_or_update == "update"
                  savefile()
               endif
               abandonfile()
            endif
            gotobufferid(source_file_id)
            abandonfile()
         endif
         gotobufferid(log_id)
         filechanged(false)
         begfile()
      else
         warn("Updatepp error: cannot edit c:\updatepp.log")
      endif
   else
      warn("Updatepp error: illegal first parameter")
   endif
end
