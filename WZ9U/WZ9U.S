/*
 * WZ9U: A (growing) collection of overrides to the default behaviours
 *       of TSE (The SemWare Editor).  Some of these implement features
 *       of TSE Jr. v2.15 not migrated to TSE, the rest are "improvements"
 *       of my own.
 *
 * Note: The KeyAssignments immediately follow the macro definitions,
 *       instead of being collected together at the bottom.  I warned you!
 *
 * Revision History:
 *    <0>   TCM   03-Apr-93   Birthday
 *    <1>   TCM   04-Apr-93   Improve scrolling for HalfPg's
 */

/*
 * mEOL - "Smart" EndOfLine
 *        If already at EndOfLine, move to EndOfNextLine
 */
    Proc mEOL()
      If NOT EndLine()
        Down()
        EndLine()
      EndIf
    End

    <End> mEOL()

/*
 * mHome - "Smart" HomeKey
 *         If already at BegOfLine, move to BegOfNextLine
 */
    Proc mHome()
      If NOT BegLine()
        Up()
        BegLine()
      EndIf
    End

    <Home> mHome()


/*
 * mHalfPgDn - Half Page Down
 *             Missing from TSEv1!  I use this a lot.
 */
    Proc mHalfPgDn()
      Integer nLines

      nLines = Query( WindowRows ) / 2
      While nLines
        RollDown()
        nLines = nLines -1
      EndWhile
    End

    <f8> mHalfPgDn()

/*
 * mHalfPgUp - Half Page Up
 *             Missing from TSEv1!
 */
    Proc mHalfPgUp()
      Integer nLines

      nLines = Query ( WindowRows ) / 2
      While nLines
        RollUp()
        nLines = nLines -1
      EndWhile
    End

    <f7> mHalfPgUp()
