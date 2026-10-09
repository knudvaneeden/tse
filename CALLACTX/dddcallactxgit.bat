 @REM version: 1.0.0.0.0 [kn, ri, tu, 01-09-2026 17:11:22]

 @echo off
 g:
 cd /d g:\versioncontrol\git\ddd01\CALLACTX\
 git add "callactx.cpp"
 git add "callactx.def"
 git add "callactx.dll"
 git add "callactx.doc"
 git add "callactx.dsp"
 git add "callactx.dsw"
 git add "callactx.ncb"
 git add "callactx.opt"
 git add "callactx.plg"
 git add "callactx.s"
 git add "callactx.txt"
 git add "callactx.zip"
 git add "callactx_readme.md"
 git add "file_id.diz"
 git add "ie.vbs"
 git add "msscript.tlh"
 git add "msscript.tli"
 git add "notes"
 git add "safearrayhelper.cpp"
 git add "safearrayhelper.h"
 git add "scriptobject.cpp"
 git add "scriptobject.h"
 git add "xml.vbs"
 git commit -m "Update callactx directory files"
 git push origin HEAD:TRUNK
 start https://github.com/knudvaneeden/tse/tree/TRUNK/CALLACTX
