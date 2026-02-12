/*

   Macro.         Unredo.
   Author.        Carlo Hogeveen <hyphen@xs4all.nl>.
   Version.       2.
   Date.          9 februari 1998.
   Status.        Ready for public testing.

*/
/*

   Purpose.

      A simple Undo/Redo function for TSE.

*/
/*

   Copyright 1998 by Carlo Hogeveen.

      You are free to use this macro in any way, provided that you don't
      buy or sell it or it's use, and provided that changes not made by
      the author are documented as such.

*/
/*

   Disclaimers.

      This macro might harm anyone and anything in any way.

      To start harming: follow the install instructions.

      This macro is unrelated to Semware's upcoming built-in Undo/Redo.

*/
/*

   What Unredo does.

      Unredo works by storing and restoring states to and from a queue of
      states in memory.

      A state consists of:

         All editable files in TSE's ring of files, with for each file:

            The filechanged status.
            The filename.
            The cursor position.

         What the current file is, and it's cursor position.

         The presently defined block.

      A new state is stored:

         Before a sequence of normal keys; filechanges are irrelevant.

         Before a sequence of not normal keys, the last of which may have
         caused filechanges.

      The oldest state is deleted:

         When the maximum number of states has been reached, before a new
         state is to be stored.

      There is a difference between Undo and Redo.
         Undo goes to the previous state where you were editing.
         Redo goes to the next state in the queue.
      The reason behind this is, that if you continue editing after Undo,
      you will still be able to retrieve the intermediate states that were
      (in time) saved before the Undo but which (on the queue) lie after the
      undone state. In other words: it avoids making states unreachable and
      keeps your options open as long as possible. Look at the PrevStates and
      the times in Unredo's Show function if you want to check this proces.

*/
/*

   What Unredo does not.

      Lots of things!

      For example:

         Unredo does not remember editor modes (and need not, IMHO).

         Unredo does not remember the clipboard contents of a state, instead
         it preserves the clipboard over undo and redo actions (which can
         come in handy!).

         You can not undo or redo actions outside the editor, like saving and
         deleting a file to and from disk; however you can with undo or redo
         (un)quit or reopen the version of a file that is or was loaded in
         memory.

         You can not undo or redo seperate actions that did no file changes,
         e.g. after multiple Finds you can only undo or redo all Finds at
         once.

         You cannot undo or redo the typing of one normal key after typing
         a sequence of normal keys.

         Since marking a block does not cause file changes, you can not undo
         or redo the marking, unmarkin or copying of a block: if however
         filechanges occured when a block was active, then the block IS being
         remembered as part of the state. This might be a point to take up
         if there ever will be a futere release of Unredo.

*/

