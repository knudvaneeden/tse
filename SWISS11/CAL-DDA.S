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
/* TSE Macro  : Cal_DDA (Calendar - David Daniel Anderson)                 */
/* Programmer : David Daniel Anderson                                      */
/*                                                                         */
/* Purpose    : Cal_DDA() provides pop-up access to DDA's free calendar    */
/*              program.  I prefer this calendar to the TSE Calendar macro */
/*              provided by SemWare.                                       */
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
/* Setup notes: If you wish to use the macro provided by SemWare instead,  */
/*   for        see the comments in "Cal-SEM.s".                           */
/* Swiss                                                                   */
/*  Army Tool                                                              */
/***************************************************************************/

proc Cal_DDA()         // Uses DDA's "cal-dda.exe" program
integer BoxAttr=iif(Query(TextAttr)==15,14,15),
        Width=26, Lft = ((Query(ScreenCols) - Width) / 2)+1,
        Depth=13, Top = ((Query(ScreenRows) - Depth) / 2)+1

  PopWinOpen(Lft,Top,Lft+Width-1,Top+Depth-1,1,'Perpetual calendar',BoxAttr)
  Set(Attr,0) ClrScr()
  Dos('cal-dda',_DONT_CLEAR_)
  PopWinClose()
end

proc main()  // If burning into TSE, eliminate this part,
  Cal_DDA()  //  and assign "Cal_DDA()" to your preferred key.
end
