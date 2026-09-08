/**************************************************************************
  Filt        Sends one or more lines to an external filter program

  Author:     Bill Stewart

  Date:       Nov 24, 1995

  Overview:

  This macro will send the line(s) touched by any type of block to an
  external filter program. The filtered line(s) are then inserted back in
  the file, replacing the old line(s).

  Keys:       (none)

  Usage notes:

  This macro lets you filter lines like in many UNIX editors such as vi.
  For example, to reformat a paragraph in vi, you type "!}fmt" and press
  Enter to reformat the remainder of the current paragraph (assuming the
  "fmt" command is available).

  This macro only filters entire lines. The macro temporarily defines a
  _LINE_ block that spans the lines on which the marked block exists,
  writes those lines to a temporary file, passes it through the specified
  filter (writing the output to another temporary file), deletes the marked
  _LINE_ block, then reinserts the filtered lines back into the file. If
  the results are unsatisfactory, you can restore the replaced lines with
  the undelete command.

  The lines that were processed remain marked as a _LINE_ block after the
  macro is finished, as a visual display of the lines that were processed.
  The macro also displays the number of lines sent to the filter, as well
  as the number of lines returned to the editor; for example, "7 line(s)
  out, 8 line(s) back".

  The macro allows a command-line argument that specifies the name of the
  filter program to use. If no command-line argument is specified, the
  macro will ask what program it should use. This information is kept in a
  history list for future use.

  Note that if the filter program doesn't exist or DOS couldn't find it,
  the lines spanned by the block will simply be deleted. To get them back,
  use the undelete command.

**************************************************************************/

integer filt_history

// Creates a temporary file in the current directory and returns its name;
// uses a .TMP extension to identify its type to the OS
string proc MakeTempFile()
  return(maketempname("", ".TMP"))
end

// Returns the number of lines spanned by a block
integer proc NumLinesInBlock()
  integer nlib = 0

  if isblockmarked()
    nlib = query(blockendline) - query(blockbegline)
    nlib = nlib + 1
  endif
  return(nlib)
end

proc Main()
  integer ok = TRUE, numbefore = 0
  string filt_prog[128] = "", linesout[79] = "", linesin[79] = ""

  if isblockmarked()
    filt_prog = query(macrocmdline)     // check for command-line arguments
    if filt_prog == ""                  // if there aren't any, prompt
      ok = ask("Filter lines through:", filt_prog, filt_history) and (length(filt_prog) > 0)
    endif
    if ok
      pushposition()
      markline(query(blockbegline), query(blockendline))
      numbefore = NumLinesInBlock()     // how many lines to process?
      gotoblockbegin()
      begline()
      linesout = MakeTempFile()         // the file to write the block to
      linesin = MakeTempFile()          // the filtered lines will be here
      saveblock(linesout)               // write the lines
      dos(format(filt_prog, " < ",  linesout, " > ", linesin), _DONT_PROMPT_ | _TEE_OUTPUT_)
      delblock()                        // delete the lines
      insertfile(linesin)               // insert the filtered lines
      popposition()
      erasediskfile(linesout)           // delete the temporary files
      erasediskfile(linesin)
      message(numbefore, " line(s) out, ", NumLinesInBlock(), " line(s) back")
    endif
  else
    warn("No block marked")
  endif
end

proc WhenLoaded()
  filt_history = getfreehistory("FILT:filt_history")
end

proc WhenPurged()
  delhistory(filt_history)
end
