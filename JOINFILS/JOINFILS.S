/*
   Macro.         Joinfils.
   Author.        Carlo Hogeveen (hyphen@xs4all.nl).
   Date-written.  20 august 1998.

   The macro should be started from the command-line with:

      E -EJOINFILS

   The macro asks for two file containing records and for the column
   positions of the common key of those records.


   Let's call the two files file1 and file2.

   File1 and file2 are joined to a new file.

   File1 and file2 must have keys in common, which need not be in the
   same columns, but which must have fixed column positions in each file.

   The records of file2 are placed behind the records of file1,
   separated by the character ":".

   If the keys match, then the records are placed on the same line.

   If there are multiple matches, then the first record of file1 is
   duplicated until all matching records of file2 are processed,
   and then the remaining matching records (if any) of file1 are written.

   In other words, this macro works o.k. if there is a one to many
   relationship between the records of file1 and file2, but not
   the other way around.
*/

integer file1_id = 0
integer file1_column_from = 0
integer file1_column_thru = 0
integer file2_id = 0
integer file2_column_from = 0
integer file2_column_thru = 0
integer end_of_file1 = false
integer end_of_file2 = false
integer file1_key_length = 0
integer file2_key_length = 0
integer file1_record_length = 0
integer file2_record_length = 0
integer new_id = 0

string key1[255] = ""
string key2[255] = ""

#ifdef WIN32
#else
   integer proc longestlineinbuffer()
      integer result = 0
      pushposition()
      begfile()
      repeat
         if result < currlinelen()
            result = currlinelen()
         endif
      until not down()
      popposition()
      return(result)
   end
#endif

proc get_file(     string  file_number,
               var integer file_id,
               var integer column_from,
               var integer column_thru)
   string filename[255] = ""
   string answer[255] = ""
   if  ask("File " + file_number + " to join:", filename)
   and fileexists(filename)
   and editfile(filename)
      file_id = getbufferid()
      begfile()
      down(10)
      updatedisplay(_all_windows_refresh_)
      if ask("File " + file_number + " column from:", answer)
         column_from = val(answer)
         if  column_from >= 1
         and column_from <= longestlineinbuffer()
            markcolumn(1, column_from, numlines(), column_from)
            updatedisplay(_all_windows_refresh_)
            if ask("File " + file_number + " column thru:", answer)
               column_thru = val(answer)
               if  column_thru >= 1
               and column_thru <= longestlineinbuffer()
               and column_thru >= column_from
                  markcolumn(1, column_from, numlines(), column_thru)
                  updatedisplay(_all_windows_refresh_)
               else
                  warn("Illegal value column thru: ", answer)
                  abandoneditor()
               endif
            else
               warn("Not answered column thru: ", answer)
               abandoneditor()
            endif
         else
            warn("Illegal value column from: ", answer)
            abandoneditor()
         endif
      else
         warn("Not answered column from: ", answer)
         abandoneditor()
      endif
   else
      warn("Error reading file: ", filename )
      abandoneditor()
   endif
end

proc add_record(integer file_id, integer record_length)
   integer org_id = getbufferid()
   integer column_from = 0
   integer part_length = 0
   string record_part [255] = ""
   for column_from = 1 to record_length by 255
      if record_length - column_from + 1 > 255
         part_length = 255
      else
         part_length = record_length - column_from + 1
      endif
      gotobufferid(file_id)
      record_part = gettext(column_from, part_length)
      gotobufferid(new_id)
      inserttext(format(record_part:part_length * -1), _insert_)
   endfor
   gotobufferid(org_id)
end

proc make_new_record()
   gotobufferid(new_id)
   addline()
   begline()
   add_record(file1_id, file1_record_length)
   inserttext(":", _insert_)
   add_record(file2_id, file2_record_length)
end

proc next_file1()
   gotobufferid(file1_id)
   if currline() == numlines()
      addline()
      end_of_file1 = true
   else
      killline()
      key1 = gettext(file1_column_from, file1_key_length)
   endif
end

proc next_file2()
   gotobufferid(file2_id)
   if currline() == numlines()
      addline()
      end_of_file2 = true
   else
      killline()
      key2 = gettext(file2_column_from, file2_key_length)
   endif
end

proc balance_lines()
   string key1_written[255] = ""
   file1_key_length = file1_column_thru - file1_column_from + 1
   file2_key_length = file2_column_thru - file2_column_from + 1

   gotobufferid(file1_id)
   file1_record_length = longestlineinbuffer()
   markcolumn(1, file1_column_from, numlines(), file1_column_thru)
   execmacro("sort")
   unmarkblock()
   begfile()
   key1 = gettext(file1_column_from, file1_key_length)

   gotobufferid(file2_id)
   file2_record_length = longestlineinbuffer()
   markcolumn(1, file2_column_from, numlines(), file2_column_thru)
   execmacro("sort")
   unmarkblock()
   begfile()
   key2 = gettext(file2_column_from, file2_key_length)

   repeat
      if end_of_file1
         make_new_record()
         next_file2()
      else
         if end_of_file2
            if key1 <> key1_written
               make_new_record()
            endif
            next_file1()
         else
            if key1 == key2
               key1_written = key1
               make_new_record()
               next_file2()
            else
               if key1 > key2
                  gotobufferid(file1_id)
                  insertline()
                  make_new_record()
                  gotobufferid(file1_id)
                  killline()
                  next_file2()
               else
                  if key1 == key1_written
                     next_file1()
                  else
                     gotobufferid(file2_id)
                     insertline()
                     make_new_record()
                     gotobufferid(file2_id)
                     killline()
                     next_file1()
                  endif
                  key1_written = ""
               endif
            endif
         endif
      endif
   until end_of_file1 and end_of_file2
end

proc main()
   get_file("1", file1_id, file1_column_from, file1_column_thru)
   get_file("2", file2_id, file2_column_from, file2_column_thru)
   if yesno("Proceed with these choices?")
      new_id = createbuffer("c:\*read\only*\joined.fil")
      if new_id == 0
         warn("Cannot create c:\*read\only*\joined.fil")
         abandoneditor()
      else
         emptybuffer()
         balance_lines()
         gotobufferid(new_id)
         filechanged(false)
         abandonfile(file1_id)
         abandonfile(file2_id)
      endif
   else
      abandoneditor()
   endif
end
