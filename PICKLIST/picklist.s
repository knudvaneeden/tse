/****************************************************************************
                PICKLISTer ... A generic picklist macro
                              David Marcus
 ****************************************************************************
                               Version 1
                             **************


Copyright: 1993 David Marcus

2026-09-26 adaptation by OpenAI Codex: configurable introductory message
when run directly without the caller's picklist filename.

        Permission is granted to all persons for non-commercial
        distribution of this file and the macros and ideas contained
        herein provided (a) credit is given to the author and (b) all
        changes not made by the author are attributed.

        Permission is granted to SemWare for commercial distribution
        provided (a) and (b) above.

Author:  David Marcus

Date:    5-5-93

Description:

        PICKLISTer is a helper macro to use within other macros.
        It lets your macro display any file as a picklist and then
        make use of the entry selected by the user.

        The picklist file can have entries added to it, edited, etc.,
        without requiring a recompile of the macro.

Installation:

1. Place PICKLIST.S in the directory where your macro source files reside.

2. Compile PICKLIST using sc:

     sc PICKLIST

3. Add these lines to any macro in which you want to use a file as a
   picklist, changing the length of string tag to be the max length
   you want to allow for the value to be returned from the picklist and
   changing the first two SetGlobalStr() lines to be the file name for
   your picklist and the title to be displayed for your picklist:

     proc sample_picklist_use()
          STRING
               tag[254] = ''          // max length for selected text
          SetGlobalStr('picklist_fn',      'your_picklist_file_name')
          SetGlobalStr('picklist_title',   'your_picklist_title')
          SetGlobalInt('picklist_maxwidth', Length(tag))
          ...
          ExecMacro('picklist')
          if GetGlobalInt('picklist_return')
               tag = GetGlobalStr('picklist_result')
               ....
          else
               Warn('No entry selected!')
          endif
          ....
     end

Usage Notes:

     This proc is designed to be called by another proc.
     It displays as a picklist of the contents of a specified file.

     Here is an example of the proc that calls it:

     proc sample_picklist_use()
          STRING tag[45] = '' // Length of this will be the max length
                              // retrieved from the picklist.

          SetGlobalStr('picklist_fn', 'i:\tags.vp')
                              // Sets file name for picklist file.

          SetGlobalStr('picklist_title', 'Select Item [Esc=Abort]')
                              // Sets title shown on picklist

          SetGlobalInt('picklist_maxwidth', Length(tag))
                              // Set max characters to pick.

          ExecMacro('picklist')
                              // Execute picklist.

          if GetGlobalInt('picklist_return')
                              // Check return value as explicitly
                              // set by picklist().

               tag = GetGlobalStr('picklist_result')
                              // set variable to picked text
               ....
          else
               Warn('No entry selected!')
          endif
          ....
     end
***************************************************************/

INTEGER proc pickList()
     INTEGER
          maxline=10,
          // set this for the minimum picklist width to display.

          cid = GetBufferId()

     /*
          First, verify that file can be loaded.
     */
     if NOT FileExists(GetGlobalStr('picklist_fn'))
          Warn("Can't find picklist file ", GetGlobalStr('picklist_fn'))
          Return(FALSE)
     endif

     /*
          Load file AND determine max line length.
     */
     EditFile(GetGlobalStr('picklist_fn'))
     repeat
          maxline = iif(CurrLineLen() > maxline, CurrLineLen(), maxline)
     until NOT Down()
          OR CurrLineLen() >= 78
          OR maxline >= GetGlobalInt('picklist_maxwidth')
     GotoLine(GetGLobalInt('picklist_line'))

     /*
          Display as picklist.
     */
     set(x1,80 - maxline - 3)
     set(y1,02)
     if List(GetGlobalStr('picklist_title'), maxline + 3)
          if maxline > GetGlobalInt('picklist_maxwidth')
               maxline = GetGlobalInt('picklist_maxwidth')
          endif

          /*
               Enter the picked item (up to maxlength/maxline width)
               as a global STRING.
          */
          SetGlobalStr('picklist_result',GetText(1,maxline))
          SetGlobalInt('picklist_line', CurrLine())
          AbandonFile()
          GotoBufferId(cid)

          /*
               Set return code.
          */
          SetGlobalInt('picklist_return',TRUE)    // so value can be retrieve
          return(TRUE)                            // when execmacro is used
     else
          /*
               if no item picked, set return code.
          */
          AbandonFile()
          GotoBufferId(cid)
          SetGlobalInt('picklist_return',FALSE)
          return(FALSE)
     endif
     return(FALSE)
end

proc main()
     STRING silentS[10] = ''

     // The ini file is searched in the current working directory.
     silentS = GetProfileStr('picklist', 'silent', 'false', 'picklist.ini')
     if GetGlobalStr('picklist_fn') == ''
          if NOT EquiStr(silentS, 'true')
               Warn('PICKLIST 1.0.0.0.0: This is a helper macro. Set the picklist_fn, picklist_title and picklist_maxwidth globals in a calling macro, then ExecMacro("picklist"). See picklist_readme.md. Set silent=true in picklist.ini to hide this message.')
          endif
     else
          pickList()
     endif
end