/*

   What Unredo does wrong!

      The bad news is, that command macros depending on TSE's FileChanged()
      command no longer work correctly.

      The good news is, that in my own experience, SO FAR (!) there ar only
      minor inconveniences:

         A bufferlist won't show which files are changed any more.

            For example Semware's ListOpen macro doesn't show an asterisk
            before files that are changed. If this really bothers you,
            you can adjust the filechanged() command in the ListOpen macro
            as described further on in this file under "Remarks".

         The Compile macro compiles the old source on disk instead of the new
         source in memory.

            This is easily remedied by explicitely saving the source file
            before executing the Compile macro,

               either by doing so manually before each Compile,

               or by adjusting and recompiling your *.ui file by putting
               'SaveFile()' before the command 'ExecMacro("Compile ...)'.

      To answer an obvious (?) question: the TSE commands QuitFile(), Exit()
      and SaveAllAndExit() still work o.k., and so do AutoSave macros.

      So while in theory Unredo is an utterly dangerous macro to use,
      in practise for me it works like magic :-)

*/
/*

   What are "normal" keys?

      In Unredo's context, normal keys are keys, about which it is certain,
      that when they are used in an edit window, their immediate effect
      never exceeds the current file (it is irrelevant, whether or not
      they change the current file).

      The great thing about normal keys is, that Unredo can handle them
      a lot quicker than not normal keys.

      The following keys are defined as normal keys:

         Printable characters with ascii codes 32 to 249.

         The following keys:

            <cursorup>,
            <cursordown>,
            <cursorleft>,
            <cursorright>,
            <ins>,
            <del>,
            <home>,
            <end>,
            <pgup>,
            <pgdn>,
            <tab>,
            <shift tab>,
            <backspace>,
            <enter>.

*/
/*

   Performance - memory.

      Because of it's simple approach, Unredo needs lots of memory.

      If possible, opening up TSE's options "Max XMS to Use" and "Max EMS
      to Use" is the best way to gain performance.

      Through the option "Path for supplemental files" TSE can swap
      memory to and from disc: it is always a good idea to point this
      option to a directory on a fast local drive with lots of free space.

      In the user settings further on in this file, you can set the maximum
      number of states Unredo keeps in memory. You can set this lower and
      higher as one of the ways to decrease and increase Unredo's memory
      usage.

      If Unredo finds itself without enough memory, it releases all the
      memory it previously claimed and then stops, deleting itself from
      memory as well, so the user can continue editing.

*/
/*

   Performance - speed.

      Unredo is not fast, but it is usable for an average editing session.

      Everyone will have to weigh for itself, whether the increase in
      keyboard response time is made up for by the capability (and the fun!)
      to undo and redo while editing.

      Unredo definitely gets too slow, when editing extremely large files
      or when editing lots of files at once.

*/
/*

   Performance - not.

      If performance drops for one of the above reasons, this can be easily
      remedied by not using Unredo for (the rest of) a particular editing
      session.

      To delete Unredo from memory for the rest of an editing session,
      use the appropriate key at the bottom of this file, or do it via the
      menu using <escape> <m>acro <e>xecute "unredo delete".

      This way not only the tiny amount of program memory Unredo uses is
      freed up, but also the vast and numerous amounts of Unredo's workspace
      are released back to the system.

      You can also decide not to load Unredo when starting TSE,
      by including the commandline parameter "/nodo".

      Unredo can be restarted from the editor by Executing the Macro "Unredo".

*/
/*

   Planned improvements.

      None for now.

      The fact that Unredo can be made even prettier is for now outweighed
      by knowledge of Semware's planned upcoming buit-in Undo/Redo.

      I also think it's time to release what I've got so far and to get
      some feedback: is Unredo a real tool or is it just a toy?

*/
/*

   Known errors.

      There might be a rare situation where Redo won't redo.
      I think I have seen it happen, but I can't reproduce it yet.

      If this happens, just use Unredo's Show function instead of Redo.

*/
/*

   Huh?

      Please feel free to e-mail any comments you might have.

*/
/*

   Install instructions.

      1. Copy this file to your TSE's MAC directory.

      2. Read the documentation.

      3. Decide on user settings: see directly below.

      4. Decide on key assignments: see the end of this file.

      5. Save and Compile this macro file.

      6. Either add "unredo" to TSE's Macro AutoLoad List and then:

            To use Unredo, simply start TSE.

            To not use unredo, start TSE with the commandline option "/nodo".

         Or without Unredo in TSE's Macro AutoLoad List, start Unredo:

            From the commandline with the option -eunredo.

            From inside TSE with <escape> <M>acro <E>xecute "unredo".

*/



////////////////////////////////////////////////////////////////////////////////



/*

   User settings.
   ==============

*/



/*
   The maximum number of undo/redo states must be at least 2.
   Keep this number low if you dont have much memory or if you regularly
   edit extremely large or numerous files; otherwise you can make this
   number higher to be able to do more Undos and Redos.
*/
#define maxstates 9



/*
   Select how many messages you want to see:
      0  =  Errors, Warnings.
      1  =  Errors, Warnings, Undo, Redo.
      2  =  Errors, Warnings, Undo, Redo, State-tracking while editing.
*/
#define messages 1




