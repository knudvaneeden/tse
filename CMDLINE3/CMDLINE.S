/*****************************************************************************
                          CmdLine, Version 3
                                9-13-93
                              David Marcus

Helper macros to facilitate user-created command line options. Includes
complete instructions for creating your own TSE command line options or
reinterpreting standard options.

I am seeking comment on both the functionality and the explanation.

þ Copyright (c) 1993 David Marcus

  Permission is granted to all persons for non-commercial distribution
  of this file and the macros and ideas contained herein provided (a)
  credit is given to the author and (b) all changes not made by the
  author are attributed.

  Permission is granted to SemWare for commercial distribution provided
  (a) and (b) above.

þ Contacting The Author

  You can contact David Marcus
     ù on the SemWare BBS
     ù via CompuServe EMail (76300,3204)
*/


/**************************************************************************
 CmdLineOptionUsed()
 **************************************************************************/
integer                       proc CmdLineOptionUsed(STRING option)
     string temp[128] = Set(DOSCmdLine, '') + ' ',
            arg[64] = '',
            opt[64] = '-' + option

     if NOT Pos(opt, temp)              // opt not found
          Set(DOSCmdLine, temp)
          return(FALSE)
     else                               // option found
          if temp[Pos(opt,temp) + Length(opt)] == ' '
                                        // no argument used
               Set(DOSCmdLine,          // reset cmd line
                    SubStr(temp, 1, Pos(opt, temp) - 1) +
                    SubStr(temp,    Pos(opt, temp) + Length(opt), 128)
                   )
          else                          // argument used
               Set(DOSCmdLine,          // everything preceding option
                   SubStr(temp, 1, Pos(opt, temp) - 1)
                  )
               temp  = SubStr(temp, Pos(opt, temp) + Length(opt), 128)
                                        // everything following option
               arg = SubStr(temp, 1, Pos(' ', temp) - 1)
                                        // everything following option
                                        // up to a space
               Set(DOSCmdLine, Query(DOSCmdLine) +
                               SubStr(temp, Pos(' ', temp) + 1, 128)
                  )                     // everything following space
          endif
          SetGlobalStr('CmdLineArgFor' + option, Arg)
          return(TRUE)
     endif
     return(42)
end

proc mLTrim(var string foo)
     while length(foo) and (foo[1] == ' ')
          foo = SubStr(foo, 2, length(foo)-1)
     endwhile
end

/**************************************************************************
 CmdLineFiles()
 **************************************************************************/
string                        proc CmdLineFiles()
     string temp[128] = Set(DOSCmdLine, '') + ' ',
            files[128] = ''
     set(break,on)
     repeat
          mLTrim(temp)

          if temp[1] == '-'             // add to cmdline
                                        // strip from temp
               Set(DOSCmdLine, Query(DOSCmdLine) +
                               SubStr(temp, 1, Pos(' ', temp))
                  )
               temp = SubStr(temp, Pos(' ', temp) + 1, 128 )

          else                          // add to files
                                        // strip from temp
               files = files + SubStr(temp, 1, Pos(' ', temp))
               temp = SubStr(temp, Pos(' ', temp) + 1, 128 )
          endif
     until length(temp) <= 1
     return(files)
end
