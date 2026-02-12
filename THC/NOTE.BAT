:NOTE - T/H/C NOTE TAKER ADDS DATE AND TIME STAMPED NOTES TO FILE
: Create versions of this file with different names to provide for taking
: notes on different subjects, or change the NOTEFILE to use a filename
: you specify on your command line.  Make directory NOTES if you regularly
: take notes on particular subjects.  Then use command NOTE "LONG SUBJECT"
: or NOTE SUBJECT (no quotes) to add a note to the subject file in NOTES.
: CLOCK.EXE must be on a path in your PATH statement.
@echo off
colormsg " Type your note, then press F6 followed by RETURN at the start of a line. "
if x%1==x goto nosubject
clock>>c:\notes\%1
type con>>c:\notes\%1
goto done
:nosubject
clock>>c:\notefile
type con>>c:\notefile
:done
