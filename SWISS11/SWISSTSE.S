/*=========================================================================*/
/*                                                                         */
/*  This macro is part of the "SwissArmyTool()" menu package, written      */
/*  and compiled by David Daniel Anderson.  This package collects, into    */
/*  a single TSE menu, many of the standard charts and utilities which     */
/*  programmers find useful.  Most of the features were written in SAL -   */
/*  the macro language for The SemWare Editor ("TSE").                     */
/*                                                                         */
/*  The entire "SwissArmyTool()" menu package should be available on       */
/*  SemWare's BBS (phone 1-404-641-8968), as SWISSnn.ZIP (where "nn" is    */
/*  the current version number).                                           */
/*                                                                         */
/***************************************************************************/
/***************************************************************************/
/* TSE Macro  : menu SwissArmyTool()                                       */
/* Programmer : David Daniel Anderson                                      */
/*                                                                         */
/* Purpose    : Provides instant access to many different and often-used   */
/*              programming charts and utilities.                          */
/*                                                                         */
/* Revision   : 1995/03/01 - first public version (v1.0)                   */
/*                                                                         */
/* Notice     : Public Domain.  Comments to author welcome on ILink,       */
/*              RIME, or Internet (david.daniel.anderson@panasia.com).     */
/*                                                                         */
/* Usage      : Can be bound to a key and burned into TSE, or run as an    */
/*              external macro.  Read SwissTSE.DOC for further help.       */
/***************************************************************************/

MENU SwissArmyTool()
  history
  title = "Programming Tools"

  "&ASCII chart",       ExecMacro('ASCChart'),
                                    DontClose // ASCII chart, in Dec & Hex
  "&Box && line chars", ExecMacro('BoxChars'),
                                    DontClose // Box and line Characters
  "&Color chart",       ExecMacro('DosColor'),
                                    DontClose // Color chart, in Dec & Hex
  "ANS&I help",         ExecMacro('ANSIHelp'),
                                    DontClose // ANSI chart, COMSPEC dependent
  "&Key code chart",    ExecMacro('ShowKey'),
                                    DontClose // Key scan codes, read & report
  "&Number conversion", ExecMacro('NConvert'),
                                    DontClose // Convert Dec<>Hex<>Bin numbs
  "Ca&lculator",        ExecMacro('WazCalc'),
                                    DontClose // Programmer's calculator
  "&Expr. evaluator",   ExecMacro('Expr'),
                                    DontClose // Expression evaluator
  "Calen&dar",          ExecMacro('Cal-DDA'),
                                    DontClose // Pop-Up calendar
     /* WARNING:
         If you cannot or do not wish to use "Cal-DDA", and instead want
           to use the TSE Calendar macro, change "Cal-DDA" to "Cal-SEM",
           and BE SURE to change "DontClose" to "CloseAllBefore" !!! */

end SwissArmyTool

proc main()
  SwissArmyTool()
end
