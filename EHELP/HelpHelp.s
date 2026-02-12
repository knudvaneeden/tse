/*
  Macro           HelpHelp
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   TSE v4 upwards, Windows + Linux
  Version         0.4   21 Oct 2022

  This extension manages the coexistence of TSE Help systems.
  Currently three are known, others could be configured.

  Known TSE Help systems, in increasing order of seniority:
    eHelp  : My solution for TSE Help based on readable, editable text files.
    GetHelp: Chris Antos' solution getting for TSE and non-TSE Help,
             the TSE Help based somewhat encoded text files.
             Currently this HelpHelp ignores it, and thereby possibly disables
             parts of it, because things are already hard enough without it.
    Help() : TSE's built-in Help based on compressed, encoded files.


  INSTALLATION

  Put HelpHelp in TSE's "mac" directory and compile it there.

  Do NOT add HelpHelp to TSE's Macro AutoLoad List. That does nothing in this
  case.

  Only/just the presence of HelpHelp.mac in TSE's "mac" directory when Help is
  requested for the first time determines whether it will be used for the rest
  of the TSE session.


  CONFIGURATION

  None possible yet.

*/





/*

  T E C H N I C A L   I N F O


  HelpHelp Context

    Only the first time TSE's Help is accessed, the presense of HelpHelp.mac
    determines whether it will be called for the rest of the TSE session.
    Let us assume it will.

    If a TSE Help request is made with a (sub)topic, then the HelpHelp macro is
    called with that topic in the macro command line, preceded by "-r".
    For example, Help("EditFile") generates the macro call
      ExecMacro("HelpHelp -r EditFile")

    The default topic is "Table of Contents", so Help()
    request to HelpHelp becomes:
      "-r Table of Contents"

    The topic can be preceded by the Help file they occur in,
    separated by a "|".
    TSE's PrevHelp() and SearchHelp() commands use this feature.
    For example, PrevHelp() could generate:
      ExecMacro("HelpHelp -r C:\TSE\Help\tsehelp.hlp|Table of Contents")

    If the Help fails, typically because the requested topic was not found,
    then the Help calls HelpHelp again with the same parameters except
    with "-h" instead of "-r".
    I think the "-h" stands for "Halt", and that it allows us to program our
    own error message instead of the one TSE's Help will generate.
    For example, given that there is no help topic named "Catch roadrunner!",
    Help('Catch roadrunner!') will generate these two calls:
      ExecMacro("HelpHelp -r Catch roadrunner!")
      ExecMacro("HelpHelp -h Catch roadrunner!")

    HelpHelp can signal to the Help whether it succeeded it handling its call
    or not, by setting TSE's built-in variable MacroCmdLine to the string
    "true" or "false".
    If TSE's Help receives "true" back, then it stops, otherwise it does its
    own handling of the request or of the halt.



  GetHelp

    GetHelp uses Help() and InsertTopic() to call HelpHelp again.

      InsertTopic(string topic [, integer flags])
        Calls HelpHelp.
        If HelpHelp is not defined or returns "false", then TSE's help inserts
        the requested topic as a line block into the current buffer, honoring
        the InsertLineBlocksAbove setting.
        While doing this, TSE's help reacts to these non-default flag values:
          Flags & 0x0001 -> Do not remove low-level help codes from the whole
                            buffer.
          Flags & 0x8000 -> Makes Inserttopic return a zero/non-zero error code
                            instead of TRUE/FALSE if its result is ok/not ok.

*/



integer call_stack_size = 0


// (Un)comment this DEBUG line or set it to TRUE/FALSE to enable/disable
// showing debugging-messagges.
#define DEBUG FALSE

#ifndef DEBUG
  #define DEBUG FALSE
#endif

proc msg(string msg)
  integer message_duration_in_seconds = 2
  integer i = 0
  #if DEBUG
    for i = message_duration_in_seconds downto 1
      KeyPressed()
      Message('HelpHelp'; call_stack_size; i, ':'; msg)
      KeyPressed()
      Delay(18)
      KeyPressed()
    endfor
    Message('')
    KeyPressed()
  #endif
end msg



proc Main()
  string cmd_line[MAXSTRINGLEN] = Query(MacroCmdLine)

  call_stack_size = call_stack_size + 1

  if  call_stack_size <= 10
  and (cmd_line[1: 2] in '-r', '-h')
  and not GetGlobalInt("GETHELP_NoHelpHelp")
    msg('Trying eHelp for: ' + cmd_line)
    ExecMacro('eHelp ' + Trim(cmd_line))
    if Val(Query(MacroCmdLine))
      msg('eHelp succeeded!')
      Set(MacroCmdLine, 'true')     // We handled it.
    else
      /*
      cmd_line = Format("GetHelp"; "-1"; Trim(cmd_line[4: MAXSTRINGLEN]))
      msg('eHelp failed. Trying GetHelp for: "' + cmd_line + '"')
      ExecMacro(cmd_line)
      // ExecMacro(Format("debug c:\users\carlo\tse\tse45\mac\GetHelp.si"))
      PurgeMacro('GetHelp')
      if Val(Query(MacroCmdLine))
        msg('GetHelp succeeded!')
        Set(MacroCmdLine, "true")   // We handled it
      else
        msg("GetHelp failed. Trying TSE's Help for: " + cmd_line)
      */
        msg("eHelp failed. Trying TSE's Help for: " + cmd_line )
        Set(MacroCmdLine, 'FALSE')  // We did not handle it
      /*
      endif
      */
    endif
  else
    msg('Illegal parameter in: ' + cmd_line)
  endif

  call_stack_size = call_stack_size - 1
end Main