////////////////////////////////////////////////////////////////////////////////
/*

   Unredo internally    (Intended for macro programmers)
   =================

*/
/*

   Data structure
   --------------

      unredo:  global var           lowstate
                                    highstate
                                    currstate
                                    newstate
                                    <array of state>

      state:   key                  "unredo_state" + statenr, where
                                    lowest_state <= statenr <= highest_state,
                                    and statenr can be 1 to 9 digits.

               session global var   unredo_state9_prevstate
                                    unredo_state9_lowid
                                    unredo_state9_highid
                                    unredo_state9_begcurrid
                                    unredo_state9_begcurrline
                                    unredo_state9_begcurrcol
                                    unredo_state9_endcurrid
                                    unredo_state9_endcurrline
                                    unredo_state9_endcurrcol
                                    unredo_state9_blockid
                                    unredo_state9_blocktype
                                    unredo_state9_blockmarking
                                    unredo_state9_blockbeginline
                                    unredo_state9_blockbegincol
                                    unredo_state9_blockendline
                                    unredo_state9_blockendcol
                                    unredo_state9_<array of file>

      file:    key                  "unredo_state" + statenr + "_file" + fileid
                                    where fileid can be 1 to 9 digits.

               session global var   unredo_state9_file9_name
                                    unredo_state9_file9_backupid
                                    unredo_state9_file9_currline
                                    unredo_state9_file9_currcol
                                    unredo_state9_file9_changed
                                    unredo_state9_file9_altered

      couter:  key                  "unredo_backupid_" + backupid
                                    where backupid can be 1 to 9 digits.

               session global var   unredo_backupid9

*/
/*

   Remarks
   -------

*/
/*
   Other macro's.

      Can query the "real" FileChanged() status with:

         real_filechanged =
                        filechanged()
                     or getglobalint("unredo_state"
                                     + str(getglobalint("unredo_currstate"))
                                     + "_file"
                                     + str(getbufferid())
                                     + "_changed")

      Or set the "real" FileChanged() status with:

         filechanged(   filechanged()
                     or getglobalint("unredo_state"
                                     + str(getglobalint("unredo_currstate"))
                                     + "_file"
                                     + str(getbufferid())
                                     + "_changed"))

      These code changes still work when Unredo is not loaded.
*/
/*
   Shared backupfiles in memory.

      Normally each editable file of a state is backupped to a new hidden
      file with it's own backupid.

      However, different states are likely to share files that are not
      changed between one state and the other.

      It would be inefficient to repeatingly create new backup files for
      each state.

      Therefore states share these hidden backupfiles for those files that
      are not changed between states.

      How many times a hidden backupfile is shared between states,
      is administered in the session global counter variable
      "unredo_backupid9", where "9" is the id of the backupfile.
*/
/*
   The "altered" status.

      Unredo_state9_file9_altered keeps track off whether a file has been
      altered since the last save_state().

      This is necessary, because it is perfectly allright for a file to have
      a filechanged() status that is ON at the time a state is saved.

      Using the "altered" status, it can (when saving a state) be decided,
      whether a new backupfile is necessary or if a shared backupfile is
      sufficient.
*/
/*
   The internal use of the FileChanged() status.

      Unredo needs to know whether a command changes a file or not.

      This is done for every file by saving the FileChanged() status and
      setting it to OFF before each command, and by checking and (if
      necessary) restoring the FileChanged() status after each command.

      This means that normally TSE commands "see" all files as unchanged,
      even when they differ from their disk versions.

      Exceptions to this rule are the TSE commands QuitFile, Exit
      and SaveAllAndExit (which Unredo can rescue by using a hook)
      and Autosave macro's (which are not commands because they are
      probably hooked to the _idle_ hook).

      Dreaming: if only FileChanged() returned a counter instead of 0/1,
      or the date/time the file was last changed in memory ... (zzzzz :-)

      If anyone can suggest another fast way to check if or when a file was
      changed in memory, I would ofcourse be VERY eager to hear it!
*/
/*
   Two states per state.

      For each state two sets of cursor positions are kept instead of one:

         The state_begin_cursor_positions containing the cursor positions for
         each file directly after the saving of the state,

         The state_end_cursor_positions, containing for each file the last
         cursor position at which the file was not altered since the save of
         the state.

      This means, that for each state possibly two Undo's or Redo's can
      be done, which makes the apparent changes while undoing and redoing
      much clearer, since then they can be shown at the cursor position.
*/



////////////////////////////////////////////////////////////////////////////////
/*

   The program.
   ============

*/


// Global variables:
integer lowstate  = 1
integer highstate = 0
integer currstate = 0
integer numstates = 0

integer normal_key = false
integer state_saved = false
integer state_previously_saved = false
integer save_state_before_next_normal_key = true
integer skip_after = true
integer old_hookstate = on

integer state_begcurrid       = 0
integer state_endcurrid       = 0
integer state_begcurrline     = 0
string  state_begcurrtime [8] = ""
integer state_endcurrline     = 0
integer state_begcurrcol      = 0
integer state_endcurrcol      = 0
string  state_endcurrtime [8] = ""

integer liststateid = 0


forward proc unhook_and_purge()


proc abort(string abort_text)
   alarm()
   warn("Abort: ", abort_text)
end


integer proc mcopyblock()
   integer old_uap = set(unmarkafterpaste, off)
   integer old_msglevel = set(msglevel, _warnings_only_)
   integer result = copyblock()
   set(msglevel, old_msglevel)
   if not result
      if iscursorinblock()
         // Partial paste: memory problem, result remains false.
      else
         // Nothing to copy: TSE says false, I says true.
         result = true
      endif
   endif
   set(unmarkafterpaste, old_uap)
   return(result)
end


proc save_currents()
   pushblock()
   pushposition()
end


proc restore_currents()
   popposition()
   popblock()
end


