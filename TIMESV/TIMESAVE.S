/******************************************************************************/
/* Macro      : TIMESAVE.S                                                    */
/* Programmer : Todd Fiske                                                    */
/*                                                                            */
/* Purpose    : Create a timed save function for TSE                          */
/*                                                                            */
/* Revision   : 05/26/1993 - first version                                    */
/* History                                                                    */
/*                                                                            */
/* Language   : SAL 1.0 (Pre-Release)                                         */
/*                                                                            */
/* This system would work really well if there was some sort of Timer         */
/* interrupt one could hook onto. I'm sure such a thing could be written as a */
/* .BIN file, but that's beyond my abilities. Right now, its set up to        */
/* trigger on the SpaceBar key which seems to work pretty well. I *almost*    */
/* don't notice it when it saves, but there is a slight lag. If I had more    */
/* files open, I'm sure it would take longer.                                 */
/*                                                                            */
/* I'm actually amazed that I could write this thing at all! It took about a  */
/* half an hour from "inspiration" (when the lights flickered just now <g>)   */
/* to completion. This is an amazing program (TSE that is)!                   */
/*                                                                            */
/******************************************************************************/

integer
   iSaveInterval  = 300,               // 5 minutes worth of seconds
   iIntervalStart =   0                // if zero, system not initialized

/******************************************************************************/
/* Function   : TimeNum                                                       */
/* Returns    : an integer containing the number of seconds since Midnight    */
/******************************************************************************/
integer proc TimeNum()
   integer
      iHours = 0,
      iMins  = 0,
      iWork  = 0,
      iHunds = 0
   GetTime(iHours, iMins, iWork, iHunds)
   iWork = iWork + (iMins * 60) + (iHours * 3600)
   return (iWork)
end

/******************************************************************************/
/* Procedure  : TimedSave                                                     */
/* Purpose    : Automatically saves all files when SpaceBar is pressed and    */
/*              pre-set interval has elapsed                                  */
/******************************************************************************/
proc TimedSave()
   InsertText(' ')                                         // insert a space
   if (iIntervalStart == 0)                                // first time
      iIntervalStart = TimeNum()                           // create base time
   else
      if ((TimeNum() - iIntervalStart) > iSaveInterval)    // interval elapsed
      or (TimeNum() < iIntervalStart)                      // midnight rollover
         Message('AutoSave!')
         SaveAllFiles()
         iIntervalStart = TimeNum()
      endif
   endif
end
<SpaceBar>              TimedSave()

/******************************************************************************/
/* Procedure  : ShowSave                                                      */
/* Purpose    : show the current status of the AutoSave system                */
/******************************************************************************/
proc ShowSave()
   integer iCurrent = TimeNum()
   Message(
      Format(
         'AutoSave System :',
         '  Interval ', iSaveInterval:5,
         '  Start ',    iIntervalStart:5,
         '  Current ',  iCurrent:5,
         '  Elapsed ',  (iCurrent - iIntervalStart):5)
   )
end
<Ctrl F6>               ShowSave()

/******************************************************************************/
/* Procedure  : SetInterval                                                   */
/* Purpose    : allow user to set a new AutoSave interval                     */
/******************************************************************************/
proc SetInterval()
   string sInterval[5] = str(iSaveInterval)
   if Ask("AutoSave Interval (in seconds):", sInterval)
      iSaveInterval = val(sInterval)
   endif
end
<Shift F6>              SetInterval()

/******************************************************************************/
/* EOF        : TIMESAVE.S                                                    */
/******************************************************************************/

