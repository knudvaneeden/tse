                                                                                /*
   ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ÚÄÙ TSE TICKTIMR MACROS ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                          ³
 ³ SOFTWARE:    TickTimr                                                    ³
 ³ VERSION:     0.10                                                        ³
 ³ DATE:        September 2, 1994                                           ³
 ³ REV. DATE:   September 2, 1994                                           ³
 ³ AUTHOR:      Mike Chambers                                               ³
 ³ TYPE:        Include                                                     ³
 ³                                                                          ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                                                                          ³
 ³ FUNCTION:    Provide fast, simple binary timing functions                ³
 ³                                                                          ³
 ³              These macros use the system tick timer to provide           ³
 ³              timing functions without converting DOS Hr, Min, Sec        ³
 ³              values.  Since the system clock is updated on the           ³
 ³              same frequency as the system timer, it is a relatively      ³
 ³              precise means of measuring the time between two events      ³
 ³                                                                          ³
 ³                                                                          ³
 ³              integer proc TickCounter(var integer Midnight)              ³
 ³                           Returns value of system tick counter           ³
 ³                           (the number of Ticks since midnight)           ³
 ³                           and the number of midnights which have         ³
 ³                           passed since the counter was last queried      ³
 ³                                                                          ³
 ³              integer proc TickDelta(integer StartCount)                  ³
 ³                           Returns the difference in ticks between        ³
 ³                           now and a previous tick timestamp 'StartCount' ³
 ³                           Accounts for interval which cross midnight     ³
 ³                           up to a resolution of 555 days.                ³
 ³                                                                          ³
 ³              integer proc TicksToSeconds(integer ticks)                  ³
 ³                           Returns number of seconds equivalent to        ³
 ³                           'ticks'. The function is limited to            ³
 ³                           tick values less than 2,147,483 ticks          ³
 ³                           (which is: 117,951 seconds  or                 ³
 ³                                        1,965 minutes  or                 ³
 ³                                           32 hours       )               ³
 ³                                                                          ³
 ³              integer proc TickstoMs(integer ticks)                       ³
 ³                           Returns number of milliseconds represented     ³
 ³                           by 'ticks'.  The function is limited to        ³
 ³                           tick values less than 39,098 ticks             ³
 ³                           (which is: 2,147 seconds  or                   ³
 ³                                         35 minutes       )               ³
 ³                                                                          ³
 ³              integer proc TimeDosCmd(string cmd)                         ³
 ³                           Returns number of ticks taken to execute       ³
 ³                           the Dos command 'cmd'.                         ³
 ³                                                                          ³
 ³              integer proc TimeTseMacro(string macro)                     ³
 ³                           Returns number of ticks taken to execute       ³
 ³                           the TSE macro 'macro'.  The macro must         ³
 ³                           be public.                                     ³
 ³                                                                          ³
 ³                      proc ReportTimes(integer ticks)                     ³
 ³                           Displays times as ticks, seconds, and          ³
 ³                           milliseconds in status line warning            ³
 ³                           area                                           ³
 ³                                                                          ³
 ³                                                                          ³
 ³                                                                          ³
 ³  LIMITATIONS:  The approach has been to stick within integer limitations ³
 ³                and as a result, there are 31 bit limitations involved in ³
 ³                the conversion calculations that force trade offs between ³
 ³                range and precision.  (See the macro descriptions above   ³
 ³                for specific limits.)  TicksToMs is slanted toward        ³
 ³                resolution, whereas TicksToSeconds is slanted toward      ³
 ³                higher range.                                             ³
 ³                                                                          ³
 ³                The Main() and ReportTimes procedures are primarily for   ³
 ³                demonstration of the timing functions.                    ³
 ³                                                                          ³
 ³                                                                          ³
 ³  These macros are in 'test mode'.  While I know of no problems, use      ³
 ³  them at your own risk.  And in the words of Mikhail Gorbachev:          ³
 ³                      "Trust -- but verify."                              ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    */

constant TicksPerDay     =  0x1800B0

#include "intr.inc"

integer proc TickCounter(var integer Midnight)
        _AX = 0
        intr(_FLAGS, 0x1A)
        MidNight = (_AX & 0x0000FFFF)
        return((_CX shl 16) | _DX)
end

integer proc TickDelta(integer StartCount)
        integer EndCount, MidNight, Delta
        EndCount=TickCounter(Midnight)
        if MidNight > 0
                Delta = ((MidNight*TicksPerDay) - StartCount + EndCount)
           else
                Delta = (EndCount - StartCount)
        endif
        return(Delta)
end


integer proc TicksToSeconds(integer ticks)
        return((Ticks * 1000) / 18206)
end


integer proc TickstoMs(integer ticks)
        return((Ticks*54925) / 1000)
end


integer proc TimeDosCmd(string cmd)
        integer Startticks, Midnight
        StartTicks = TickCounter(Midnight)
        Dos(Cmd,_DONT_PROMPT_)
        return(TickDelta(StartTicks))
end

integer proc TimeTseMacro(string macro)
        integer Startticks, Midnight
           StartTicks = TickCounter(Midnight)
        if not ExecMacro(macro)
           warn(macro,' not was not found')
        endif
        return(TickDelta(StartTicks))
end

proc ReportTimes(integer ticks)
    warn(ticks, ' ticks')
    warn(TicksToSeconds(ticks),' seconds')
    warn(TicksToMs(ticks), ' milliseconds')
end