proc del_lowest_state()
   string statestr [21] = "unredo_state" + str(lowstate)
   string fileidstr [21] = ""
   integer lowid  = getglobalint(statestr + "_lowid")
   integer highid = getglobalint(statestr + "_highid")
   integer fileid = 0
   integer backupid = 0
   integer numbackupids = 0
   integer orgid = getbufferid()

   if messages == 2
      message("Deleting state ", lowstate)
   endif

   for fileid = lowid to highid
      fileidstr = statestr + "_file" + str(fileid)
      backupid = getglobalint(fileidstr + "_backupid")
      if backupid
         numbackupids = getglobalint("unredo_backupid" + str(backupid))
         if numbackupids > 1
            setglobalint("unredo_backupid" + str(backupid), numbackupids - 1)
         else
            delglobalvar("unredo_backupid" + str(backupid))
            abandonfile(backupid)
         endif
         delglobalvar(fileidstr + "_backupid")
         delglobalvar(fileidstr + "_currcol")
         delglobalvar(fileidstr + "_currline")
         delglobalvar(fileidstr + "_changed")
         delglobalvar(fileidstr + "_name")
         delglobalvar(fileidstr + "_altered")
         delglobalvar(fileidstr + "_fixated")
      endif
   endfor

   delglobalvar(statestr + "_prevstate")
   delglobalvar(statestr + "_begcurrid")
   delglobalvar(statestr + "_begcurrline")
   delglobalvar(statestr + "_begcurrcol")
   delglobalvar(statestr + "_begcurrtime")
   delglobalvar(statestr + "_endcurrid")
   delglobalvar(statestr + "_endcurrline")
   delglobalvar(statestr + "_endcurrcol")
   delglobalvar(statestr + "_endcurrtime")
   delglobalvar(statestr + "_blockid")
   delglobalvar(statestr + "_blocktype")
   delglobalvar(statestr + "_blockmarking")
   delglobalvar(statestr + "_blockbegline")
   delglobalvar(statestr + "_blockbegcol")
   delglobalvar(statestr + "_blockendline")
   delglobalvar(statestr + "_blockendcol")
   delglobalvar(statestr + "_lowid")
   delglobalvar(statestr + "_highid")

   lowstate = lowstate + 1
   numstates = numstates - 1
   gotobufferid(orgid)
end


proc delete_unredo()
   while lowstate <= highstate
      del_lowest_state()
   endwhile
   unhook_and_purge()
   message("Unredo is deleted from memory")
end


proc save_filechanged()
   setglobalint(  "unredo_state"
                  + str(currstate)
                  + "_file"
                  + str(getbufferid())
                  + "_changed",
                filechanged(false))
end


integer proc check_filechanged()
   string statestr [21] = "unredo_state" + str(currstate)
   string filestr  [35] = statestr + "_file" + str(getbufferid())
   integer result = false
   integer old_tf = 0
   if filechanged()
      result = true
      setglobalint(filestr + "_altered", true)
   else
      filechanged(getglobalint(filestr + "_changed"))
      if  not getglobalint(filestr + "_altered")
      and not getglobalint(filestr + "_fixated")
         old_tf = set(timeformat, 1)
         setglobalint(statestr + "_endcurrid",   getbufferid())
         setglobalint(statestr + "_endcurrline", currline())
         setglobalint(statestr + "_endcurrcol",  currcol())
         setglobalstr(statestr + "_endcurrtime", gettimestr())
         set(timeformat, old_tf)
      endif
   endif
   return(result)
end


