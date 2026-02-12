===

1. -To install

     1. -Take the file bulkfind_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstallbulkfind.bat

     4. -That will create a new file bulkfind_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          bulkfind.mac

2. -The .ini file is the local file 'bulkfind.ini'
    (thus not using tse.ini)

===

/*
  Macro           BulkFind
  Author          Carlo.Hogeveen@xs4all.nl
  Version         v1.0.1 - 3 Feb 2020
  Compatibility   Windows TSE Pro v4.0 upwards,
                  Linux TSE Pro v4.41.24 upwards.

  This tool searches for a list of search terms in a list of files or in all
  open files.

  Input
    Default files to search: All opened files except the current file.
    Default terms to search for: The lines in the current file.
    Default search options: "i".
  Output
    Default output: A new buffer.
    Default output format: HELP (TSE's built-in Help format).

  You can change the defaults by optionally providing these macro parameters
    in=<name of file containing a list of files to search in>
    for=<name of file containg the list of search terms>
    opt=<the search options>
    out=<name of file to write the results to>
    fmt=<the output's initial display format>
  Where
    Parameters must be separated by spaces.
    Unless specified otherwise parameters are case-insentitive.
    It is strongly advised but not mandatory that file names have full paths.
    Quotes are optional for parameters containing no spaces.
    The "for" file may only have one search term per line; leading and trailing
    spaces are stripped unless the search term is quoted with either quote.
    Only these five TSE search options are allowed: "^iwx$".
    The default search options are "i"; an explicit "opt=" turns "i" off.
    Output display formats are "HELP" (default), "FINDS" and "TEXT".
    The HELP format displays the results in a browse mode like TSE's
    built-in Help with each found string nicely hilited.
    The FINDS format displays the results in a browse mode like TSE's
    built-in "View Finds" you get after a TSE search with the "v" option.
    Escaping the HELP and FINDS browse modes or selecting a line with <Enter>
    goes to the TEXT display mode, which here stands for the full editor.

  If the CmdLineParameter macro is installed, then BulkFind will accept the
  above parameters too after the " -p " command line option.
  See the documentation of CmdLineParameter for more.

  EXAMPLES PREMIS
  Let us find out if any of the 2943 male first names from
    http://www.cs.cmu.edu/Groups/AI/util/areas/nlp/corpora/names/male.txt
  occur in any TSE macro source files.

  EXAMPLE METHOD 1
  Open all TSE macro source files with
    -a <insert your TSE folder>\mac\*.s*
  Then open a new empty file and copy the names from the above link into it.
  Then run this command from the Macro Execute menu:
    BulkFind opt=iw

  EXAMPLE METHOD 2
  Open all TSE macro source files with
    -a <insert your TSE folder>\mac\*.s*
  Copy (the content of) the above male.txt file to "C:\male.txt".
  Then run this command from the Macro Execute menu:
    BulkFind for=c:\male.txt opt=iw fmt=text

  TODO
    MUST
    SHOULD
    COULD
    WONT

  HISTORY
  v0.1 - 18 Jan 2020
    Initial beta release. Enough works to be already useful.
  v0.2 - 20 Jan 2020
    Documented that the "out=<outputfile>" parameter does not work yet.
  v0.3 - 25 Jan 2020
    Made the "out=<outputfile>" parameter work.
    If the "in" and "for" file were not opened before BulkFind,
    then they are no longer open after BulkFind.
    Implemented the "fmt=finds" parameter.
    In the default output "HELP" display mode the multiple result lines for
    multiple search results in the same line are now merged into one line.
    Improved the afterwards cursor positioning.
    Fixed some very minor bugs.
    Improved the documentation.
  v0.4 - 26 Jan 2020
    Reduced memory usage and increased search capability by only temporarily
    loading unloaded files.
  v0.5 - 27 Jan 2020
    Fixed message line flashing.
    Fixed duplicate lines.
    Made BulkFind compatible with Linux TSE Pro v4.41.20 upwards.
    Fred H Olson reported that under Linux BulkFind does not understand "~/".
      Found out that Linux TSE does understand "~/" for some high-level TSE
      commands, but not (yet?) for these five low-level TSE commands:
        FileExists()
        FindFirstFile()
        fOpen()
        InsertFile()
        LoadBuffer()
      "Fixed" it by only for Linux replacing any of these low-level TSE
      commands that BulkFind was using with a high-level TSE command.
  v1.0 - 2 Feb 2020
    No more bug reports and no more plans for new features.
    Tweaked the documentation a bit and moved the tool out of the Beta section.
  v1.0.1 - 3 Feb 2020
    Fix specific to Linux:
      Semware fixed the above five low-level TSE commands in TSE Pro v4.41.24.
      I fixed BulkFind to no longer use work-arounds for these commands.
      BulkFind now requires TSE Pro v4.41.24 upwards for Linux.
*/
