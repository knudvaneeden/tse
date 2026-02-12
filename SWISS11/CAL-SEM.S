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
/* TSE Macro  : SemWareCalendar (aka Cal-SEM.s)                            */
/* Programmer : David Daniel Anderson                                      */
/*                                                                         */
/* Purpose    : Cal-SEM.s provides direct access to the SemWare provided   */
/*              "Calendar" included with TSE v2.0.  Intended to be used    */
/*              in an external macro, which doesn't have access to TSE.UI. */
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
/* Setup notes: If you wish to use the Calendar macro provided by SemWare  */
/*   for        instead, simply change the Calendar option on the          */
/* Swiss        "SwissArmyTool()" menu to read:                            */
/*  Army                                                                   */
/*   Tool        "Calen&dar",          ExecMacro('Cal-SEM'),               */
/*                                      CloseAllBefore // Pop-Up calendar  */
/***************************************************************************/

proc SemWareCalendar()  // Alternate calendar procedure, uses Calendar.s
  PushKey(<Enter>)
  PushKey(<r>)
  PushKey(<a>)
  PushKey(<d>)
  PushKey(<n>)
  PushKey(<e>)
  PushKey(<l>)
  PushKey(<a>)
  PushKey(<c>)
  ExecMacro("Potpourr")
end

proc main()          // If burning into TSE, eliminate this part, and
  SemWareCalendar()  //  assign "SemWareCalendar()" to your preferred key.
end