integer proc save_state()
   integer result = true   // Result says, whether the save_state succeeded.
   string newstatestr [21] = "unredo_state" + str(highstate + 1)
   integer lowid = 999999999
   integer highid = 0
   integer startid = 0
   integer backupid = 0
   integer orgid = getbufferid()
   integer currstateline = currline()
   integer currstatecol = currcol()
   integer fileid = 0
   string fileidstr [35] = ""
   integer old_tf = 0

   if buffertype() == _normal_
   or nextfile()
      startid = getbufferid()

      if numstates >= maxstates
         del_lowest_state()
      endif

      if messages == 2
         message("Saving state ", highstate + 1)
      endif

      old_tf = set(timeformat, 1)

      setglobalint(newstatestr + "_prevstate",    currstate)
      setglobalint(newstatestr + "_begcurrid",    orgid)
      setglobalint(newstatestr + "_begcurrline",  currstateline)
      setglobalint(newstatestr + "_begcurrcol",   currstatecol)
      setglobalstr(newstatestr + "_begcurrtime",  gettimestr())
      setglobalint(newstatestr + "_endcurrid",    orgid)
      setglobalint(newstatestr + "_endcurrline",  currstateline)
      setglobalint(newstatestr + "_endcurrcol",   currstatecol)
      setglobalstr(newstatestr + "_endcurrtime",  gettimestr())
      setglobalint(newstatestr + "_blockid",      query(blockid))
      setglobalint(newstatestr + "_blocktype",    isblockmarked())
      setglobalint(newstatestr + "_blockmarking", query(marking))
      setglobalint(newstatestr + "_blockbegline", query(blockbegline))
      setglobalint(newstatestr + "_blockbegcol",  query(blockbegcol))
      setglobalint(newstatestr + "_blockendline", query(blockendline))
      setglobalint(newstatestr + "_blockendcol",  query(blockendcol))

      save_currents()

      repeat
         fileid = getbufferid()
         // Handle old state.
         setglobalint("unredo_state"
                      + str(currstate)
                      + "_file"
                      + str(fileid)
                      + "_fixated",
                      true)
         // Handle new state.
         if lowid > fileid
            lowid = fileid
         endif
         if highid < fileid
            highid = fileid
         endif
         fileidstr = newstatestr + "_file" + str(fileid)
         setglobalstr(fileidstr + "_name",     currfilename())
         setglobalint(fileidstr + "_changed",  filechanged(false))
         setglobalint(fileidstr + "_currline", currline())
         setglobalint(fileidstr + "_currcol" , currcol())
         delglobalvar(fileidstr + "_altered")
         if     getglobalint("unredo_state"
                             + str(currstate)
                             + "_file"
                             + str(fileid)
                             + "_altered")
         or not getglobalint("unredo_state"
                             + str(currstate)
                             + "_file"
                             + str(fileid)
                             + "_backupid")
            markline(1, numlines())
            if createtempbuffer()
               backupid = getbufferid()
               if mcopyblock()
                  setglobalint(newstatestr
                               + "_file"
                               + str(fileid)
                               + "_backupid",
                               backupid)
               else
                  abandonfile()
                  backupid = 999999999
                  result = false
               endif
            else
               backupid = 999999999
               result = false
            endif
         else
            backupid = getglobalint("unredo_state"
                                    + str(currstate)
                                    + "_file"
                                    + str(fileid)
                                    + "_backupid")
            setglobalint(newstatestr
                         + "_file"
                         + str(fileid)
                         + "_backupid",
                         backupid)
         endif
         setglobalint("unredo_backupid" + str(backupid),
                      getglobalint("unredo_backupid" + str(backupid)) + 1)
         gotobufferid(fileid)
         nextfile()
      until getbufferid() == startid

      setglobalint(newstatestr + "_lowid",  lowid)
      setglobalint(newstatestr + "_highid", highid)

      set(timeformat, old_tf)

      restore_currents()

      numstates = numstates + 1
      highstate = highstate + 1
      currstate = highstate

      gotobufferid(orgid)
      if messages == 2
         updatedisplay(_statusline_refresh_)
      endif
   endif

   return(result)
end


proc save_state_filechanged_only()
   integer orgid = getbufferid()
   integer startid = 0
   if buffertype() == _normal_
   or nextfile()
      startid = getbufferid()
      repeat
         setglobalint("unredo_state"
                      + str(currstate)
                      + "_file"
                      + str(getbufferid())
                      + "_changed",
                      filechanged(false))
         nextfile()
      until getbufferid() == startid
   endif
   gotobufferid(orgid)
end


integer proc state_changed()
   integer result = false  // Result says, whether the state is changed.
   integer orgid = getbufferid()
   integer startid = 0
   string statestr [21] = "unredo_state" + str(currstate)
   integer fileid = 0
   string fileidstr [35] = ""
   integer lowid = getglobalint(statestr + "_lowid")
   integer highid = getglobalint(statestr + "_highid")
   for fileid = lowid to highid
      fileidstr = statestr + "_file" + str(fileid)
      if getglobalint(fileidstr + "_backupid")
         setglobalint(fileidstr + "_check", on)
      endif
   endfor
   if buffertype() == _normal_
   or nextfile()
      startid = getbufferid()
      repeat
         fileidstr = statestr + "_file" + str(getbufferid())
         if getglobalint(fileidstr + "_check")
            delglobalvar(fileidstr + "_check")
            if check_filechanged()
               result = true
            endif
         else
            result = true
         endif
         nextfile()
      until getbufferid() == startid
   endif
   for fileid = lowid to highid
      fileidstr = statestr + "_file" + str(fileid)
      if getglobalint(fileidstr + "_check")
         delglobalvar(fileidstr + "_check")
         result = true
      endif
   endfor
   gotobufferid(orgid)
   return(result)
end


proc set_normal_key()
   if query(key) in  <cursorup>,
                     <cursordown>,
                     <cursorleft>,
                     <cursorright>,
                     <ins>,
                     <del>,
                     <home>,
                     <end>,
                     <pgup>,
                     <pgdn>,
                     <tab>,
                     <shift tab>,
                     <backspace>,
                     <enter>
      normal_key = true
   else
      if (query(key) & 0xff) in 32 .. 249
         normal_key = true
      else
         normal_key = false
      endif
   endif
end


integer proc claim()
   integer result = true
   old_hookstate = sethookstate(off)
   return(result)
end


integer proc disclaim()
   integer result = true
   setglobalint("unredo_currstate", currstate)
   sethookstate(old_hookstate)
   return(result)
end


proc before_command()
   skip_after = false
   claim()
   set_normal_key()
   if      normal_key
   and not save_state_before_next_normal_key
      save_filechanged()
      state_saved = false
   else
      if state_previously_saved
         save_state_filechanged_only()
      else
         if save_state()
            state_previously_saved = true
         else
            delete_unredo()
         endif
      endif
      state_saved = true
   endif
   disclaim()
