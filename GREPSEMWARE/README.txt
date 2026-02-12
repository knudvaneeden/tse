TSE grep.s has been extended to do the search instead
of using the default

1. -TSE Semware grep.exe (located in your <TSE> installation
    directory) to optionally and alternatively also do the
    grep using e.g.

     TSE Semware grep

     GNU grep

     Pcre2grep grep

     Embarcadero BCC version 1.02 grep

     Embarcadero BCC version 55 grep

     Cygwin grep

     MingW grep

     Julia grep

     Octave grep

2. -Further is the installation of these programs not
    included, so has be performed by yourself, by
    downloading and installing these from the Internet

    So you will have to install the relevant for you grep
    implementations (e.g. only GNU).

3. -Further do you have to put the full path to TSE Semware
    grep.exe (located in your TSE installation directory) in
    the file grepsemware.ini (see one of the first line
    lines where you see 'tse', replace the full path there)

4. -To download goto

      https://github.com/knudvaneeden/ddd/blob/TRUNK/GREPSEMWARE/grepsemware_knud.zip

     and click on the 3 dots '...' at the bottom right and select 'Download'.

5. -To install unzip the file grepsemware_knud.zip in any
    arbitrary directory.

6. -Then run the file 'zipinstallgrepsemware.bat'

7. -That will re-compile the .s and .si files in that
    directory.

8. -Make sure that sc32.exe is in your PATH, otherwise edit
    that .bat file and replace 'sc32' with the full path to
    your sc32.exe (located in your TSE installation
    directory), then save the file and run it again.

9. -That creates thus a new grepsemware_knud.zip file.
    That will be your installation file
    from now on.

10. -Take that installation .zip file and unzip it again in
     any arbitrary other directory.

11. -Advised is in general to save your work in TSE first.

12. -Then run this TSE macro in that directory

      grepsemware.mac

     (you must supply the full path, e.g.

       c:\temp\foobar\grepsemware.mac

13. -This program is with regard to TSE fully stand alone
    thus.

    It can be run anywhere basically.

    So no dependence on or installation in e.g.

     -LoadDir() directories,

     -TSE mac directory, ...

     This because all information should be stored in one
     and the same directory.

     It does also not use

      tse.ini

     but thus a stand alone  .ini in that directory.

14. -You should backup, open and edit once the file
     grepsemware.ini in which you will find the different
     grep information in the format:

[grepsemware]

// format: comma separated list with: name of grep, TSE macro name which handles the grep output, the parameters to always add the line number + always add the filename in front, the executable filename

E.g. in each line a different grep implementation:

grep01S=tse, grepsemwaretse, , f:\wordproc\tse32_v44200\grep.exe

grep02S=gnu, grepsemwaregnu, -n -H, g:\search\regularexpression\gnu\bin\grep.exe

grep03S=pcre2grep, grepsemwarepcre2grep, -n -H, g:\search\regularexpression\pcregrep\pcre2grep.exe

grep04S=embarcaderobcc55, grepsemwareembarcaderobcc55, -n+ -o+, g:\borland\bcc55\bin\grep.exe

grep05S=embarcaderobcc102, grepsemwareembarcaderobcc102, -n+ -o+, g:\borland\bcc102\bin\grep.exe

grep06S=cygwin, grepsemwarecygwin, -n -H, g:\cygwin\bin\grep.exe

grep07S=mingw, grepsemwaremingw, -n -H, g:\language\computer\cpp\mingw\msys\1.0\bin\grep.exe

grep08S=julia, grepsemwarejulia, -n -H, g:\language\computer\julia\git\bin\grep.exe

grep09S=octave, grepsemwareoctave, -n -H, g:\language\computer\octave\octave-4.2.0-w64\bin\grep.exe

15. -You should change the file path on your system to match
     that of the installation of your grep (e.g. GNU,
     pcre2grep, ...), backup and save the file.

16. -The TSE macro files

      grepsemwaretse.s

      grepsemwaregnu.s

      grepsemwarepcre2grep.s

      grepsemwareembarcaderobcc55.s

      grepsemwarembarcaderobcc102.s

      grepsemwarecygwin.s

      grepsemwaremingw.s

      grepsemwarejulia.s

      grepsemwareoctave.s

      ...

     take care of removing any non-relevant text
     and converting the lines

      filename : linenumber : found text

     to the default TSE grep notation

---

17. -The method used to run these different grep versions is
     to

a. force those different grep versions to always include
   line numbers in each found line

b. force those different grep versions to always include the
   filename in front of each line

Typical parameters for that are '-n -H' in the Unix like
 grep implementations.

Note that Semware TSE grep also uses this method, as it
always concatenates '-n' to the search options which always
includes thus line numbers. But TSE grep.s does not use the
-f parameter to add also the filename in front of each
line. In this version you can also use -f as parameter.

c. So for each grep version you convert from this format to
   the TSE Semware grep.s default format:

Before:

--- cut here: begin --------------------------------------------------
c:\temp\foobar1.txt:1       a
c:\temp\foobar1.txt:2       a
c:\temp\foobar1.txt:3       a
c:\temp\foobar1.txt:4       a
c:\temp\foobar2.txt:1       a
c:\temp\foobar2.txt:2       a
c:\temp\foobar2.txt:3       a
c:\temp\foobar2.txt:4       a
--- cut here: end ----------------------------------------------------

Output after:

--- cut here: begin --------------------------------------------------
c:\temp\foobar1.txt
1: a
2: a
3: a
4: a
c:\temp\foobar2.txt
1: a
2: a
3: a
4: a
--- cut here: end ----------------------------------------------------

18. -Note further that you yourself will have to choose the
     correct search option parameters for each of the grep.

      type e.g.

       grep.exe --help

      or

       grep.exe ?

to see options.

19. -To recursively search directories you use for most
     implementations e.g.

      --directories=recurse

     (in TSE Semware grep this has to be '-s' for example)

20. -Disclaimer: Feel free to use this software anyway you
                 want, but if you use it it is always at
                 your own risk.

with friendly greetings
Knud van Eeden
