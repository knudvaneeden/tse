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
/* TSE Macro  : ANSIHelp                                                   */
/* Programmer : David Daniel Anderson                                      */
/*                                                                         */
/* Purpose    : ANSIHelp() uses the DOS "HELP" program to provide basic    */
/*              information on ANSI.                                       */
/*                                                                         */
/* Revision   : 1995/03/01 - first public version (v1.0)                   */
/*                                                                         */
/* Notice     : Public Domain.  Comments to author welcome on ILink,       */
/*              RIME, or Internet (david.daniel.anderson@panasia.com).     */
/*                                                                         */
/* Usage      : Can be bound to a key and burned into TSE, or run as an    */
/*              external macro.                                            */
/*              Additional usage help is available when active.            */
/*                                                                         */
/* Setup notes: If the user is running 4DOS, help on "ANSI" is called.     */
/*   for                                                                   */
/*  Swiss       If the user is NOT running 4DOS, help on "ANSI.SYS" is     */
/*   Army         called.                                                  */
/*    Tool                                                                 */
/*              If the user does not have DOS "HELP" installed (ie. the    */
/*                user has a version of DOS earlier than 5.0), the HELP    */
/*                command will likely yield no assistance.                 */
/***************************************************************************/

proc ANSIHelp()   // Will only work with DOS v5.0 or above, or 4DOS.
  if Pos('4DOS',Upper(GetEnvStr('COMSPEC')))
      DOS('help ANSI',_DONT_PROMPT_)  // 4DOS ANSI chart
  else
      DOS('help ANSI.SYS',_DONT_PROMPT_)  // ANSI chart
  endif
end

proc main()   // If burning into TSE, eliminate this part,
  ANSIHelp()  //  and assign "ANSIHelp()" to your preferred key.
end
