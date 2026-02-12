/*
   Macro       Os2cmd
   Author      Carlo Hogeveen (0hogeveen01@almere.flnet.nl)
   Written     September 1996


   Os2cmd will perform an OS/2 command from TSE and
   return to TSE with captured screen output in file os2task?.log.

   Up to 9 OS/2 tasks can thus be spawned simultaniously, either from 9 TSE
   sessions or from 1 TSE session losing the screen output.

   If used to spawn a foreground session with <ctrl 1>,
   os2cmd does not return to TSE by itself.

   If used to spawn a backround session with <ctrl 2>,
   and the spawned OS/2 command ends by itself,
   os2cmd returns to TSE with the screen output from the OS/2 command!

   If used to spawn a backround session with <ctrl 2>,
   and the spawned OS/2 command does not end by itself,
   you have to manually switch to and from the new OS/2 session.

   Os2cmd was tested with TSE PRO 2.5 under OS/2 Warp.


   Os2cmd uses hstart.exe (hstart05.zip) from Henk Kelder,
   which requires at least OS/2 2.1.

   Place hstart.exe in a dos session in a directory in your path.

   In the "hstart screen" you can abort the capturing of screen output
   and return to TSE by pressing any key.
*/

proc os2cmd(string groundletter, string groundword)
   string
      os2command [60] = "",
      cdisk       [1] = "c",
      task       [23]

   integer
      counter,
      copyparam = _default_

   pushblock()
   message("OS/2 command returns screen output in TSE file os2task?.log")

   if  ask(groundword + " OS/2 command?", os2command)
   and os2command <> ""
      if editfile("c:\config.sys")
         repeat
            begline()
            if lower(getword()) == "set"
               markline()
               copy(copyparam)
               if copyparam == _default_
                  copyparam =  _append_
               endif
            endif
         until not down()

         abandonfile()
         counter = 0

         repeat
            counter = counter + 1
            task    = cdisk + ":\os2task" + str(counter)
         until counter == 10
            or not fileexists(task + ".cmd")

         if counter == 10
            alarm()
            message("There are already 9 os2tasks present under "
                    + cdisk
                    + ":, cleaning follows ...")
            delay(99)
            for counter = 9 downto 1
               task = cdisk + ":\os2task" + str(counter)
               erasediskfile(task + ".cmd")
               erasediskfile(task + ".log")
               erasediskfile(task + ".rdy")
               message("Files from ", task, " are removed")
               delay(18)
            endfor
         endif

         if editfile(task + ".cmd")
            emptybuffer()
            paste()                                // Restore OS/2 settings.
            unmarkblock()
            endfile()
/*
            addline(cdisk + ":")                   // Restore working disk
            addline("cd " + cdisk + ":\lan\tss")   // Restore working dir
            addline("call l:\cmd\setwst")          // Other local OS/2 init
*/
            addline("echo Screen output from call   " + os2command
                     + ": > " + task + ".log")
            addline("call " + os2command
                     + " >> " + task + ".log")
            addline("echo. >> " + task + ".rdy")
            savefile()
            abandonfile()
            erasediskfile(task + ".rdy")
            erasediskfile(task + ".log")
            dos( "hstart /fs /c /"
               + groundletter
               + " "
               + task
               + ".cmd",
               _dont_prompt_ )

            repeat
               delay(23)
            until keypressed()
               or fileexists(task + ".rdy")

            if keypressed()
               getkey()
            endif

            editfile(task + ".log", _dont_prompt_)
            erasediskfile(task + ".cmd")
            erasediskfile(task + ".log")
            erasediskfile(task + ".rdy")
         endif
      else
         message("c:\config.sys not found")
         alarm()
         delay(18)
      endif
   else
      message("Then not")
   endif
end


<ctrl 1>    os2cmd("f", "Foreground")
<ctrl 2>    os2cmd("b", "Background")

