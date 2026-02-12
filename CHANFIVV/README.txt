===

1. -To install

     1. -Take the file chanfivv_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstallchanfivv.bat

     4. -That will create a new file chanfivv_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          chanfivv.mac

2. -The .ini file is the local file 'chanfivv.ini'
    (thus not using tse.ini)

===

 // Use case = You want to make different TSE configuration files active on your demand while inside TSE
 //
 // ===
 //
 // Method =
 //
 // This is thus designed to be done completely
 // only from within TSE itself
 // (so no exit of TSE or restart of TSE or start of another TSE executable necessary)
 //
 // One simplest approach:
 //
 //  1. Keep your desired settings as usual in 1, 2, 3, ..., N different profile text files
 //
 //  2. Use a List() to load the desired current profile text file from those available profile text files
 //
 //  3. Then parse one after the other all lines in the currently loaded profile text file.
 //
 //  4. Each of those single lines contains a key = value pair, like
 //
 //      blablabla = 123
 //
 //      xyzxyz = ON
 //
 //       ...
 //
 //  5. Extract the key and the value
 //
 //  6. Then use Set() to enable or disable that key value pair in that line
 //
 //  7. You can not (by TSE design and syntax) use a string variable for the set name, so you will have to output it verbatim to a TSE macro and compile that
 //
 // ===
 //
 // Example:
 //
 // Input: snippet from a TSE configuration file
 //
 /*
--- cut here: begin --------------------------------------------------
StartUpFlags            = _STARTUP_MENU_
GUIStartUpFlags         = _USE_DEFAULT_WIN_POS_|_USE_LAST_SAVED_FONT_|_USE_LAST_SAVED_WIN_SIZE_
SingleInstance          = On
DefaultExt              = "ui s si c cpp h java pas inc bat prg txt doc html asm"
FileLocking             = _NONE_
LoadWildFromDos         = On
LoadWildFromInside      = On
PickFileChangesDir      = Off
PickFileFlags           = _ADD_DIRS_ | _ADD_SLASH_ | _DIRS_AT_TOP_
PickFileSortOrder       = "ne"
EOLType                 = 0         // 0=As Loaded, 1=^M (CR), 2=^J (LF), 3=^M^J (CR/LF)
EOFType                 = 2         // 0=nothing, 1=^Z, 2=EOLType, 3=EOLType+^Z
--- cut here: end ----------------------------------------------------
 */
 //
 // Output: a compilable TSE .s file with the configuration values set using Set()
 //
 /*
--- cut here: begin --------------------------------------------------
PROC Main()
 Set( StartUpFlags , _STARTUP_MENU_ )
 Set( GUIStartUpFlags , _USE_DEFAULT_WIN_POS_|_USE_LAST_SAVED_FONT_|_USE_LAST_SAVED_WIN_SIZE_ )
 Set( SingleInstance , On )
 Set( DefaultExt , "ui s si c cpp h java pas inc bat prg txt doc html asm" )
 Set( FileLocking , _NONE_ )
 Set( LoadWildFromDos , On )
 Set( LoadWildFromInside , On )
 Set( PickFileChangesDir , Off )
 Set( PickFileFlags , _ADD_DIRS_ | _ADD_SLASH_ | _DIRS_AT_TOP_ )
 Set( PickFileSortOrder , "ne" )
 Set( EOLType , 0 )
 Set( EOFType , 2 )
END
--- cut here: end ----------------------------------------------------
 */
