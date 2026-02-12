/**************************************************************************
  Filt        Sends one or more lines to an external filter program

  Author:     Bill Stewart

  Date:       Feb 23, 2001

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

  History:

  Version 2 (02/23/2001):

  o  Places temporary files in the TEMP directory.
  o  More error checking (Could temp file be created?, etc.).
  o  Temporary file variable lengths increased to 255 characters.

  Version 1 (11/24/1995):

  o  Initial version.

**************************************************************************/

integer filt_history

// Creates a temporary file in the current directory and returns its name;
// uses a .TMP extension to identify its type to the OS; places the file in
// the directory pointed to by the TEMP environment variable
string proc MakeTempFile()
  string tempdir[255] = ""

  tempdir = getenvstr("TEMP")
  if tempdir == ""
    tempdir = getenvstr("TMP")
    if tempdir == ""
      tempdir = currdir()
    endif
  endif
  return(maketempname(tempdir, ".TMP"))
end

// Returns the number of lines spanned by a block
integer proc NumLinesInBlock()
  integer nlib = 0

  if isblockmarked()
    nlib = query(blockendline) - query(blockbegline) + 1
  endif
  return(nlib)
end

proc Main()
  integer ok = TRUE, numbefore = 0
  string filt_prog[255] = "", linesout[255] = "", linesin[255] = ""


  if isblockincurrfile()
    filt_prog = query(macrocmdline)     // check for command-line arguments
    if filt_prog == ""                  // if there aren't any, prompt
      ok = ask("Filter lines through:", filt_prog, filt_history) and (length(filt_prog) > 0)
    endif
    if ok
      pushposition()
      markline(query(blockbegline), query(blockendline))
      numbefore = NumLinesInBlock()            // how many lines to process?
      linesout = MakeTempFile()                // the file to write block to
      linesin = MakeTempFile()                 // filtered lines will be here
      if saveblock(linesout, _OVERWRITE_ | _DONT_PROMPT_)
        dos(format(filt_prog, " < ",  linesout, " > ", linesin), _DONT_PROMPT_ | _TEE_OUTPUT_)
        delblock()                             // delete the lines
        if insertfile(linesin, _DONT_PROMPT_)  // insert the filtered lines
          popposition()
          erasediskfile(linesout)              // delete the temporary files
          erasediskfile(linesin)
          message(numbefore, " line(s) out, ", NumLinesInBlock(), " line(s) back")
        else
          warn("Could not insert temporary file ")
          undelete()
        endif
      else
        warn("Could not create temporary file ")
      endif
    endif
  else
    warn("No block in current file")
  endif
end

proc WhenLoaded()
  filt_history = getfreehistory("FILT:filt_history")
end

proc WhenPurged()
  delhistory(filt_history)
end