end


proc after_command()
   if skip_after
      skip_after = false
   else
      claim()
      if state_saved
         if state_changed()
            if normal_key
               save_state_before_next_normal_key = false
            else
               save_state_before_next_normal_key = true
            endif
            state_previously_saved = false
         else
            if normal_key
               save_state_before_next_normal_key = false
            endif
         endif
      else
         // A following normal key has been pressed
         if check_filechanged()
            state_previously_saved = false
         endif
         save_state_before_next_normal_key = false
      endif
      disclaim()
   endif
end


proc on_file_quit()
   if not filechanged()
      filechanged(getglobalint("unredo_state"
                               + str(currstate)
                               + "_file"
                               + str(getbufferid())
                               + "_changed"))
   endif
end


proc on_exit_called()
   integer orgid = getbufferid()
   integer startid = 0
   if buffertype() == _normal_
   or nextfile()
      startid = getbufferid()
      repeat
         on_file_quit()
      until getbufferid() == startid
   endif
   gotobufferid(orgid)
end


proc on_file_save()
   delglobalvar("unredo_state"
                + str(currstate)
                + "_file"
                + str(getbufferid())
                + "_changed")
end


string proc get_state_position(integer state)
   string statestr [21] = "unredo_state" + str(state)
   state_begcurrid   = getglobalint(statestr + "_begcurrid")
   state_endcurrid   = getglobalint(statestr + "_endcurrid")
   state_begcurrline = getglobalint(statestr + "_begcurrline")
   state_endcurrline = getglobalint(statestr + "_endcurrline")
   state_begcurrcol  = getglobalint(statestr + "_begcurrcol")
   state_endcurrcol  = getglobalint(statestr + "_endcurrcol")
   state_begcurrtime = getglobalstr(statestr + "_begcurrtime")
   state_endcurrtime = getglobalstr(statestr + "_endcurrtime")
   return(statestr)
end


proc repointer(integer parent, integer child)
   integer state  = 0
   integer lowid  = 0
   integer highid = 0
   integer fileid = 0
   string statestr  [21] = ""
   string childstr  [35] = ""
   string parentstr [35] = ""
   for state = lowstate to highstate
      statestr = "unredo_state" + str(state)
      lowid    = getglobalint(statestr + "_lowid")
      highid   = getglobalint(statestr + "_highid")
      for fileid = lowid to highid
         childstr = statestr + "_file" + str(child)
         parentstr = statestr + "_file" + str(parent)
         setglobalstr(childstr + "_name"    ,getglobalstr(parentstr + "_name"    ))
         setglobalint(childstr + "_backupid",getglobalint(parentstr + "_backupid"))
         setglobalint(childstr + "_changed" ,getglobalint(parentstr + "_changed" ))
         setglobalint(childstr + "_currline",getglobalint(parentstr + "_currline"))
         setglobalint(childstr + "_currcol" ,getglobalint(parentstr + "_currcol" ))
         setglobalint(childstr + "_altered" ,getglobalint(parentstr + "_altered" ))
         delglobalvar(parentstr + "_name"    )
         delglobalvar(parentstr + "_backupid")
         delglobalvar(parentstr + "_changed" )
         delglobalvar(parentstr + "_currline")
         delglobalvar(parentstr + "_currcol" )
         delglobalvar(parentstr + "_altered" )
      endfor
      if getglobalint(statestr + "_begcurrid") == parent
         setglobalint(statestr + "_begcurrid", child)
      endif
      if getglobalint(statestr + "_endcurrid") == parent
         setglobalint(statestr + "_endcurrid", child)
      endif
      if getglobalint(statestr + "_blockid") == parent
         setglobalint(statestr + "_blockid", child)
      endif
      if getglobalint(statestr + "_highid") < child
         setglobalint(statestr + "_highid", child)
      endif
   endfor
end


