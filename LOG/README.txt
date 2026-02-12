===

1. -To install

     1. -Take the file log_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstalllog.bat

     4. -That will create a new file log_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          log.mac

2. -The .ini file is the local file 'log.ini'
    (thus not using tse.ini)

===

/*
  Macro           Log
  Author          Carlo Hogeveen
  Compatibility   TSE v4 upwards, Windows and Linux
  Version         v1   14 Mar 2022

  This macro helps another macro to log lines to a log file.

  Log lines are prefixed with the date and time.

  USAGE
    The macro is used by executing it as follows:
      log open <filename>
      log write <any text>
      log close

    If <filename> already exists, then logging is appended to it.

  INSTALLATION
    Copy this file to TSE's "mac" folder, and compile it there.

  TODO
    MUST
    SHOULD
    COULD   (Let me know if you want any of these.)
    - An extra parameter <handle>, so macros can write to multiple log files
      at the same time.
      Example usage:
        log open <filename>           Returns <handle> in MacroCmdLine.
        log [handle] write [text]     A handle must be before write and close
        log [handle] close            to make it distinguishable from <text>.
    - If <filename> is a folder, create a new uniquely named log file in that
      folder.
    - If no <filename> is supplied, create a new uniquely named file in a
      default folder.
    WONT


  HISTORY

  v1   14 Mar 2022
    Initial release.

*/
