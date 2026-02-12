===

1. -To install

     1. -Take the file setwiyde_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstallsetwiyde.bat

     4. -That will create a new file setwiyde_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          setwiyde.mac

2. -The .ini file is the local file 'setwiyde.ini'
    (thus not using tse.ini)

===

Use case: you want to position a popup window at a specific position on the monitor screen. E.g. the right top corner of the screen.

===

Method: You must insert the text

         ExecMacro( "setwiyde" )

        immediately 1 line before the following keywords, e.g.

         ExecMacro( "setwiyde" )
         Warn( "test" )

         ExecMacro( "setwiyde" )
         YesNo( "test" )