proc unredo(integer  old_state,                                             //)
            integer  state,
            string   statestr,
            string   action,
            integer  goto_begin_of_state)
   integer lowid = getglobalint(statestr + "_lowid")
   integer highid = getglobalint(statestr + "_highid")
   integer fileid = 0
   string fileidstr [35] = ""
   integer startid = 0
   integer backupid = 0
   integer newid = 0
   integer repointering = false
   claim()
   if messages > 0
      message(action + "ing state ", old_state, " to state ", state)
   endif
   currstate = state
   repeat
      if buffertype() == _normal_
         if currfilename() == getglobalstr(statestr
                                           + "_file"
                                           + str(getbufferid())
                                           + "_name")
            if startid == 0
               startid = getbufferid()
            endif
         else
            abandonfile()
         endif
      endif
   until not nextfile()
      or startid == getbufferid()
   if  buffertype() == _normal_
   and currfilename() <> getglobalstr(statestr
                                      + "_file"
                                      + str(getbufferid())
                                      + "_name")
      abandonfile()
   endif
   for fileid = lowid to highid
      fileidstr = statestr + "_file" + str(fileid)
      backupid = getglobalint(fileidstr + "_backupid")
      if backupid
         if gotobufferid(fileid)
         or fileid == getbufferid()
            newid = fileid
            emptybuffer()
            repointering = false
         else
            newid = createbuffer(getglobalstr(fileidstr + "_name"))
            setglobalint(statestr + "_highid", newid)
            if fileid == state_begcurrid
               state_begcurrid = newid
            endif
            if fileid == state_endcurrid
               state_endcurrid = newid
            endif
            repointering = true
         endif
         gotobufferid(backupid)
         markline(1, numlines())
         gotobufferid(newid)
         if mcopyblock()
            filechanged(getglobalint(fileidstr + "_changed"))
            gotoline(getglobalint(fileidstr + "_currline"))
            gotocolumn(getglobalint(fileidstr + "_currcol"))
            delglobalvar(fileidstr + "_altered")
            if repointering
               repointer(fileid, newid)
            endif
         else
            delete_unredo()
            fileid = highid
         endif
      endif
   endfor
   unmarkblock()
   if getglobalint(statestr + "_blockid")
      gotobufferid(getglobalint(statestr + "_blockid"))
      gotoline(getglobalint(statestr + "_blockbegline"))
      gotocolumn(getglobalint(statestr + "_blockbegcol"))
      mark(getglobalint(statestr + "_blocktype"))
      gotoline(getglobalint(statestr + "_blockendline"))
      gotocolumn(getglobalint(statestr + "_blockendcol"))
      if not getglobalint(statestr + "_blockmarking")
         mark(getglobalint(statestr + "_blocktype"))
      endif
   endif
   if goto_begin_of_state
      gotobufferid(state_begcurrid)
      begline()
      gotoline(state_begcurrline)
      gotocolumn(state_begcurrcol)
   else
      gotobufferid(state_endcurrid)
      begline()
      gotoline(state_endcurrline)
      gotocolumn(state_endcurrcol)
   endif
   disclaim()
end


proc reset_unredo()
   state_saved = false
   state_previously_saved = true
   save_state_before_next_normal_key = false
   skip_after = true
   scrolltocenter()
end


proc undo()
   integer prevstate = getglobalint("unredo_state"
                                    + str(currstate)
                                    + "_prevstate")
   string statestr [21] = ""
   if currstate == 0
      message("No Undos available yet (state ", currstate, ")")
   else
      statestr = get_state_position(currstate)
      if not existglobalvar("unredo_state" + str(prevstate) + "_prevstate")
         unredo(currstate, currstate, statestr, "Undo", true)
         message("No further Undos available (state ",
                  currstate, " begin)")
      else
         if state_begcurrid   <> getbufferid()
         or state_begcurrline <> currline()
         or state_begcurrcol  <> currcol()
            unredo(currstate, currstate, statestr, "Undo", true)
            if messages > 0
               if  state_begcurrid   == state_endcurrid
               and state_begcurrline == state_endcurrline
               and state_begcurrcol  == state_endcurrcol
                  message("Undone (state ", currstate, ")")
               else
                  message("Undone (state ", currstate, " begin)")
               endif
            endif
         else
            statestr = get_state_position(prevstate)
            unredo(currstate, prevstate, statestr, "Undo", false)
            if messages > 0
               if  state_begcurrid   == state_endcurrid
               and state_begcurrline == state_endcurrline
               and state_begcurrcol  == state_endcurrcol
                  message("Undone (state ", currstate, ")")
               else
                  message("Undone (state ", currstate, " end)")
               endif
            endif
         endif
      endif
      reset_unredo()
   endif
end


proc redo()
   integer nextstate = currstate + 1
   string statestr [21] = ""
   if currstate == 0
      message("No Redos available yet (state = ", currstate, ")")
   else
      statestr = get_state_position(currstate)
      if not existglobalvar("unredo_state" + str(nextstate) + "_prevstate")
         unredo(currstate, currstate, statestr, "Redo", false)
         message("No further Redos available (state ",
                  currstate, " end)")
      else
         if state_endcurrid   <> getbufferid()
         or state_endcurrline <> currline()
         or state_endcurrcol  <> currcol()
            unredo(currstate, currstate, statestr, "Redo", false)
            if messages > 0
               if  state_begcurrid   == state_endcurrid
               and state_begcurrline == state_endcurrline
               and state_begcurrcol  == state_endcurrcol
                  message("Redone (state ", currstate, ")")
               else
                  message("Redone (state ", currstate, " end)")
               endif
            endif
         else
            statestr = get_state_position(nextstate)
            unredo(currstate, nextstate, statestr, "Redo", true)
            if messages > 0
               if  state_begcurrid   == state_endcurrid
               and state_begcurrline == state_endcurrline
               and state_begcurrcol  == state_endcurrcol
                  message("Redone (state ", currstate, ")")
               else
                  message("Redone (state ", currstate, " begin)")
               endif
            endif
         endif
      endif
      reset_unredo()
   endif
