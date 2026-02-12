/****************************************************************************
                           CmdLine, Version 3
                                9-13-93
                              David Marcus

                          Additional Examples

This a portion of my current setup. It includes
     * A reinterpretation of -N so as to go to line,col
       which you would use in the format

          e foo -n12,34

     * A -P option to print all files on the command line:

          e filespec [filespec]... -p

     * The use of an external macro to load files that is incurred
       whenever TSE is loaded and -e is not used. This external macro is
       not included.

NOTE: This file compiles with the following grumbles; they are not a problem.

Compilingùùùùùùù
Note    003  (40,18)    Possibly infinite loop
Warning 051  (77,34)    Variable 'linecol_hist' possibly used before initialization
Warning 051  (77,48)    Variable 'linecol_hist' possibly used before initialization
Writing output to file 'q:\cmdexam.mac'

*****************************************************************************/

#INCLUDE 'q:\cmdline.s'

forward proc linecolumn(string arg)
forward proc PrintFiles()
proc WhenLoaded()

     integer lwfi
     string files[75]




  /* PrintFiles, exit TSE */

     if CmdLineOptionUsed('p') or CmdLineOptionUsed('P')
          Set(LoadWildFromInside, Query(LoadWildfromDOS))
          Editfile( CmdLineFiles() )
          PrintFiles()
     endif

  /* GotoLine,Column */
     if (CmdLineOptionUsed('n') or CmdLineOptionUsed('N'))
         AND Length(GetGlobalStr('CmdLineArgForN'))
          LWFI = Set(LoadWildFromInside, Query(LoadWildfromDOS))
          files = CmdLineFiles()
          if EditFile( files )
               LineColumn(GetGlobalStr('CmdLineArgForN'))
          else
               Set(DOSCmdLine, Query(DOSCmdLine) + ' ' + files)
          endif
          Set(LoadWildFromInside, LWFI)
     endif

  /* LoadFiles() */
  /***************** NOT INCLUDED *************************
     if NOT Pos('-e', Query(DOSCmdLine))           // if not executing macro
          if CmdLineOptionUsed('a')                         // If -a used
              AND GetGlobalStr('CmdLineArgForA') == '-'     // and '-' is arg to it
               SetGlobalStr('LoadFilesLoadWild', 'FALSE')         // tell LoadFile to not
          else                                              //   load wildly
               SetGlobalStr('LoadFilesLoadWild', 'TRUE')
          endif
          SetGlobalStr("LoadFilesArgument", CmdLineFiles())
          ExecMacro('loadfile')
     endif
   ********************************************************/

end

proc PrintFiles()
     if NumFiles() > 1
          case yesNo('Print all ' + Str(NumFiles()) + ' files?')
          when 1 loop
                 Set(QuitToPrompt,FALSE)
                 PrintFile()
                 if NumFiles() == 1
                      AbandonEditor()
                 else
                      AbandonFile()
                 endif
            endloop
          when 2 loop
                 case yesNo( 'Print ' + CurrFileName() )
                    when 1
                         Set(QuitToPrompt,FALSE)
                         PrintFile()
                         if NumFiles() == 1
                              AbandonEditor()
                         else
                              AbandonFile()
                         endif
                    when 2
                         if NumFiles() == 1
                              AbandonEditor()
                         else
                              AbandonFile()
                         endif
                    when 0,3
                         AbandonEditor()
                 endcase
            endloop
          when 0,3
               AbandonEditor()
          endcase
     else
          PrintFile()
          AbandonEditor()

     endif
end

proc linecolumn(string arg)
     STRING s[12]='',
            l[5]='', c[10]='', plus_l[1] = '', plus_c[1] = ''
     INTEGER linecol_hist = iif (linecol_hist, linecol_hist, GetFreeHistory())

     if NOT Length(arg)
          if NOT Ask('Goto line[,column] :', s, linecol_hist)
               return()
          endif
     else
          s = arg
          AddHistoryStr(s, linecol_hist)
     endif

     if NOT (Pos(',',s) == 1)
          l = SubStr(s, 1, iif( Pos(',', s), Pos(',', s), Length(s) ))
          if l[1] == '+' or l[1] == '-'
               plus_l = l[1]
               l  = SubStr(l, 2, Length(l) -1 )
          endif
          case plus_l
               when '+'  GotoLine(CurrLine() + val(l))
               when '-'  GotoLine(CurrLine() - val(l))
               otherwise GotoLine(val(l))
          endcase
     endif

     if Pos(',',s)
          c = SubStr(s, Pos(',', s) + 1 , Length(s) - Pos(',', s))
          if c[1] == '+' or c[1] == '-'
               plus_c = c[1]
               c  = SubStr(c, 2, length(c) -1 )
          endif
          case plus_c
               when '+'  GotoColumn(CurrCol() + val(c))
               when '-'  GotoColumn(CurrCol() - val(c))
               otherwise GotoColumn(val(c))
          endcase
     endif
end