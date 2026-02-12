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
/* TSE Macro  : WazCalc                                                    */
/* Programmer : David Daniel Anderson                                      */
/*                                                                         */
/* Purpose    : WazCalc() calls "WAZCALC.EXE V1.00 11/28/91", by Wayne G.  */
/*              Hall.  WazCalc.exe is a public domain pop-up calculator,   */
/*              with both TSR and non-TSR modes.  For this macro, WazCalc  */
/*              is called in non-TSR mode.                                 */
/*                                                                         */
/* Revision   : 1995/03/01 - first public version (v1.0)                   */
/*                                                                         */
/* Notice     : Public Domain.  Comments to author welcome on ILink,       */
/*              RIME, or Internet (david.daniel.anderson@panasia.com).     */
/*                                                                         */
/* Usage      : Can be bound to a key and burned into TSE, or run as an    */
/*              external macro.                                            */
/*              Additional usage help is shown on-screen when active.      */
/*                                                                         */
/* Setup      : WazCalc() assumes that WazCalc.exe is in a directory in    */
/*              your DOS PATH.                                             */
/*                                                                         */
/*    If this is not the case, then:                                       */
/*                                                                         */
/*    If you have WazCalc.exe in a directory that is NOT in your path,     */
/*      edit the "WazPath" string in WazCalc() to reflect the directory    */
/*      in which WazCalc.exe resides.                                      */
/*                                                                         */
/*   If you don't have WazCalc.exe, or don't want to use it, either        */
/*     edit the "SwissArmyTool()" menu to run a TSE calculator macro       */
/*     of your choice, or a different calculator program.                  */
/*                                                                         */
/*   In any case, if you DON'T use the WazCalc() procedure, comment it     */
/*     out of the "SwissArmyTool()" menu (select "Comments" in the TSE     */
/*     Help Index to learn about commenting).                              */
/*                                                                         */
/***************************************************************************/

proc WazCalc()
string WazPath[32]='wazcalc/c'
integer BoxAttr=iif(Query(TextAttr)==14,15,14)
  PopWinOpen(14,1,66,21,1,'This is a non-TSR pop-up of WazCalc',BoxAttr)
    DOS(WazPath,_DONT_PROMPT_)
  PopWinClose()
end

proc main()  // If burning into TSE, eliminate this part,
  WazCalc()  //  and assign "WazCalc()" to your preferred key.
end
