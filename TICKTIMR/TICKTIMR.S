
/*** TSE TICKDEMO MACROS ****************************************************
 ****************************************************************************/


#include "ticktimr.inc"


proc Main()
    integer Ticks
    ticks = TimeTseMacro('iconfig')
    ReportTimes(ticks)
    ReportTimes(TimeDosCmd('dir'))
end