end


proc show_state(integer state,                                          // )
                string  substate,
                string  statestr,
                integer state_currid,
                integer state_currline,
                integer state_currcol,
                string  state_currtime)
   string state_currfilename [80] = getglobalstr(statestr
                                                 + "_file"
                                                 + str(state_currid)
                                                 + "_name")
   if length(state_currfilename) > 32
      state_currfilename = substr(state_currfilename,
                                  length(state_currfilename) - 31,
                                  32)
      state_currfilename [1] = chr(17)
   endif
   addline(format(str(state) + " " + substate:-16,
                  getglobalint(statestr + "_prevstate"):-9,
                  state_currtime:8,
                  state_currline:6,
                  state_currcol:4,
                  " ",
                  state_currfilename:-32))
end


proc show_states()
   integer state = 0
   integer currstateline = 0
   integer goto_begin = false
   integer list_result = false
   integer old_currid = getbufferid()
   integer old_currline = currline()
   integer old_currcol = currcol()
   string statestr [21] = ""
   string substate [5] = ""
   if currstate == 0
      message("No Undos or Redos available yet")
   else
      pushposition()
      gotobufferid(liststateid)
      emptybuffer()
      for state = lowstate to highstate
         statestr = get_state_position(state)
         if existglobalvar(statestr + "_prevstate")
            if  state_begcurrid   == state_endcurrid
            and state_begcurrline == state_endcurrline
            and state_begcurrcol  == state_endcurrcol
               show_state(state, "", statestr, state_endcurrid,
                          state_endcurrline, state_endcurrcol,
                          state_endcurrtime)
            else
               show_state(state, "begin", statestr, state_begcurrid,
                          state_begcurrline, state_begcurrcol,
                          state_begcurrtime)
               show_state(state, "end", statestr, state_endcurrid,
                          state_endcurrline, state_endcurrcol,
                          state_endcurrtime)
            endif
            if state == currstate
               currstateline = currline()
            endif
         endif
      endfor
      gotoline(currstateline)
      list_result = list(
"State           PrevState    Time  Line Col CurrentFile                       "
                     , 78)
      if list_result == 0
      or (   getbufferid(gettoken(gettext(45, 32), " ", 1)) == old_currid
         and val(gettext(34, 6))                            == old_currline
         and val(gettext(40, 4))                            == old_currcol  )
         popposition()
         message("No new state selected")
      else
         killposition()
         state = val(gettoken(gettext(1, 16), " ", 1))
         statestr = get_state_position(state)
         substate = gettoken(gettext(1, 16), " ", 2)
         if substate == "begin"
            goto_begin = true
         else
            goto_begin = false
         endif
         unredo(currstate, state, "unredo_state" + str(state), "Select", goto_begin)
         reset_unredo()
         message("State ", state, " ", substate, " selected")
      endif
   endif
end


proc unhook_and_purge()
   unhook(before_command)
   unhook(after_command)
   unhook(on_file_quit)
   unhook(on_exit_called)
   unhook(on_file_save)
   purgemacro("unredo")
end


proc whenloaded()
   integer currid = getbufferid()
   if pos("/nodo", lower(query(doscmdline)))
      purgemacro("unredo")
   else
      if  hook(_before_command_, before_command)
      and hook(_after_command_,  after_command)
      and hook(_on_file_quit_,   on_file_quit)
      and hook(_on_exit_called_, on_exit_called)
      and hook(_on_file_save_,   on_file_save)
         liststateid = createtempbuffer()
         gotobufferid(currid)
         // We're in the air.
      else
         abort("Failed to hook UNREDO")
         unhook_and_purge()
      endif
   endif
end


proc main()
   string param [7] = lower(gettoken(query(macrocmdline), " ", 1))
   case param
      when "undo"    undo()
      when "redo"    redo()
      when "show"    show_states()
      when "delete"  delete_unredo()
   endcase
end



/*
   You can change these key assignments or execute them from another file.

   Unredo can always be (re)started with <escape> <m>acro <e>xecute "unredo".
*/
<ctrlshift u>  execmacro("unredo undo")      // Undo.
<ctrlshift r>  execmacro("unredo redo")      // Redo.
<ctrlshift s>  execmacro("unredo show")      // Show states.
<ctrlshift d>  execmacro("unredo delete")    // Delete Unredo from memory.

